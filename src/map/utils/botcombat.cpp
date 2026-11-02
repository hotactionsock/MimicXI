/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "botcombat.h"

#include "botutils.h"

#include "common/logging.h"
#include "common/settings.h"
#include "common/utils.h"
#include "common/xirand.h"

#include "ai/ai_container.h"
#include "ai/controllers/world_bot_controller.h"
#include "ai/helpers/pathfind.h"
#include "ai/states/magic_state.h"
#include "entities/char_entity.h"
#include "entities/mob_entity.h"
#include "item_container.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "status_effect.h"
#include "status_effect_container.h"
#include "treasure_pool.h"
#include "utils/charutils.h"
#include "zone.h"
#include "zone_entities.h"
#include "ability.h"
#include "items/item_weapon.h"
#include "party.h"
#include "recast_container.h"
#include "spell.h"
#include "utils/battleutils.h"
#include "weapon_skill.h"

#include <list>

namespace botutils
{

namespace
{

auto liveBot(uint32 charId) -> CCharEntity*
{
    if (g_PMapEngine == nullptr)
    {
        return nullptr;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar || session->PChar->loc.zone == nullptr)
    {
        return nullptr;
    }

    return session->PChar.get();
}

auto isFightable(CMobEntity* PMob) -> bool
{
    return PMob->isAlive() && PMob->status != xi::Status::Disappear && !PMob->PAI->IsUntargetable() &&
           PMob->PMaster == nullptr && PMob->allegiance == xi::Allegiance::Mob;
}

// Prey for a group of partySize by the engine's /check, same as zone scoring.
auto suitsLevel(CMobEntity* PMob, uint8 level, uint8 partySize = 1) -> bool
{
    return IsBotPrey(level, PMob->GetMLevel() + PMob->getMod(xi::Mod::EXP_LVL_MOD), partySize);
}

auto isAttacking(CMobEntity* PMob, CCharEntity* PChar) -> bool
{
    return PMob->PAI->IsEngaged() && PMob->GetBattleTarget() == PChar;
}

auto findAttacker(CCharEntity* PChar) -> std::optional<BotTarget>
{
    std::optional<BotTarget> best;

    // clang-format off
    PChar->loc.zone->GetZoneEntities()->ForEachMob([&](CMobEntity* PMob)
    {
        if (!isFightable(PMob) || !isAttacking(PMob, PChar))
        {
            return;
        }

        const float d = distance(PChar->loc.p, PMob->loc.p);
        if (!best || d < best->distance)
        {
            best = BotTarget{ PMob->id, PMob->loc.p, d, true };
        }
    });
    // clang-format on

    return best;
}

} // namespace

auto FindBotAttacker(uint32 charId) -> std::optional<BotTarget>
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return std::nullopt;
    }

    return findAttacker(PChar);
}

auto FindBotTarget(uint32 charId, float radius, uint8 partySize) -> std::optional<BotTarget>
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return std::nullopt;
    }

    if (auto attacker = findAttacker(PChar))
    {
        return attacker;
    }

    const uint8              level = PChar->GetMLevel();
    std::optional<BotTarget> best;

    // clang-format off
    PChar->loc.zone->GetZoneEntities()->ForEachMob([&](CMobEntity* PMob)
    {
        if (!isFightable(PMob) || PMob->m_Type != xi::MobType::Normal || !suitsLevel(PMob, level, partySize))
        {
            return;
        }

        // Leave other people's fights alone: unclaimed and not already busy.
        if (PMob->PAI->IsEngaged() || (PMob->m_OwnerID.isSet() && PMob->m_OwnerID.UniqueNo != PChar->id))
        {
            return;
        }

        const float d = distance(PChar->loc.p, PMob->loc.p);
        if (d <= radius && (!best || d < best->distance))
        {
            best = BotTarget{ PMob->id, PMob->loc.p, d, false };
        }
    });
    // clang-format on

    return best;
}

auto EngageBotTarget(uint32 charId, uint32 mobId) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead())
    {
        return false;
    }

    auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController());
    auto* PMob       = dynamic_cast<CMobEntity*>(PChar->loc.zone->GetEntity(static_cast<uint16>(mobId & 0xFFF), TYPE_MOB));
    if (controller == nullptr || PMob == nullptr || PMob->id != mobId)
    {
        return false;
    }

    // Stand up first - /heal and fighting don't mix.
    PChar->StatusEffectContainer->DelStatusEffectSilent(xi::StatusEffect::Healing);

    return controller->Engage(EntityId(PMob));
}

void SetBotHealing(uint32 charId, bool on)
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead())
    {
        return;
    }

    if (!on)
    {
        PChar->StatusEffectContainer->DelStatusEffectSilent(xi::StatusEffect::Healing);
        return;
    }

    if (PChar->PAI->IsEngaged() || PChar->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::Healing))
    {
        return;
    }

    // Same as GP_CLI_COMMAND_CAMP's enableHealing.
    PChar->PAI->ClearStateStack();
    const auto healingTickDelay = std::chrono::seconds(settings::get<uint8>("map.HEALING_TICK_DELAY"));
    PChar->StatusEffectContainer->AddStatusEffect(xi::StatusEffect::Healing, 0, 0, healingTickDelay, 0s);
}

auto LotBotTreasure(uint32 charId) -> uint8
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->PTreasurePool == nullptr)
    {
        return 0;
    }

    uint8 lotted = 0;
    for (const auto& item : PChar->PTreasurePool->getItems())
    {
        if (item.ID == 0 || PChar->PTreasurePool->hasLottedItem(PChar, item.SlotID) ||
            PChar->PTreasurePool->hasPassedItem(PChar, item.SlotID))
        {
            continue;
        }

        if (PChar->getStorage(LOC_INVENTORY)->GetFreeSlotsCount() == 0)
        {
            break;
        }

        PChar->PTreasurePool->lotItem(PChar, item.SlotID, static_cast<uint16>(xirand::GetRandomNumber(1, 1000)));
        ++lotted;
    }

    return lotted;
}

auto UseBotWeaponSkill(uint32 charId, uint16 wsId) -> uint16
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead() || !PChar->PAI->IsEngaged() || PChar->health.tp < 1000)
    {
        return 0;
    }

    auto* PTarget    = PChar->GetBattleTarget();
    auto* PWeapon    = dynamic_cast<CItemWeapon*>(PChar->m_Weapons[SLOT_MAIN]);
    auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController());
    if (PTarget == nullptr || PWeapon == nullptr || controller == nullptr)
    {
        return 0;
    }

    // The requested weapon skill, or the strongest it knows for this weapon type.
    CWeaponSkill* PBest = nullptr;
    for (auto* PSkill : battleutils::GetWeaponSkills(static_cast<uint8>(PWeapon->getSkillType())))
    {
        if (PSkill == nullptr || !charutils::hasWeaponSkill(PChar, PSkill->getID()))
        {
            continue;
        }

        if (wsId != 0)
        {
            if (PSkill->getID() == wsId)
            {
                PBest = PSkill;
                break;
            }
        }
        else if (PBest == nullptr || PSkill->getSkillLevel() > PBest->getSkillLevel())
        {
            PBest = PSkill;
        }
    }

    if (PBest == nullptr || !controller->WeaponSkill(EntityId(PTarget), PBest->getID()))
    {
        return 0;
    }

    return PBest->getID();
}

auto GetBotAbilities(uint32 charId) -> std::vector<BotAbility>
{
    std::vector<BotAbility> result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return result;
    }

    for (const auto job : { PChar->GetMJob(), PChar->GetSJob() })
    {
        if (job == xi::Job::NONE)
        {
            continue;
        }

        for (auto* PAbility : ability::GetAbilities(job))
        {
            if (PAbility == nullptr || PAbility->getRecastId() == static_cast<Recast>(0) ||
                !charutils::hasAbility(PChar, PAbility->getID()))
            {
                continue;
            }

            const bool onCooldown = PChar->PRecastContainer->HasRecast(RECAST_ABILITY, PAbility->getRecastId(), PAbility->getRecastTime());
            result.push_back({ PAbility->getID(), !onCooldown, (PAbility->getValidTarget() & TARGET_ENEMY) != 0 });
        }
    }

    return result;
}

auto UseBotAbility(uint32 charId, uint16 abilityId) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead() || !charutils::hasAbility(PChar, abilityId))
    {
        return false;
    }

    auto* PAbility   = ability::GetAbility(abilityId);
    auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController());
    if (PAbility == nullptr || controller == nullptr)
    {
        return false;
    }

    CBattleEntity* PTarget = PChar;
    if ((PAbility->getValidTarget() & TARGET_ENEMY) != 0)
    {
        PTarget = PChar->GetBattleTarget();
        if (PTarget == nullptr)
        {
            return false;
        }
    }

    return controller->Ability(EntityId(PTarget), abilityId);
}

auto HomepointBot(uint32 charId) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || !PChar->isDead())
    {
        return false;
    }

    // Revive as the home-point menu does (charutils::HomePoint with resetHPMP),
    // then persist it - the teleport reloads the character from the database.
    PChar->StatusEffectContainer->DelStatusEffectSilent(xi::StatusEffect::Weakness);
    PChar->StatusEffectContainer->DelStatusEffectSilent(xi::StatusEffect::LevelSync);
    PChar->SetDeathTime(timer::time_point::min());
    PChar->health.hp = PChar->GetMaxHP();
    PChar->health.mp = PChar->GetMaxMP();
    PChar->animation = xi::Animation::None;

    charutils::SaveCharStats(PChar);
    charutils::SaveDeathTime(PChar);

    const auto destination = PChar->profile.home_point.destination;
    const auto pos         = PChar->profile.home_point.p;

    return TeleportBotCharacter(charId, destination, pos.x, pos.y, pos.z, pos.rotation) != nullptr;
}

// ---- Spellcasting -----------------------------------------------------------

auto GetBotSpells(uint32 charId) -> std::vector<BotSpell>
{
    std::vector<BotSpell> result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return result;
    }

    for (uint16 id = 1; id < 1024; ++id)
    {
        if (!PChar->m_SpellList[id])
        {
            continue;
        }

        auto* PSpell = spell::GetSpell(static_cast<SpellID>(id));
        if (PSpell == nullptr || PSpell->getSpellGroup() == SPELLGROUP_TRUST || !spell::CanUseSpell(PChar, PSpell))
        {
            continue;
        }

        const bool onCooldown = PChar->PRecastContainer->HasRecast(RECAST_MAGIC, static_cast<Recast>(id), 0s);

        result.push_back({ id,
                           PSpell->getMPCost(),
                           static_cast<uint8>(PSpell->getSkillType()),
                           static_cast<uint8>(PSpell->getSpellGroup()),
                           PSpell->canTargetEnemy(),
                           !onCooldown,
                           static_cast<uint8>(PSpell->getElement()) });
    }

    return result;
}

auto CastBotSpell(uint32 charId, uint16 spellId, uint32 targetId) -> BotCastResult
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead() || spellId == 0 || spellId >= 1024 || !PChar->m_SpellList[spellId])
    {
        return BotCastResult::Invalid;
    }

    auto* PSpell     = spell::GetSpell(static_cast<SpellID>(spellId));
    auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController());
    if (PSpell == nullptr || controller == nullptr || !spell::CanUseSpell(PChar, PSpell))
    {
        return BotCastResult::Invalid;
    }

    if (PChar->PRecastContainer->HasRecast(RECAST_MAGIC, static_cast<Recast>(spellId), 0s) || PChar->PAI->IsCurrentState<CMagicState>())
    {
        return BotCastResult::NotReady;
    }

    if (PSpell->hasMPCost() && PChar->health.mp < PSpell->getMPCost())
    {
        return BotCastResult::NoMP;
    }

    CBattleEntity* PTarget = PChar;
    if (PSpell->canTargetEnemy())
    {
        PTarget = PChar->GetBattleTarget();
        if (PTarget == nullptr || distance(PChar->loc.p, PTarget->loc.p) > PSpell->getRange())
        {
            return BotCastResult::NoTarget;
        }
    }
    else if (targetId != 0 && targetId != PChar->id)
    {
        // A party member: the spell must allow it, and they must be here.
        if ((PSpell->getValidTarget() & TARGET_PLAYER_PARTY) == 0 || PChar->PParty == nullptr)
        {
            return BotCastResult::Invalid;
        }

        PTarget = nullptr;
        for (auto* PMember : PChar->PParty->members)
        {
            if (PMember != nullptr && PMember->id == targetId)
            {
                PTarget = PMember;
                break;
            }
        }

        if (PTarget == nullptr || PTarget->isDead() || PTarget->loc.zone != PChar->loc.zone ||
            distance(PChar->loc.p, PTarget->loc.p) > PSpell->getRange())
        {
            return BotCastResult::NoTarget;
        }
    }

    // Moving interrupts a spell: stop any walk, and face an enemy target.
    controller->ClearWanderTarget();
    if (auto* path = PChar->PAI->PathFind.get())
    {
        path->Clear();
        if (PTarget != PChar)
        {
            path->LookAt(PTarget->loc.p);
        }
    }

    return controller->Cast(EntityId(PTarget), static_cast<SpellID>(spellId)) ? BotCastResult::Cast : BotCastResult::NotReady;
}

auto IsBotCasting(uint32 charId) -> bool
{
    auto* PChar = liveBot(charId);
    return PChar != nullptr && PChar->PAI->IsCurrentState<CMagicState>();
}

void SetBotCombatRange(uint32 charId, float yalms)
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return;
    }

    if (auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController()))
    {
        controller->SetCombatRange(yalms);
    }
}

// ---- Travel safety ----------------------------------------------------------

auto ScanBotThreats(uint32 charId, float radius, uint8 partySize) -> std::vector<BotThreat>
{
    std::vector<BotThreat> result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return result;
    }

    const uint8 level = PChar->GetMLevel();

    // clang-format off
    PChar->loc.zone->GetZoneEntities()->ForEachMob([&](CMobEntity* PMob)
    {
        if (PMob == nullptr || PMob->isDead() || !PMob->PAI->IsSpawned() || PMob->PMaster != nullptr || PMob->PAI->IsEngaged())
        {
            return;
        }

        const float d = distance(PChar->loc.p, PMob->loc.p);
        if (d > radius)
        {
            return;
        }

        // Same "am I aggressive at all" checks as CMobController::CanAggroTarget.
        const bool aggressive = (PMob->getMobMod(xi::MobMod::AlwaysAggro) != 0 || PMob->m_Aggro) && !PMob->m_neutral &&
                                PMob->getMobMod(xi::MobMod::NoAggro) == 0 &&
                                !(((PMob->m_roamFlags & xi::RoamFlag::Worm) != xi::RoamFlag::None) && PMob->IsNameHidden());
        if (!aggressive)
        {
            return;
        }

        // Prey it would happily fight anyway, and Too Weak mobs don't aggro.
        if (suitsLevel(PMob, level, partySize) || charutils::CheckMob(level, PMob) <= EMobDifficulty::TooWeak)
        {
            return;
        }

        const auto detects = static_cast<xi::Detects>(PMob->getMobMod(xi::MobMod::Detection));

        BotThreat threat{};
        threat.mobId         = PMob->id;
        threat.pos           = PMob->loc.p;
        threat.distance      = d;
        threat.sight         = (detects & xi::Detects::Sight) != xi::Detects::None;
        threat.sound         = (detects & xi::Detects::Hearing) != xi::Detects::None;
        threat.trueDetection = PMob->m_TrueDetection;
        threat.sightRange    = static_cast<float>(PMob->getMobMod(xi::MobMod::SightRange));
        threat.soundRange    = static_cast<float>(PMob->getMobMod(xi::MobMod::SoundRange));
        result.push_back(threat);
    });
    // clang-format on

    std::sort(result.begin(), result.end(),
              [](const BotThreat& a, const BotThreat& b)
              {
                  return a.distance < b.distance;
              });

    return result;
}

namespace
{

auto findInventoryItem(CCharEntity* PChar, uint16 itemId) -> uint8
{
    auto* PInventory = PChar->getStorage(LOC_INVENTORY);
    if (PInventory == nullptr)
    {
        return 0;
    }

    for (uint8 slot = 1; slot <= PInventory->GetSize(); ++slot)
    {
        auto* PItem = PInventory->GetItem(slot);
        if (PItem != nullptr && PItem->getID() == itemId && PItem->getQuantity() > 0 && !PItem->isSent())
        {
            return slot;
        }
    }

    return 0;
}

} // namespace

auto UseBotItem(uint32 charId, uint16 itemId) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead())
    {
        return false;
    }

    const uint8 slot       = findInventoryItem(PChar, itemId);
    auto*       controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController());
    if (slot == 0 || controller == nullptr)
    {
        return false;
    }

    // Using an item is interrupted by moving, like casting.
    controller->ClearWanderTarget();
    if (auto* path = PChar->PAI->PathFind.get())
    {
        path->Clear();
    }

    return controller->UseItem(EntityId(PChar), LOC_INVENTORY, slot);
}

auto BotHasItem(uint32 charId, uint16 itemId) -> bool
{
    auto* PChar = liveBot(charId);
    return PChar != nullptr && findInventoryItem(PChar, itemId) != 0;
}

void StopBot(uint32 charId)
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return;
    }

    if (auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController()))
    {
        controller->ClearWanderTarget();
    }

    if (auto* path = PChar->PAI->PathFind.get())
    {
        path->Clear();
    }
}

// ---- Skillchains and magic bursts -------------------------------------------

namespace
{

// A weapon skill's three skillchain properties.
auto propertiesOf(CWeaponSkill* PSkill) -> std::list<SKILLCHAIN_ELEMENT>
{
    return { static_cast<SKILLCHAIN_ELEMENT>(PSkill->getPrimarySkillchain()),
             static_cast<SKILLCHAIN_ELEMENT>(PSkill->getSecondarySkillchain()),
             static_cast<SKILLCHAIN_ELEMENT>(PSkill->getTertiarySkillchain()) };
}

// The resonance a target's Skillchain effect offers, as GetSkillChainEffect reads it.
auto resonanceOf(CStatusEffect* PSCEffect) -> std::list<SKILLCHAIN_ELEMENT>
{
    if (PSCEffect->GetTier() == 0)
    {
        const auto power = PSCEffect->GetPower();
        return { static_cast<SKILLCHAIN_ELEMENT>(power & 0b1111),
                 static_cast<SKILLCHAIN_ELEMENT>((power >> 4) & 0b1111),
                 static_cast<SKILLCHAIN_ELEMENT>((power >> 8) & 0b1111) };
    }

    return { static_cast<SKILLCHAIN_ELEMENT>(PSCEffect->GetPower()) };
}

auto targetSkillchainEffect(CCharEntity* PChar) -> CStatusEffect*
{
    auto* PTarget = PChar->GetBattleTarget();
    return PTarget ? PTarget->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::Skillchain, 0) : nullptr;
}

} // namespace

auto GetBotWeaponSkills(uint32 charId) -> std::vector<BotWeaponSkill>
{
    std::vector<BotWeaponSkill> result;

    auto* PChar   = liveBot(charId);
    auto* PWeapon = PChar ? dynamic_cast<CItemWeapon*>(PChar->m_Weapons[SLOT_MAIN]) : nullptr;
    if (PWeapon == nullptr)
    {
        return result;
    }

    for (auto* PSkill : battleutils::GetWeaponSkills(static_cast<uint8>(PWeapon->getSkillType())))
    {
        if (PSkill != nullptr && charutils::hasWeaponSkill(PChar, PSkill->getID()))
        {
            result.push_back({ PSkill->getID(),
                               static_cast<uint16>(PSkill->getSkillLevel()),
                               { PSkill->getPrimarySkillchain(), PSkill->getSecondarySkillchain(), PSkill->getTertiarySkillchain() } });
        }
    }

    return result;
}

auto GetBotTargetSkillchain(uint32 charId) -> std::optional<BotSkillchainWindow>
{
    auto* PChar     = liveBot(charId);
    auto* PSCEffect = PChar ? targetSkillchainEffect(PChar) : nullptr;
    if (PSCEffect == nullptr)
    {
        return std::nullopt;
    }

    const auto now     = timer::now();
    const auto age     = now - PSCEffect->GetStartTime();
    const auto left    = PSCEffect->GetDuration() - age;
    const auto toMs    = [](auto d) { return static_cast<uint32>(std::max<int64>(0, std::chrono::duration_cast<std::chrono::milliseconds>(d).count())); };

    BotSkillchainWindow window{};
    window.tier        = static_cast<uint8>(PSCEffect->GetTier());
    window.closed      = window.tier > 0;
    window.ageMs       = toMs(age);
    window.remainingMs = toMs(left);

    if (window.closed)
    {
        window.element = static_cast<uint8>(PSCEffect->GetPower());
        for (const auto element : battleutils::GetSkillchainMagicElement(static_cast<SKILLCHAIN_ELEMENT>(window.element)))
        {
            window.burstElements.push_back(static_cast<uint8>(element));
        }
    }
    else
    {
        const auto power  = PSCEffect->GetPower();
        window.properties = { static_cast<uint8>(power & 0b1111), static_cast<uint8>((power >> 4) & 0b1111), static_cast<uint8>((power >> 8) & 0b1111) };
    }

    return window;
}

auto PredictBotSkillchain(uint32 charId, uint16 wsId) -> std::pair<uint8, uint8>
{
    auto* PChar     = liveBot(charId);
    auto* PSCEffect = PChar ? targetSkillchainEffect(PChar) : nullptr;
    auto* PSkill    = battleutils::GetWeaponSkill(wsId);
    if (PSCEffect == nullptr || PSkill == nullptr)
    {
        return { 0, 0 };
    }

    // Same timing rule as GetSkillChainEffect: a chain needs 3s since the last link.
    if (PSCEffect->GetStartTime() + 3s >= timer::now())
    {
        return { 0, 0 };
    }

    const auto skillchain = battleutils::FormSkillchain(resonanceOf(PSCEffect), propertiesOf(PSkill));
    return { static_cast<uint8>(skillchain), battleutils::GetSkillchainTier(skillchain) };
}

auto SkillchainBetween(uint16 openerWs, uint16 closerWs) -> std::pair<uint8, uint8>
{
    auto* POpener = battleutils::GetWeaponSkill(openerWs);
    auto* PCloser = battleutils::GetWeaponSkill(closerWs);
    if (POpener == nullptr || PCloser == nullptr)
    {
        return { 0, 0 };
    }

    const auto skillchain = battleutils::FormSkillchain(propertiesOf(POpener), propertiesOf(PCloser));
    return { static_cast<uint8>(skillchain), battleutils::GetSkillchainTier(skillchain) };
}

} // namespace botutils
