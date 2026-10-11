-- lua/export_vn_players.lua
-- Script xuất danh sách & chỉ số cầu thủ Việt Nam từ FC Live Editor ra file JSON
-- Chạy script này trong Live Editor (Lua Engine) khi đang ở Career Mode hoặc Menu chính

local ATTR_FIELDS = {
    "overallrating", "potential", "preferredposition1",
    -- Pace (Tốc độ)
    "acceleration", "sprintspeed",
    -- Shooting (Dứt điểm)
    "positioning", "finishing", "shotpower", "longshots", "volleys", "penalties",
    -- Passing (Chuyền bóng)
    "vision", "crossing", "freekickaccuracy", "shortpassing", "longpassing", "curve",
    -- Dribbling (Rê bóng & Khéo léo)
    "agility", "balance", "reactions", "ballcontrol", "dribbling", "composure",
    -- Defending (Phòng ngự)
    "interceptions", "headingaccuracy", "defensiveawareness", "standingtackle", "slidingtackle",
    -- Physical (Thể lực & Sức mạnh)
    "jumping", "stamina", "strength", "aggression",
    -- Goalkeeper (Thủ môn)
    "gkdiving", "gkhandling", "gkkicking", "gkpositioning", "gkreflexes"
}

local VN_SURNAMES = {
    "nguyen", "tran", "le", "pham", "hoang", "huynh", "vu", "vo", "phan", "truong",
    "bui", "dang", "do", "ngo", "duong", "dinh", "doan", "lam", "mai", "tien linh",
    "van toan", "quang hai", "hoang duc", "tuan hai", "viet anh", "ngoc hai", "van lam",
    "cong phuong", "tuan anh", "xuan truong", "tan tai", "van thanh", "thanh chung", "filip"
}

local VN_CLUBS = {
    "vietnam", "việt nam", "v-league", "vleague", "v league", "ha noi", "hanoi", "viettel",
    "cahn", "nam dinh", "the cong", "hai phong", "binh duong", "slna", "hagl", "da nang",
    "thanh hoa", "tphcm", "tp hcm", "tp.hcm", "song lam", "binh dinh", "ha tinh", "quang nam",
    "khanh hoa", "binh phuoc", "ninh binh", "pvf", "ba ria", "vung tau", "long an", "dong thap", "hue"
}

local function escape_json(s)
    if s == nil then return '""' end
    return '"' .. tostring(s):gsub('\\\\', '\\\\\\\\'):gsub('"', '\\\\"'):gsub('\\n', '\\\\n'):gsub('\\r', '\\\\r') .. '"'
end

local function is_vn_name(name)
    if not name or name == "" then return false end
    local lower = string.lower(name)
    for _, s in ipairs(VN_SURNAMES) do
        if string.find(lower, s, 1, true) then return true end
    end
    return false
end

local function is_vn_team(teamname)
    if not teamname or teamname == "" then return false end
    local lower = string.lower(teamname)
    for _, c in ipairs(VN_CLUBS) do
        if string.find(lower, c, 1, true) then return true end
    end
    return false
end
local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function export_vn_players()
    local bInCM = safe_call(IsInCM) or false
    local user_team_id = bInCM and safe_call(GetUserTeamID) or -1
    user_team_id = user_team_id and math.floor(tonumber(user_team_id) or -1) or -1
    local user_team_name = (user_team_id > 0 and safe_call(GetTeamName, user_team_id)) or ""

    print(string.format("[Export VN] Career Mode: %s | User Team ID: %d (%s)",
        tostring(bInCM), user_team_id, tostring(user_team_name)))

    local rows = safe_call(GetDBTableRows, "players")
    if not rows then
        print("[Export VN] ERROR: Khong the lay du lieu bang 'players'!")
        return
    end
    -- PASS 1: Xac dinh tat ca cac doi bong thuoc he thong Viet Nam (V-League, Hang Nhat, DTQG)
    local team_vn_player_count = {}
    local is_vn_club = {}

    if user_team_id > 0 then
        is_vn_club[user_team_id] = true
    end

    for i = 1, #rows do
        local p = rows[i]
        local pid = (p.playerid and p.playerid.value) and math.floor(tonumber(p.playerid.value) or 0) or 0
        if pid > 0 then
            local teamid = safe_call(GetTeamIdFromPlayerId, pid) or -1
            teamid = math.floor(tonumber(teamid) or -1)

            if teamid > 0 then
                local teamname = safe_call(GetTeamName, teamid) or ""
                if is_vn_team(teamname) then
                    is_vn_club[teamid] = true
                end

                local pname = safe_call(GetPlayerName, pid) or ""
                local nat_id = (p.nationality and p.nationality.value) and math.floor(tonumber(p.nationality.value) or -1) or -1
                if nat_id == 166 or is_vn_name(pname) then
                    team_vn_player_count[teamid] = (team_vn_player_count[teamid] or 0) + 1
                end
            end
        end
    end

    -- Neu mot doi co >= 3 cau thu goc Viet thi chac chan la CLB Viet Nam (V-League)
    for tid, count in pairs(team_vn_player_count) do
        if count >= 3 then
            is_vn_club[tid] = true
        end
    end

    -- PASS 2: Gom tat ca cau thu (bao gom ca ngoai binh V-League nhu Rafaelson, Hendrio...)
    local exported = {}
    local seen_ids = {}

    for i = 1, #rows do
        local p = rows[i]
        local pid = (p.playerid and p.playerid.value) and math.floor(tonumber(p.playerid.value) or 0) or 0

        if pid > 0 and not seen_ids[pid] then
            local teamid = safe_call(GetTeamIdFromPlayerId, pid) or -1
            teamid = math.floor(tonumber(teamid) or -1)
            local teamname = (teamid > 0 and safe_call(GetTeamName, teamid)) or ""

            local pname = safe_call(GetPlayerName, pid) or ""
            local nat_id = (p.nationality and p.nationality.value) and math.floor(tonumber(p.nationality.value) or -1) or -1
            local is_vietnamese = (nat_id == 166) or is_vn_name(pname)
            local in_vn_team = (teamid > 0 and is_vn_club[teamid]) or false

            local match_reason = nil
            local player_type = nil

            if in_vn_team then
                if is_vietnamese then
                    match_reason = "vleague_domestic"
                    player_type = "Noi binh V-League"
                else
                    match_reason = "vleague_foreign"
                    player_type = "Ngoai binh V-League"
                end
            elseif is_vietnamese then
                match_reason = "vn_abroad"
                player_type = "Cau thu Viet thi dau nuoc ngoai"
            elseif user_team_id > 0 and teamid == user_team_id then
                match_reason = "user_team"
                player_type = "Cau thu doi cua ban"
            end

            if match_reason then
                seen_ids[pid] = true
                local item = {
                    playerid = pid,
                    name = pname,
                    teamid = teamid,
                    teamname = teamname,
                    nationality = nat_id,
                    match_reason = match_reason,
                    player_type = player_type
                }

                for _, attr in ipairs(ATTR_FIELDS) do
                    if p[attr] then
                        item[attr] = math.floor(tonumber(p[attr].value) or 0)
                    else
                        item[attr] = 0
                    end
                end

                table.insert(exported, item)
            end
        end
    end

    -- Xay dung noi dung JSON
    local json_lines = {"["}
    for idx, item in ipairs(exported) do
        local parts = {
            string.format('"playerid": %d', item.playerid),
            string.format('"name": %s', escape_json(item.name)),
            string.format('"teamid": %d', item.teamid),
            string.format('"teamname": %s', escape_json(item.teamname)),
            string.format('"nationality": %d', item.nationality),
            string.format('"match_reason": %s', escape_json(item.match_reason)),
            string.format('"player_type": %s', escape_json(item.player_type))
        }
        for _, attr in ipairs(ATTR_FIELDS) do
            table.insert(parts, string.format('"%s": %d', attr, item[attr] or 0))
        end
        local line = "  {" .. table.concat(parts, ", ") .. "}"
        if idx < #exported then
            line = line .. ","
        end
        table.insert(json_lines, line)
    end
    table.insert(json_lines, "]")
    local json_content = table.concat(json_lines, "\n")

    -- Ghi file
    local paths = {
        "C:/FC 26 Live Editor/vn_players_raw.json",
        "data/vn_players_raw.json"
    }

    local saved = false
    for _, path in ipairs(paths) do
        local f = io.open(path, "w")
        if f then
            f:write(json_content)
            f:close()
            print(string.format("[Export VN] Da xuat thanh cong %d cau thu vao: %s", #exported, path))
            saved = true
        end
    end

    if not saved then
        print(string.format("[Export VN] CANH BAO: Khong mo duoc file ghi! Tong so cau thu tim thay: %d", #exported))
    end
end

export_vn_players()
