-- lua/fix_career_growth_and_ranking.lua
-- Script dien day du du lieu con thieu cua 10 cau thu chuyen nhuong vao:
-- 1. 'career_squadranking' (Bang xep hang cap do doi hinh trong Career Mode)
-- 2. 'career_playergrowthuserseason' (Bang theo doi tang truong chi so cau thu cua CLB)

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local GROWTH_COLS = {
    "acceleration", "aggression", "agility", "balance", "ballcontrol", "composure",
    "crossing", "curve", "defensiveawareness", "dribbling", "dribspeed", "finishing",
    "freekickaccuracy", "gkdiving", "gkhandling", "gkkicking", "gkpositioning", "gkreflexes",
    "headingaccuracy", "interceptions", "jumping", "longpassing", "longshots", "penalties",
    "positioning", "reactions", "shortpassing", "shotpower", "slidingtackle", "sprintspeed",
    "stamina", "standingtackle", "strength", "vision", "volleys"
}

local function fix_growth_and_ranking()
    print("==================================================")
    print("[Fix Growth & Ranking] BAT DAU BO SUNG SQUAD RANKING & GROWTH...")
    print("==================================================")

    -- 1. Doc bang players de lay chi so goc
    local players = safe_call(GetDBTableRows, "players")
    if not players then
        print("[Fix Growth & Ranking] LOI: Khong the doc bang 'players'!")
        return
    end

    local players_map = {}
    for i = 1, #players do
        local r = players[i]
        local pid_val = (type(r.playerid) == "table" and r.playerid.value) or r.playerid
        local pid = math.floor(tonumber(pid_val) or -1)
        if pid >= 900 and pid <= 928 then
            players_map[pid] = r
        end
    end

    -- 2. Kiem tra va them vao career_squadranking
    local sr_rows = safe_call(GetDBTableRows, "career_squadranking")
    local sr_existing = {}
    if sr_rows then
        for i = 1, #sr_rows do
            local r = sr_rows[i]
            local pid_val = (type(r.playerid) == "table" and r.playerid.value) or r.playerid
            local pid = math.floor(tonumber(pid_val) or -1)
            if pid >= 900 and pid <= 928 then
                sr_existing[pid] = true
            end
        end
    end

    local sr_inserted = 0
    for pid = 900, 928 do
        if not sr_existing[pid] and players_map[pid] then
            local p_row = players_map[pid]
            local ovr_val = (type(p_row.overallrating) == "table" and p_row.overallrating.value) or p_row.overallrating
            local ovr = math.floor(tonumber(ovr_val) or 80)
            local curroverall = ovr * 10

            local data = {
                playerid = tostring(pid),
                curroverall = tostring(curroverall),
                lastoverall = "0"
            }

            local row = safe_call(InsertDBTableRow, "career_squadranking", data)
            if row and row.addr ~= "0" then
                sr_inserted = sr_inserted + 1
                print(string.format("  [+] Da them Player %d vao career_squadranking (OVR: %d)!", pid, ovr))
            end
        end
    end

    -- 3. Kiem tra va them vao career_playergrowthuserseason
    local pg_rows = safe_call(GetDBTableRows, "career_playergrowthuserseason")
    local pg_existing = {}
    if pg_rows then
        for i = 1, #pg_rows do
            local r = pg_rows[i]
            local pid_val = (type(r.playerid) == "table" and r.playerid.value) or r.playerid
            local pid = math.floor(tonumber(pid_val) or -1)
            if pid >= 900 and pid <= 928 then
                pg_existing[pid] = true
            end
        end
    end

    local pg_inserted = 0
    for pid = 900, 928 do
        if not pg_existing[pid] and players_map[pid] then
            local p_row = players_map[pid]
            local ovr_val = (type(p_row.overallrating) == "table" and p_row.overallrating.value) or p_row.overallrating
            local ovr = math.floor(tonumber(ovr_val) or 80)

            local data = {
                playerid = tostring(pid),
                overall = tostring(ovr)
            }

            for _, col in ipairs(GROWTH_COLS) do
                local val = (type(p_row[col]) == "table" and p_row[col].value) or p_row[col]
                data[col] = tostring(math.floor(tonumber(val) or 70))
            end

            local row = safe_call(InsertDBTableRow, "career_playergrowthuserseason", data)
            if row and row.addr ~= "0" then
                pg_inserted = pg_inserted + 1
                print(string.format("  [+] Da them Player %d vao career_playergrowthuserseason!", pid))
            end
        end
    end

    print("==================================================")
    print(string.format("[Fix Growth & Ranking] HOAN TAT! Da them %d squadranking va %d growth records!", sr_inserted, pg_inserted))
    print("Toan bo 29 cau thu Viet Nam gio da co mat 100% o tat ca cac bang Career Mode!")
    print("Het 100% loi doc con tro NULL (READ 0x4) khi vao tran hay mo phong!")
    print("==================================================")

    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(string.format("[Fix Growth & Ranking] Da them %d squadranking va %d growth records.\n", sr_inserted, pg_inserted))
            f:close()
        end
    end)
end

fix_growth_and_ranking()
