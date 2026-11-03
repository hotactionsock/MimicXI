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

#include "botprogress.h"
#include "botlog.h"
#include "botutils.h"

#include "entities/char_entity.h"
#include "utils/itemutils.h"
#include "items/craft_state.h"
#include "lua/luautils.h"
#include "utils/synthutils.h"

#include <format>
#include <string>

namespace botutils
{

namespace
{

constexpr std::array<const char*, CraftSkills{}.size()> kCraftNames = {
    "Woodworking", "Smithing", "Goldsmithing", "Clothcraft", "Leathercraft", "Bonecraft", "Alchemy", "Cooking",
};

constexpr std::array<const char*, 11> kRankNames = {
    "Amateur", "Recruit", "Initiate", "Novice", "Apprentice", "Journeyman", "Craftsman", "Artisan", "Adept", "Veteran", "Expert",
};

auto craftName(uint8 skillId) -> std::string
{
    return skillId >= kFirstCraftSkill && skillId <= kLastCraftSkill ? kCraftNames[skillId - kFirstCraftSkill] : std::to_string(skillId);
}

auto itemName(uint16 itemId) -> std::string
{
    const auto* PItem = xi::items::lookup(itemId);
    return PItem ? HumanName(PItem->getName()) : std::to_string(itemId);
}

} // namespace

void OnBotQuestOrMission(CCharEntity* PChar, const char* event, uint8 logId, uint16 id)
{
    if (PChar == nullptr || !IsBotEntity(PChar))
    {
        return;
    }

    luautils::OnWorldBotProgress(PChar, event, logId, id);
}

auto BotCraftSkills(CCharEntity* PChar) -> CraftSkills
{
    CraftSkills skills{};
    for (uint8 i = 0; i < skills.size(); ++i)
    {
        skills[i] = PChar->RealSkills.skill[kFirstCraftSkill + i];
    }

    return skills;
}

void LogBotSynth(CCharEntity* PChar, const CraftSkills& before)
{
    if (PChar == nullptr || !IsBotEntity(PChar))
    {
        return;
    }

    auto&       craft  = PChar->craftState();
    const uint8 result = craft.result();
    const auto  made   = craft.resultTier(result == synthutils::SYNTHESIS_FAIL ? synthutils::SYNTHESIS_SUCCESS : result);
    const auto  name   = itemName(made.itemId);

    if (craft.craftMode() != CRAFT_DESYNTHESIS)
    {
        if (result == synthutils::SYNTHESIS_FAIL)
        {
            LogBotEvent(PChar->id, BotLogLevel::Detail, "craft", "synth_failed", std::format("{}'s attempt to make {} broke", PChar->getName(), name),
                        std::format(R"({{"item_id":{},"item":"{}"}})", made.itemId, JsonEscape(name)));
        }
        else
        {
            const uint8 hq = result >= synthutils::SYNTHESIS_HQ ? static_cast<uint8>(result - synthutils::SYNTHESIS_SUCCESS) : 0;
            const auto  of = made.qty > 1 ? std::format("{} {}", made.qty, name) : name;
            LogBotEvent(PChar->id, hq ? BotLogLevel::Notable : BotLogLevel::Detail, "craft", "synth",
                        hq ? std::format("{} made {} - a high-quality result (HQ{})", PChar->getName(), of, hq)
                           : std::format("{} made {}", PChar->getName(), of),
                        std::format(R"({{"item_id":{},"item":"{}","quantity":{},"hq":{}}})", made.itemId, JsonEscape(name), made.qty, hq));
        }
    }

    // A craft that rose a whole level (skills are stored x10).
    const auto after = BotCraftSkills(PChar);
    for (uint8 i = 0; i < after.size(); ++i)
    {
        if (after[i] / 10 > before[i] / 10)
        {
            const auto craftLabel = craftName(kFirstCraftSkill + i);
            LogBotEvent(PChar->id, BotLogLevel::Notable, "craft", "craft_skill",
                        std::format("{}'s {} rose to {}", PChar->getName(), craftLabel, after[i] / 10),
                        std::format(R"({{"craft":"{}","skill_id":{},"level":{}}})", craftLabel, kFirstCraftSkill + i, after[i] / 10));
        }
    }
}

void LogBotCraftRank(CCharEntity* PChar, uint8 skillId, uint8 rank)
{
    if (PChar == nullptr || !IsBotEntity(PChar) || skillId < kFirstCraftSkill || skillId > kLastCraftSkill)
    {
        return;
    }

    const auto craftLabel = craftName(skillId);
    const auto rankLabel  = rank < kRankNames.size() ? kRankNames[rank] : std::to_string(rank);
    LogBotEvent(PChar->id, BotLogLevel::Milestone, "craft", "craft_rank",
                std::format("{} reached {} rank in {}", PChar->getName(), rankLabel, craftLabel),
                std::format(R"({{"craft":"{}","skill_id":{},"rank":{},"rank_name":"{}"}})", craftLabel, skillId, rank, rankLabel));
}

} // namespace botutils
