-- lua/dump_full_database.lua
-- Script dump toan bo database tu FC Live Editor ra thu muc C:/FC 26 Live Editor/db_dump/
-- Giup phan tich chuyen sau moi quan he giua teamplayerlinks, career_playercontract, default_teamsheets, players, teams

local DUMP_DIR = "C:/FC 26 Live Editor/db_dump/"

local PRIORITY_TABLES = {
    "teamplayerlinks",
    "career_playercontract",
    "default_teamsheets",
    "career_users",
    "career_presignedcontract",
    "playerloans",
    "players",
    "teams",
    "leagueteamlinks",
    "leagues",
    "formations",
    "squad"
}

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function escape_json(s)
    if s == nil then return '""' end
    local str = tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t')
    return '"' .. str .. '"'
end

local function val_to_json(val)
    if val == nil then return 'null' end
    local s = tostring(val)
    if tonumber(s) and not s:find("^0%d") then
        return s
    end
    return escape_json(s)
end

local function row_to_json(row)
    local parts = {}
    local keys = {}
    for k in pairs(row) do table.insert(keys, k) end
    table.sort(keys)
    for _, col in ipairs(keys) do
        local field = row[col]
        local val = (type(field) == "table" and field.value ~= nil) and field.value or field
        table.insert(parts, string.format('"%s": %s', col, val_to_json(val)))
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

local function write_json_file(filename, content)
    local f = io.open(DUMP_DIR .. filename, "w")
    if f then
        f:write(content)
        f:close()
        return true
    end
    return false
end

local function dump_table_to_file(tbl_name, rows)
    local lines = {"[\n"}
    local total = #rows
    for i = 1, total do
        local comma = (i < total) and ",\n" or "\n"
        table.insert(lines, "  " .. row_to_json(rows[i]) .. comma)
    end
    table.insert(lines, "]")
    return write_json_file(tbl_name .. ".json", table.concat(lines))
end

local function dump_full_db()
    print("==================================================")
    print("[Dump DB] BAT DAU DUMP FULL DATABASE TU RAM...")
    print("==================================================")

    local bInCM = safe_call(IsInCM) or false
    local user_team_id = bInCM and safe_call(GetUserTeamID) or -1
    user_team_id = user_team_id and math.floor(tonumber(user_team_id) or -1) or -1
    local user_team_name = (user_team_id > 0 and safe_call(GetTeamName, user_team_id)) or ""

    print(string.format("[Dump DB] Che do: %s | User Team ID: %d (%s)",
        bInCM and "Career Mode" or "Main Menu", user_team_id, user_team_name))

    -- 1. Lay danh sach tat ca bang tu Live Editor
    local table_names = safe_call(GetDBTableNames)
    local final_tables = {}
    local seen_tables = {}

    if table_names and type(table_names) == "table" and #table_names > 0 then
        print(string.format("[Dump DB] GetDBTableNames() tra ve %d bang.", #table_names))
        for _, name in ipairs(table_names) do
            if not seen_tables[name] then
                table.insert(final_tables, name)
                seen_tables[name] = true
            end
        end
    end

    -- Bo sung cac priority tables neu chua co
    for _, name in ipairs(PRIORITY_TABLES) do
        if not seen_tables[name] then
            table.insert(final_tables, name)
            seen_tables[name] = true
        end
    end

    local summary = {
        is_cm = bInCM,
        user_team_id = user_team_id,
        user_team_name = user_team_name,
        tables = {}
    }

    local success_count = 0

    -- 2. Dump tung bang
    for idx, tbl in ipairs(final_tables) do
        local rows = safe_call(GetDBTableRows, tbl)
        if rows and type(rows) == "table" then
            local n = #rows
            print(string.format("  [%d/%d] Dang dump bang '%s' (%d rows)...", idx, #final_tables, tbl, n))
            
            -- Ghi file json cho bang nay
            dump_table_to_file(tbl, rows)
            summary.tables[tbl] = n
            success_count = success_count + 1

            -- Xu ly rieng bang teamplayerlinks: tao them file focus dac biet
            if tbl == "teamplayerlinks" then
                local focus_rows = {}
                for i = 1, n do
                    local r = rows[i]
                    local pid = (r.playerid and r.playerid.value) and math.floor(tonumber(r.playerid.value) or 0) or 0
                    local tid = (r.teamid and r.teamid.value) and math.floor(tonumber(r.teamid.value) or 0) or 0
                    -- Loc cac cau thu VN (900-928), Binh Tan FC (115486), Barca (241), hoac doi cua ban
                    if (pid >= 900 and pid <= 928) or tid == 115486 or tid == 241 or (user_team_id > 0 and tid == user_team_id) then
                        table.insert(focus_rows, r)
                    end
                end
                dump_table_to_file("teamplayerlinks_focus", focus_rows)
                print(string.format("    -> Da xuat teamplayerlinks_focus.json (%d rows lien quan VN/Binh Tan/Barca)", #focus_rows))
            end

            -- Xu ly rieng bang players: tao them file focus dac biet cho VN
            if tbl == "players" then
                local vn_players = {}
                for i = 1, n do
                    local r = rows[i]
                    local pid = (r.playerid and r.playerid.value) and math.floor(tonumber(r.playerid.value) or 0) or 0
                    if pid >= 900 and pid <= 928 then
                        table.insert(vn_players, r)
                    end
                end
                dump_table_to_file("players_vn_focus", vn_players)
                print(string.format("    -> Da xuat players_vn_focus.json (%d cau thu VN)", #vn_players))
            end
        else
            summary.tables[tbl] = "NOT_FOUND_OR_NIL"
        end
    end

    -- 3. Ghi file summary.json
    local sum_lines = {"{\n"}
    table.insert(sum_lines, string.format('  "is_cm": %s,\n', tostring(summary.is_cm)))
    table.insert(sum_lines, string.format('  "user_team_id": %d,\n', summary.user_team_id))
    table.insert(sum_lines, string.format('  "user_team_name": %s,\n', escape_json(summary.user_team_name)))
    table.insert(sum_lines, '  "tables": {\n')
    local t_keys = {}
    for k in pairs(summary.tables) do table.insert(t_keys, k) end
    table.sort(t_keys)
    for i, k in ipairs(t_keys) do
        local comma = (i < #t_keys) and ",\n" or "\n"
        local v = summary.tables[k]
        local v_str = (type(v) == "number") and tostring(v) or escape_json(tostring(v))
        table.insert(sum_lines, string.format('    "%s": %s%s', k, v_str, comma))
    end
    table.insert(sum_lines, "  }\n}")
    write_json_file("summary.json", table.concat(sum_lines))

    local msg = string.format("[Dump DB] HOAN TAT! Da dump %d bang thanh cong vao thu muc: %s", success_count, DUMP_DIR)
    print("==================================================")
    print(msg)
    print("==================================================")

    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(msg .. "\n")
            f:close()
        end
    end)
end

dump_full_db()
