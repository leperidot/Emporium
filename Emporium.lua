-- Emporium.lua

-- ================================================================
-- LUA 5.0 COMPATIBILITY (for older WoW 1.12.1 clients)
-- ================================================================
-- Some WoW clients use Lua 5.0 which doesn't have string.match or string.gmatch
-- This shim provides compatibility using string.find and string.gfind

if not string.match then
    string.match = function(s, pattern, init)
        init = init or 1
        local i, j, c1, c2, c3, c4, c5, c6, c7, c8, c9 = string.find(s, pattern, init)
        if i then
            return c1, c2, c3, c4, c5, c6, c7, c8, c9
        end
        return nil
    end
end

if not string.gmatch then
    -- In Lua 5.0, it's called string.gfind
    string.gmatch = string.gfind
end

EmporiumDB = EmporiumDB or {}

-- ================================================================
-- CONFIGURATION & STATE VARIABLES
-- ================================================================

local TRADE_RANGE  = 5  -- Level range tolerance (±5 levels)
local guildEnabled = true  -- Guild channel monitoring on/off
local debugMode    = false   -- Print debug messages

-- Level cache for senders without explicit level in their message
-- EmporiumDB.levelCache = { ["PlayerName"] = level, ... }
local LEVEL_CACHE_RANGE = 5  -- +/- range applied when using cached level

-- ================================================================
-- HELPER FUNCTIONS
-- ================================================================

-- Check if message contains WTS
local function IsTradeMessage(msg)
    local s = string.lower(msg)
    return string.find(s, "wts")
end

-- Check if player's level is within the specified range
local function PlayerLevelInRange(rangeMin, rangeMax)
    return UnitLevel("player") >= rangeMin and UnitLevel("player") <= rangeMax
end

local function GetLevelRange(level)
    if level and level >= 1 and level <= 60 then
        return math.max(1, level - TRADE_RANGE), math.min(60, level + TRADE_RANGE)
    end
    return 0, 0
end

-- ================================================================
-- LEVEL RANGE PARSER
-- ================================================================
-- Extracts level information from trade messages
-- Supports formats:
--   "28+-", "28+", "28-"       → 23-33 (±5 from base)
--   "28±"                      → 23-33 (±5 from base)
--   "25-30"                    → 25-30 (explicit range)
--   "lvl 27", "lv 27"          → 22-32 (±5 from level)
--   Bare numbers (fallback)    → ±5 from number
-- Returns: rangeMin, rangeMax (or nil if no level found)

local function ParseLevelRange(msg)
    local s = string.lower(msg)

    -- "28+-", "28+--", etc. (at end of message)
    local level = string.match(s, "(%d+)%s*[%+%-][%+%-%/]+$")
    if not level then
        -- "28+-" followed by non-digit
        level = string.match(s, "(%d+)%s*[%+%-][%+%-%/]+[^%d]")
    end
    if not level then
        -- "+-28" at end
        level = string.match(s, "[%+%-][%+%-%/]+(%d+)%s*$")
    end
    if not level then
        -- "28±" (plus-minus symbol, UTF-8 encoded as \194\177)
        level = string.match(s, "(%d+)%s*\194\177")
    end
    if not level then
        -- "28+" or "28-" at end
        level = string.match(s, "(%d+)%s*[%+%-]$")
    end
    if not level then
        -- "28+" or "28-" followed by non-digit/non-symbol
        level = string.match(s, "(%d+)%s*[%+%-][^%+%-%d/]")
    end
    if level then
        level = tonumber(level)
        return GetLevelRange(level)
    end

    -- Explicit range "25-30"
    local a, b = string.match(s, "(%d+)%s*%-%s*(%d+)")
    if a and b then
        a, b = tonumber(a), tonumber(b)
        if a and b and a < b and b <= 60 then
            return a, b
        end
    end

    -- "lvl 27", "lv 27"
    level = string.match(s, "lv[le]*%.?%s*(%d+)")
    if level then
        level = tonumber(lvl)
        return GetLevelRange(level)
    end

    -- "any level"
    if string.find(s, "any level") or string.find(s, "any lvl") then
        return 1, 60
    end

    -- Fallback: Use first valid number found (±5 range)
    for num in string.gmatch(s, "%d+") do
        local n = tonumber(num)
        return GetLevelRange(n)
    end

    return 0, 0  -- No valid level found
end

-- ================================================================
-- LEVEL CACHE (passive)
-- Records player levels we observe via friends list, guild roster,
-- party, raid, target, mouseover, and /who results. Used as a fallback
-- when a WTS/WTB message has no explicit level range. Persisted in
-- EmporiumDB.levelCache across sessions. No network traffic generated.
-- ================================================================

local function CacheLevel(name, level)
    if not name or not level or level == 0 then return end
    EmporiumDB.levelCache = EmporiumDB.levelCache or {}
    local cached = EmporiumDB.levelCache[name]
    -- Only overwrite if new level is higher (handles seeing someone level up)
    if not cached or level > cached then
        EmporiumDB.levelCache[name] = level
    end
end

local function GetCachedLevel(name)
    if not EmporiumDB.levelCache then return nil end
    return EmporiumDB.levelCache[name]
end

-- Class cache (parallel to level cache)
-- Stores raw English class token, e.g. "WARRIOR", "PALADIN"
-- EmporiumDB.classCache = { ["PlayerName"] = "CLASSNAME", ... }
local CLASS_COLORS = {
    WARRIOR = "|cffc79c6e",
    PALADIN = "|cfff58cba",
    HUNTER  = "|cffabd473",
    ROGUE   = "|cfffff569",
    PRIEST  = "|cffffffff",
    SHAMAN  = "|cff0070de",
    MAGE    = "|cff69ccf0",
    WARLOCK = "|cff9482c9",
    DRUID   = "|cffff7d0a",
}

local function CacheClass(name, class)
    if not name or not class or class == "" then return end
    EmporiumDB.classCache = EmporiumDB.classCache or {}
    EmporiumDB.classCache[name] = string.upper(class)
end

local function GetCachedClass(name)
    if not EmporiumDB.classCache then return nil end
    return EmporiumDB.classCache[name]
end

local function GetClassColor(class)
    if not class then return nil end
    return CLASS_COLORS[string.upper(class)]
end

local function ScanFriendsLevels()
    for i = 1, GetNumFriends() do
        local name, level, class = GetFriendInfo(i)
        CacheLevel(name, level)
        CacheClass(name, class)
    end
end

local function ScanGuildLevels()
    if not IsInGuild() then return end
    for i = 1, GetNumGuildMembers() do
        local name, _, _, level, class = GetGuildRosterInfo(i)
        CacheLevel(name, level)
        CacheClass(name, class)
    end
end

local function ScanRaidLevels()
    for i = 1, GetNumRaidMembers() do
        local name, _, _, level, class = GetRaidRosterInfo(i)
        CacheLevel(name, level)
        CacheClass(name, class)
    end
end

local function ScanPartyLevels()
    for i = 1, GetNumPartyMembers() do
        local unit = "party"..i
        CacheLevel(UnitName(unit), UnitLevel(unit))
        local _, class = UnitClass(unit)
        CacheClass(UnitName(unit), class)
    end
end

local function ScanTargetLevel()
    if UnitIsPlayer("target") then
        CacheLevel(UnitName("target"), UnitLevel("target"))
        local _, class = UnitClass("target")
        CacheClass(UnitName("target"), class)
    end
end

local function ScanMouseoverLevel()
    if UnitIsPlayer("mouseover") then
        CacheLevel(UnitName("mouseover"), UnitLevel("mouseover"))
        local _, class = UnitClass("mouseover")
        CacheClass(UnitName("mouseover"), class)
    end
end

local function ScanWhoLevels()
    for i = 1, GetNumWhoResults() do
        local name, _, level, _, class = GetWhoInfo(i)
        CacheLevel(name, level)
        CacheClass(name, class)
    end
end

-- ================================================================
-- STORE OFFER
-- ================================================================

local function StoreOffer(sender, msg, rangeMin, rangeMax)
    DEFAULT_CHAT_FRAME:AddMessage("Emporium: <" .. sender .. "> " .. msg .. " [" .. rangeMin .. "-" .. rangeMax .. "]")
end

-- ================================================================
-- CORE MESSAGE PROCESSOR
-- ================================================================
-- Main entry point for processing HC chat messages
-- Flow:
-- 1. Check if message contains WTS/WTB
-- 2. Parse level range from message
-- 3. Store offer to be displayed later

local function ProcessHCMessage(sender, msg)
    -- Ignore non-trade messages
    if not IsTradeMessage(msg) then return end

    local rangeMin, rangeMax = ParseLevelRange(msg)

    -- Fallback: if no level range was found in the message, try to use
    -- the sender's cached level (gathered passively from friends/guild/
    -- party/raid/target/mouseover/who results)
    local usedCachedLevel = false
    if not rangeMin then
        local cachedLevel = GetCachedLevel(sender)
        if cachedLevel then
            rangeMin, rangeMax = GetLevelRange(cachedLevel)
            usedCachedLevel = true
        end
    end

    StoreOffer(sender, msg or msg, rangeMin, rangeMax)
end

-- ================================================================
-- EVENT HANDLERS
-- ================================================================
-- Responds to game events to keep data synchronized:
-- - VARIABLES_LOADED: Load saved settings from WTF folder
-- - PLAYER_ENTERING_WORLD: cache level...
-- - PLAYER_LOGOUT: Save item color cache to disk

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("FRIENDLIST_UPDATE")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventFrame:RegisterEvent("WHO_LIST_UPDATE")
eventFrame:RegisterEvent("CHAT_MSG_SAY")
eventFrame:RegisterEvent("CHAT_MSG_GUILD")
eventFrame:RegisterEvent("CHAT_MSG_CHANNEL")
eventFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        -- Load all saved settings from EmporiumDB (SavedVariables)
        if EmporiumDB.guildEnabled ~= nil then guildEnabled = EmporiumDB.guildEnabled end
                    
        -- Initialize level cache (passive sender level tracking)
        EmporiumDB.levelCache = EmporiumDB.levelCache or {}
        EmporiumDB.classCache = EmporiumDB.classCache or {}
    end
    
    if event == "PLAYER_ENTERING_WORLD" then
        -- Seed level cache with what we already know
        CacheLevel(UnitName("player"), UnitLevel("player"))
        local _, playerClass = UnitClass("player")
        CacheClass(UnitName("player"), playerClass)
        ScanFriendsLevels()
        ScanGuildLevels()
        ScanPartyLevels()
        ScanRaidLevels()
    end

    -- Level cache events (passive, no network traffic)
    if event == "FRIENDLIST_UPDATE" then
        ScanFriendsLevels()
    end
    if event == "GUILD_ROSTER_UPDATE" then
        ScanGuildLevels()
    end
    if event == "RAID_ROSTER_UPDATE" then
        ScanRaidLevels()
    end
    if event == "PARTY_MEMBERS_CHANGED" then
        ScanPartyLevels()
    end
    if event == "PLAYER_TARGET_CHANGED" then
        ScanTargetLevel()
    end
    if event == "UPDATE_MOUSEOVER_UNIT" then
        ScanMouseoverLevel()
    end
    if event == "WHO_LIST_UPDATE" then
        ScanWhoLevels()
    end
    if event == "CHAT_MSG_GUILD" or event == "CHAT_MSG_SAY" then
        -- arg1 = message body, arg2 = sender name (no [G]/<lvl:name> prefix on raw event)
        if guildEnabled and arg1 and arg2 then
            ProcessHCMessage(arg2, arg1)
        end
    end
    if event == "CHAT_MSG_CHANNEL" then
        -- arg1 = message body, arg2 = sender name (no [G]/<lvl:name> prefix on raw event), arg4 = channel name
        if string.find(arg4, "World") then
            ProcessHCMessage(arg2, arg1)
        end
    end
end)

-- ================================================================
-- SLASH COMMANDS
-- ================================================================
-- Command interface for users to control the addon
-- Main commands:
-- /emporium or /emporium menu - Open settings GUI
-- /emporium debug - Toggle debug output
-- /emporium help [command] - Show help


SLASH_EMPORIUM1 = "/emporium"
SlashCmdList["EMPORIUM"] = function(msg)
    local cmd = string.lower(string.gsub(msg or "", "^%s*(.-)%s*$", "%1"))

    if cmd == "debug" then
        -- Toggle debug mode: prints detailed message processing info
        debugMode = not debugMode
        local state = debugMode and "|cff00cc00ON|r" or "|cffff4444OFF|r"
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Emporium:|r Debug " .. state)

    elseif cmd == "cache" then
        local count = 0
        if EmporiumDB.levelCache then
            for _ in pairs(EmporiumDB.levelCache) do count = count + 1 end
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Emporium:|r Level cache: |cffffffff" .. count .. "|r player(s) tracked.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa(use |cffffffff/emporium cache clear|r|cffaaaaaa to wipe)")

    elseif cmd == "cache clear" then
        EmporiumDB.levelCache = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Emporium:|r Level cache cleared.")

    elseif cmd == "help" or cmd == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Emporium:|r To get help, type |cffffffff/emporium help |cff00ffff<command>|r for details.")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Emporium:|r Example: |cffffffff/emporium help |cff00ffffstatus|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Emporium:|r List of commands:")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffffff/emporium    |cffffffff/emporium |cff00ffffcache|r    |cffffffff/emporium |cff00ffffon|r/|cff00ffffoff|r")

    elseif string.sub(cmd, 1, 5) == "help " then
        local topic = string.gsub(cmd, "^help%s+", "")
        local G = "|cffffd100"
        if topic == "debug" then
            DEFAULT_CHAT_FRAME:AddMessage(G .. "debug|r - Toggles debug mode.")
            DEFAULT_CHAT_FRAME:AddMessage("  When ON, every HC WTS/WTB is printed with its parsed level range")
            DEFAULT_CHAT_FRAME:AddMessage("  and whether it matched your level. Good for testing the parser.")
        elseif topic == "cache" then
            DEFAULT_CHAT_FRAME:AddMessage(G .. "cache|r - Shows how many players are in the level cache.")
            DEFAULT_CHAT_FRAME:AddMessage("  Emporium passively records levels from friends, guild, party,")
            DEFAULT_CHAT_FRAME:AddMessage("  raid, target, mouseover, and /who results. These are used as")
            DEFAULT_CHAT_FRAME:AddMessage("  a fallback when a WTS/WTB has no level in the message.")
            DEFAULT_CHAT_FRAME:AddMessage("  Use |cffffffff/emporium cache clear|r to wipe the cache.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444Emporium:|r Unknown command '" .. topic .. "'. Type /emporium help for a list.")
        end

    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444Emporium:|r Unknown command. Type |cffffffff/emporium help|r for a list.")
    end
end

-- ================================================================
-- ADDON LOADED
-- ================================================================
-- Print confirmation message when addon loads successfully

DEFAULT_CHAT_FRAME:AddMessage("|cffffd100Emporium:|r Loaded. Type |cffffffff/emporium help|r for commands.")

-- SAVED VARIABLES (stored in WTF/Account/ACCOUNT/SavedVariables/Emporium.lua):
-- EmporiumDB.levelCache
-- EmporiumDB.classCache