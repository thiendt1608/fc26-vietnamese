-- lua/dump_all_players.lua
-- Script dump 100% TOÀN BỘ cầu thủ trong game database (không qua bất kỳ bộ lọc nào)
-- Đồng thời quét trực tiếp tìm "Pendant", "Quang Vinh" hoặc bất kỳ cầu thủ Việt kiều nào

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function escape_json(s)
    if s == nil then return '""' end
    return '"' .. tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r') .. '"'
end

local function escape_csv(s)
    if s == nil then return '""' end
    local str = tostring(s):gsub('"', '""')
    return '"' .. str .. '"'
end

local function dump_all()
    print("[Dump All] Dang doc toan bo bang 'players' tu RAM...")
    local rows = safe_call(GetDBTableRows, "players")
    if not rows then
        print("[Dump All] ERROR: Khong the lay bang 'players'!")
        return
    end

    local total = #rows
    print(string.format("[Dump All] Tong so records trong bang 'players': %d", total))

    local players = {}
    local targets_found = {}
    local search_terms = {"pendant", "quang vinh", "quang-vinh", "jason"}

    for i = 1, total do
        local p = rows[i]
        local pid = (p.playerid and p.playerid.value) and math.floor(tonumber(p.playerid.value) or 0) or 0

        if pid > 0 then
            local pname = safe_call(GetPlayerName, pid) or ""
            local teamid = safe_call(GetTeamIdFromPlayerId, pid) or -1
            teamid = math.floor(tonumber(teamid) or -1)
            local teamname = (teamid > 0 and safe_call(GetTeamName, teamid)) or "Free Agents"

            local nat_id = (p.nationality and p.nationality.value) and math.floor(tonumber(p.nationality.value) or -1) or -1
            local ovr = (p.overallrating and p.overallrating.value) and math.floor(tonumber(p.overallrating.value) or 0) or 0
            local pot = (p.potential and p.potential.value) and math.floor(tonumber(p.potential.value) or 0) or 0
            local pos = (p.preferredposition1 and p.preferredposition1.value) and math.floor(tonumber(p.preferredposition1.value) or 0) or 0

            -- Kiem tra truc tiep xem co phai cau thu can tim khong
            local low_name = string.lower(pname)
            for _, term in ipairs(search_terms) do
                if string.find(low_name, term, 1, true) then
                    table.insert(targets_found, string.format("TIM THAY: ID %d | %s | Doi: %s | QG: %d | OVR: %d", pid, pname, teamname, nat_id, ovr))
                    break
                end
            end

            table.insert(players, {
                playerid = pid,
                name = pname,
                teamid = teamid,
                teamname = teamname,
                nationality = nat_id,
                overallrating = ovr,
                potential = pot,
                preferredposition1 = pos
            })
        end
    end

    print(string.format("[Dump All] Da doc xong %d cau thu hop le.", #players))

    -- In ket qua tim kiem truc tiep ra man hinh console
    if #targets_found > 0 then
        print("================ KET QUA TIM KIEM MUC TIEU ================")
        for _, t in ipairs(targets_found) do
            print(t)
        end
        print("===========================================================")
    else
        print("[Dump All] Khong thay cau thu nao co chu 'pendant', 'quang vinh' trong ten.")
    end

    -- Xuat file CSV (nhe, de tra cuu bang Excel)
    local csv_lines = {"playerid,name,teamid,teamname,nationality,overallrating,potential,preferredposition1"}
    for _, p in ipairs(players) do
        table.insert(csv_lines, string.format("%d,%s,%d,%s,%d,%d,%d,%d",
            p.playerid, escape_csv(p.name), p.teamid, escape_csv(p.teamname),
            p.nationality, p.overallrating, p.potential, p.preferredposition1))
    end
    local csv_content = table.concat(csv_lines, "\n")

    -- Xuat file JSON (cho Python/Agent doc)
    local json_lines = {"["}
    for idx, p in ipairs(players) do
        local line = string.format('  {"playerid": %d, "name": %s, "teamid": %d, "teamname": %s, "nationality": %d, "overallrating": %d, "potential": %d, "preferredposition1": %d}',
            p.playerid, escape_json(p.name), p.teamid, escape_json(p.teamname),
            p.nationality, p.overallrating, p.potential, p.preferredposition1)
        if idx < #players then
            line = line .. ","
        end
        table.insert(json_lines, line)
    end
    table.insert(json_lines, "]")
    local json_content = table.concat(json_lines, "\n")

    -- Ghi file ra C:/FC 26 Live Editor/
    local f_csv = io.open("C:/FC 26 Live Editor/all_players_full.csv", "w")
    if f_csv then
        f_csv:write(csv_content)
        f_csv:close()
        print("[Dump All] Da luu CSV: C:/FC 26 Live Editor/all_players_full.csv")
    end

    local f_json = io.open("C:/FC 26 Live Editor/all_players_full.json", "w")
    if f_json then
        f_json:write(json_content)
        f_json:close()
        print("[Dump All] Da luu JSON: C:/FC 26 Live Editor/all_players_full.json")
    end

    -- Copy vao thu muc data cua tool
    local f_data = io.open("data/all_players_full.json", "w")
    if f_data then
        f_data:write(json_content)
        f_data:close()
    end
end

dump_all()
