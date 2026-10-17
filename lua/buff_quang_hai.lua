-- lua/buff_quang_hai.lua
-- Buff rieng Quang Hai (903) ve chu so chuan C1 (giong trong buff_vietnam_squad.lua).
-- Chay truc tiep trong Lua Engine cua Live Editor.

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function safe_edit(field, val)
    if field and field.value ~= nil then
        field.value = tostring(val)
        if type(EditDBTableField) == "function" then
            EditDBTableField(field)
        end
    end
end

local QUANG_HAI = {
    overallrating = 82, potential = 85,
    preferredposition1 = 18, preferredposition2 = 23, preferredposition3 = 27,
    preferredfoot = 2, weakfootabilitytypecode = 3, skillmoves = 4,
    height = 168, weight = 67,
    acceleration = 81, sprintspeed = 78,
    positioning = 82, finishing = 82, shotpower = 84,
    longshots = 86, volleys = 80, penalties = 80,
    vision = 86, crossing = 84, freekickaccuracy = 88,
    shortpassing = 85, longpassing = 83, curve = 88,
    agility = 87, balance = 88, reactions = 83,
    ballcontrol = 86, dribbling = 85, composure = 85,
    interceptions = 52, headingaccuracy = 58, defensiveawareness = 48,
    standingtackle = 52, slidingtackle = 48,
    jumping = 76, stamina = 82, strength = 70, aggression = 72,
    gkdiving = 10, gkhandling = 10, gkkicking = 10,
    gkpositioning = 10, gkreflexes = 10,
}

local function buff_quang_hai()
    local rows = type(GetDBTableRows) == "function" and GetDBTableRows("players") or nil
    if not rows then
        print("[Buff Quang Hai] ERROR: Khong lay duoc bang 'players' tu RAM!")
        return
    end

    for i = 1, #rows do
        local p = rows[i]
        local pid = p.playerid and math.floor(tonumber(p.playerid.value) or 0) or 0
        if pid == 903 then
            local applied = 0
            for field, val in pairs(QUANG_HAI) do
                if p[field] then
                    safe_edit(p[field], val)
                    applied = applied + 1
                end
            end
            local msg = string.format("[Buff Quang Hai] Da buff thanh cong %d field cho Quang Hai (903)!", applied)
            print(msg)
            pcall(function()
                local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
                if f then
                    f:write(msg .. "\n")
                    f:close()
                end
            end)
            return
        end
    end
    print("[Buff Quang Hai] ERROR: Khong tim thay player 903!")
end

buff_quang_hai()
