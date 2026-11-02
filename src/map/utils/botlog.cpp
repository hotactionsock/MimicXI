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

#include "botlog.h"

#include "botutils.h"

#include "common/database.h"
#include "common/earth_time.h"
#include "common/logging.h"
#include "common/settings.h"
#include "common/tracy.h"

#include "entities/char_entity.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "zone.h"

#include <algorithm>
#include <array>
#include <cctype>
#include <format>
#include <unordered_map>
#include <vector>

namespace botutils
{

namespace
{

struct LogRow
{
    uint32      charId;
    uint32      ts;
    uint16      zoneId;
    std::string category;
    std::string event;
    std::string message;
    std::string data;
};

std::vector<LogRow>                         g_pending;
std::unordered_map<uint32, BotHuntProgress> g_hunt;

constexpr std::size_t kMaxPending = 20000; // safety valve if the database is down

auto zoneOf(uint32 charId) -> uint16
{
    if (g_PMapEngine == nullptr)
    {
        return 0;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->PChar || session->PChar->loc.zone == nullptr)
    {
        return 0;
    }

    return static_cast<uint16>(session->PChar->getZone());
}

} // namespace

auto BotLogEnabled(BotLogLevel level) -> bool
{
    return static_cast<uint8>(level) <= settings::get<uint8>("map.WORLDBOTS_LOG_LEVEL");
}

void LogBotEvent(uint32 charId, BotLogLevel level, const std::string& category, const std::string& event, const std::string& message,
                 const std::string& dataJson)
{
    if (!BotLogEnabled(level))
    {
        return;
    }

    if (g_pending.size() >= kMaxPending)
    {
        g_pending.erase(g_pending.begin()); // keep the newest
    }

    g_pending.push_back({ charId, earth_time::timestamp(), zoneOf(charId), category, event, message, dataJson.empty() ? "{}" : dataJson });
}

void FlushBotLog()
{
    TracyZoneScoped;

    if (g_pending.empty())
    {
        return;
    }

    std::vector<LogRow> rows;
    rows.swap(g_pending);

    const bool ok = db::transaction(
        [&rows]()
        {
            for (const auto& row : rows)
            {
                if (!db::preparedStmt("INSERT INTO world_bot_log (charid, ts, zone_id, category, event, message, data) VALUES (?, ?, ?, ?, ?, ?, ?)",
                                      row.charId, row.ts, row.zoneId, row.category, row.event, row.message, row.data))
                {
                    throw std::runtime_error("world_bot_log insert failed");
                }
            }
        });

    if (!ok)
    {
        ShowError("botutils::FlushBotLog: could not write %u bot log rows; keeping them for the next flush", static_cast<uint32>(rows.size()));
        rows.insert(rows.end(), g_pending.begin(), g_pending.end());
        g_pending.swap(rows);
        if (g_pending.size() > kMaxPending)
        {
            g_pending.erase(g_pending.begin(), g_pending.begin() + static_cast<std::ptrdiff_t>(g_pending.size() - kMaxPending));
        }
    }
}

void PruneBotLog()
{
    const auto days = settings::get<uint32>("map.WORLDBOTS_LOG_RETENTION_DAYS");
    if (days == 0)
    {
        return;
    }

    const uint32 cutoff = earth_time::timestamp() - days * 24 * 60 * 60;
    db::preparedStmt("DELETE FROM world_bot_log WHERE ts < ? LIMIT 50000", cutoff);
}

auto HumanName(const std::string& internalName) -> std::string
{
    // Word by word: capitalise, and write Roman numerals in capitals ("Cure II").
    std::string result;
    std::string word;

    const auto flush = [&]()
    {
        if (word.empty())
        {
            return;
        }

        const bool roman = std::all_of(word.begin(), word.end(),
                                       [](char c)
                                       {
                                           const char lower = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
                                           return lower == 'i' || lower == 'v' || lower == 'x';
                                       });

        for (std::size_t i = 0; i < word.size(); ++i)
        {
            const auto c = static_cast<unsigned char>(word[i]);
            result.push_back(roman || i == 0 ? static_cast<char>(std::toupper(c)) : word[i]);
        }

        word.clear();
    };

    for (const char c : internalName)
    {
        if (c == '_' || c == ' ' || c == '-')
        {
            flush();
            result.push_back(c == '_' ? ' ' : c);
        }
        else
        {
            word.push_back(c);
        }
    }

    flush();
    return result;
}

auto JobFullName(uint8 job) -> std::string
{
    static const std::array<const char*, 23> names = {
        "", "Warrior", "Monk", "White Mage", "Black Mage", "Red Mage", "Thief", "Paladin", "Dark Knight", "Beastmaster", "Bard", "Ranger",
        "Samurai", "Ninja", "Dragoon", "Summoner", "Blue Mage", "Corsair", "Puppetmaster", "Dancer", "Scholar", "Geomancer", "Rune Fencer",
    };

    return job < names.size() ? names[job] : "";
}

auto JsonEscape(const std::string& text) -> std::string
{
    std::string result;
    result.reserve(text.size() + 2);

    for (const char c : text)
    {
        switch (c)
        {
            case '"':
                result += "\\\"";
                break;
            case '\\':
                result += "\\\\";
                break;
            case '\n':
                result += "\\n";
                break;
            case '\r':
                result += "\\r";
                break;
            case '\t':
                result += "\\t";
                break;
            default:
                if (static_cast<unsigned char>(c) < 0x20)
                {
                    result += std::format("\\u{:04x}", static_cast<unsigned char>(c));
                }
                else
                {
                    result.push_back(c);
                }
                break;
        }
    }

    return result;
}

void NoteBotHunt(uint32 charId, uint32 exp, bool kill)
{
    auto& progress = g_hunt[charId];
    progress.exp += exp;
    if (kill)
    {
        ++progress.kills;
    }
}

auto TakeBotHuntProgress(uint32 charId) -> BotHuntProgress
{
    const auto it = g_hunt.find(charId);
    if (it == g_hunt.end())
    {
        return {};
    }

    const auto progress = it->second;
    g_hunt.erase(it);
    return progress;
}

} // namespace botutils
