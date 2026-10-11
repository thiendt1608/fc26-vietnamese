-- lua/dump_all_tables_and_fk_analysis.lua
-- Script dump TOAN BO 201 BANG database cua FC 26
-- Dong thoi quet va phan tich toan bo Khoa Ngoai (Foreign Keys) lien quan den Binh Tan FC (115486) va 29 cau thu VN (900-928)

local BASE_DIR = "C:/FC 26 Live Editor/db_dump/"
local ALL_TABLES_DIR = BASE_DIR .. "all_tables/"
local FK_DIR = BASE_DIR .. "fk_matches/"

local TARGET_TEAM_ID = 115486    -- Binh Tan FC
local TARGET_NT_ID = 111527      -- DTQG Viet Nam
local TARGET_PIDS_MIN = 900
local TARGET_PIDS_MAX = 928

local KNOWN_TABLES_FALLBACK = {
    "players", "teams", "teamplayerlinks", "teamsheets", "default_teamsheets",
    "formations", "formationassignments", "career_playercontract", "career_users",
    "career_presignedcontract", "playerloans", "leagueteamlinks", "leagues",
    "stadiums", "teamstadiumlinks", "squad", "career_playergrowth",
    "career_managerhistory", "career_calendar", "career_compobj", "career_leaguestanding",
    "career_scout", "rivals", "derbies", "rivalteams", "teamkits", "referees",
    "default_mentalities", "tactic", "tactics", "customteamtactic", "playernames",
    "editedplayernames", "career_youthplayers", "career_transferoffer", "transfers"
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

local function write_file(path, content)
    local f = io.open(path, "w")
    if f then
        f:write(content)
        f:close()
        return true
    end
    return false
end

local function dump_rows_to_json(filepath, rows)
    local lines = {"[\n"}
    local total = #rows
    for i = 1, total do
        local comma = (i < total) and ",\n" or "\n"
        table.insert(lines, "  " .. row_to_json(rows[i]) .. comma)
    end
    table.insert(lines, "]")
    return write_file(filepath, table.concat(lines))
end

local function run_deep_dump_and_fk_analysis()
    print("==================================================")
    print("[FK Analysis] BAT DAU QUET FULL DATABASE & KHOA NGOAI...")
    print("==================================================")

    -- 1. Thu thap tat ca ten bang
    local table_names_map = {}
    local ordered_tables = {}

    local meta = safe_call(GetDBMeta)
    if meta and type(meta.shortname_name_tables_map) == "table" then
        print("[FK Analysis] Lay duoc metadata tu GetDBMeta()!")
        for shortname, realname in pairs(meta.shortname_name_tables_map) do
            if realname and realname ~= "" and not table_names_map[realname] then
                table_names_map[realname] = true
                table.insert(ordered_tables, realname)
            end
        end
    end

    local db_names = safe_call(GetDBTableNames)
    if db_names and type(db_names) == "table" then
        for _, realname in ipairs(db_names) do
            if realname and realname ~= "" and not table_names_map[realname] then
                table_names_map[realname] = true
                table.insert(ordered_tables, realname)
            end
        end
    end

    for _, realname in ipairs(KNOWN_TABLES_FALLBACK) do
        if not table_names_map[realname] then
            table_names_map[realname] = true
            table.insert(ordered_tables, realname)
        end
    end

    table.sort(ordered_tables)
    print(string.format("[FK Analysis] Tong so ten bang can kiem tra: %d bang.", #ordered_tables))

    local fk_report = {
        scan_time = os.date("%Y-%m-%d %H:%M:%S"),
        target_team_id = TARGET_TEAM_ID,
        target_nt_id = TARGET_NT_ID,
        matching_tables = {},
        total_tables_checked = #ordered_tables,
        valid_tables_found = 0
    }

    local valid_tables_count = 0
    local fk_matched_tables_count = 0

    -- 2. Quet tung bang
    for idx, tbl in ipairs(ordered_tables) do
        local rows = safe_call(GetDBTableRows, tbl)
        if rows and type(rows) == "table" and #rows > 0 then
            valid_tables_count = valid_tables_count + 1
            local n = #rows

            -- Luu file JSON cho cac bang nho hoac bang quan trong
            if n <= 10000 or tbl == "teamplayerlinks" or tbl:find("career_") or tbl:find("teamsheet") or tbl:find("tactic") then
                dump_rows_to_json(ALL_TABLES_DIR .. tbl .. ".json", rows)
            end

            -- Quet Khoa Ngoai (Foreign Key)
            local matched_rows = {}
            local matched_columns = {}

            for i = 1, n do
                local r = rows[i]
                local is_matched = false
                local hit_col = nil

                for col, field in pairs(r) do
                    local val = (type(field) == "table" and field.value ~= nil) and field.value or field
                    local num = math.floor(tonumber(val) or -999999)

                    if num == TARGET_TEAM_ID or num == TARGET_NT_ID or (num >= TARGET_PIDS_MIN and num <= TARGET_PIDS_MAX) then
                        is_matched = true
                        hit_col = col
                        matched_columns[col] = (matched_columns[col] or 0) + 1
                    end
                end

                if is_matched then
                    table.insert(matched_rows, r)
                end
            end

            if #matched_rows > 0 then
                fk_matched_tables_count = fk_matched_tables_count + 1
                dump_rows_to_json(FK_DIR .. tbl .. ".json", matched_rows)
                
                local col_summary = {}
                for col, hits in pairs(matched_columns) do
                    table.insert(col_summary, string.format("%s (%d hits)", col, hits))
                end

                fk_report.matching_tables[tbl] = {
                    total_rows = n,
                    matched_rows_count = #matched_rows,
                    columns = col_summary
                }

                print(string.format("  [!] BANG CO KHOA NGOAI: '%s' -> %d/%d rows | Cols: %s",
                    tbl, #matched_rows, n, table.concat(col_summary, ", ")))
            end
        end
    end

    fk_report.valid_tables_found = valid_tables_count

    -- 3. Xuat bao cao tong hop foreign_key_report.json
    local rep_lines = {"{\n"}
    table.insert(rep_lines, string.format('  "scan_time": "%s",\n', fk_report.scan_time))
    table.insert(rep_lines, string.format('  "target_team_id": %d,\n', fk_report.target_team_id))
    table.insert(rep_lines, string.format('  "valid_tables_found": %d,\n', fk_report.valid_tables_found))
    table.insert(rep_lines, string.format('  "fk_matched_tables_count": %d,\n', fk_matched_tables_count))
    table.insert(rep_lines, '  "matching_tables": {\n')

    local m_keys = {}
    for k in pairs(fk_report.matching_tables) do table.insert(m_keys, k) end
    table.sort(m_keys)

    for i, k in ipairs(m_keys) do
        local info = fk_report.matching_tables[k]
        local comma = (i < #m_keys) and ",\n" or "\n"
        local cols_str = {}
        for _, c in ipairs(info.columns) do table.insert(cols_str, escape_json(c)) end
        table.insert(rep_lines, string.format('    "%s": {\n      "total_rows": %d,\n      "matched_rows_count": %d,\n      "columns": [%s]\n    }%s',
            k, info.total_rows, info.matched_rows_count, table.concat(cols_str, ", "), comma))
    end
    table.insert(rep_lines, "  }\n}")
    write_file(BASE_DIR .. "foreign_key_report.json", table.concat(rep_lines))

    print("==================================================")
    print(string.format("[FK Analysis] HOAN TAT! Da tim thay %d bang chua KHOA NGOAI cua Binh Tan FC va cau thu VN!", fk_matched_tables_count))
    print(string.format("Bao cao chi tiet tai: %sforeign_key_report.json", BASE_DIR))
    print("==================================================")

    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(string.format("[FK Analysis] HOAN TAT! Tim thay %d bang co FK.\n", fk_matched_tables_count))
            f:close()
        end
    end)
end

run_deep_dump_and_fk_analysis()
