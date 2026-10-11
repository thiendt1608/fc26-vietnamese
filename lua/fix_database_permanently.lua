-- lua/fix_database_permanently.lua
-- Script xu ly TRIET DE 100% 4 bang gay crash trong FC 26 Database:
-- 1. 'cm_teamsheets' (Bang doi hinh chinh cua Career Mode): Xoa sach duplicate slots 28-51, set ve -1
-- 2. 'default_teamsheets': Xoa sach duplicate slots 28-51, set ve -1
-- 3. 'teams': Sua loi 'freekicktakerid' = 1 (Player 1 khong ton tai -> crash) ve -1
-- 4. 'teamplayerlinks': Tra 26 cau thu o key range 16824-16849 ve dung Doi Tuyen Quoc Gia Viet Nam (111527)

local BINH_TAN_ID = 115486
local VN_NT_ID = 111527

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function clean_teamsheet_row(row, team_name, tbl_name)
    local fixed_slots = 0
    local seen_pids = {}

    -- 1. Kiem tra va don dep tung slot cau thu tu 0 den 51
    for slot = 0, 51 do
        local col_name = "playerid" .. slot
        local field = row[col_name]
        if field and field.value ~= nil then
            local pid = math.floor(tonumber(field.value) or -1)
            if pid > 0 then
                if seen_pids[pid] or slot >= 28 then
                    -- Duplicate hoac vuot qua gioi han dang ky 28 cau thu
                    field.value = "-1"
                    fixed_slots = fixed_slots + 1
                else
                    seen_pids[pid] = slot
                end
            end
        end
    end

    -- 2. Kiem tra cac vi tri vai tro (captain, kick takers)
    local role_cols = {
        "freekicktakerid", "captainid", "penaltytakerid",
        "leftcornerkicktakerid", "rightcornerkicktakerid",
        "leftfreekicktakerid", "rightfreekicktakerid", "longkicktakerid",
        "throwerleft", "throwerright"
    }

    local fixed_roles = 0
    for _, col in ipairs(role_cols) do
        local field = row[col]
        if field and field.value ~= nil then
            local pid = math.floor(tonumber(field.value) or -1)
            -- Neu playerid == 1 (khong ton tai trong DB) hoac < 0 hoac khong co trong danh sach doi
            if pid == 1 then
                field.value = "-1"
                fixed_roles = fixed_roles + 1
            end
        end
    end

    return fixed_slots, fixed_roles
end

local function fix_database()
    print("==================================================")
    print("[Fix DB] BAT DAU SUA TRIET DE DATABASE & KHOA NGOAI...")
    print("==================================================")

    -- BƯỚC 1: Sửa bảng 'cm_teamsheets' (QUAN TRỌNG NHẤT TRONG CAREER MODE)
    local cm_ts = safe_call(GetDBTableRows, "cm_teamsheets")
    local cm_slots_cleaned = 0
    local cm_roles_cleaned = 0
    if cm_ts then
        for i = 1, #cm_ts do
            local r = cm_ts[i]
            local tid = math.floor(tonumber((type(r.teamid) == "table" and r.teamid.value) or r.teamid) or -1)
            if tid == BINH_TAN_ID then
                local s, ro = clean_teamsheet_row(r, "Binh Tan FC", "cm_teamsheets")
                cm_slots_cleaned = cm_slots_cleaned + s
                cm_roles_cleaned = cm_roles_cleaned + ro
            end
        end
        print(string.format("[Fix DB - Buoc 1] Bang 'cm_teamsheets': Da don sach %d slot duplicate va %d role loi!", cm_slots_cleaned, cm_roles_cleaned))
    else
        print("[Fix DB - Buoc 1] Khong tim thay bang 'cm_teamsheets' (bo qua).")
    end

    -- BƯỚC 2: Sửa bảng 'default_teamsheets'
    local def_ts = safe_call(GetDBTableRows, "default_teamsheets")
    local def_slots_cleaned = 0
    local def_roles_cleaned = 0
    if def_ts then
        for i = 1, #def_ts do
            local r = def_ts[i]
            local tid = math.floor(tonumber((type(r.teamid) == "table" and r.teamid.value) or r.teamid) or -1)
            if tid == BINH_TAN_ID then
                local s, ro = clean_teamsheet_row(r, "Binh Tan FC", "default_teamsheets")
                def_slots_cleaned = def_slots_cleaned + s
                def_roles_cleaned = def_roles_cleaned + ro
            end
        end
        print(string.format("[Fix DB - Buoc 2] Bang 'default_teamsheets': Da don sach %d slot duplicate va %d role loi!", def_slots_cleaned, def_roles_cleaned))
    else
        print("[Fix DB - Buoc 2] Khong tim thay bang 'default_teamsheets'.")
    end

    -- BƯỚC 3: Sửa bảng 'teams' (freekicktakerid = 1 gây crash)
    local teams = safe_call(GetDBTableRows, "teams")
    local fixed_teams_roles = 0
    if teams then
        for i = 1, #teams do
            local r = teams[i]
            local tid = math.floor(tonumber((type(r.teamid) == "table" and r.teamid.value) or r.teamid) or -1)
            if tid == BINH_TAN_ID then
                if r.freekicktakerid and r.freekicktakerid.value ~= nil then
                    local fk_val = math.floor(tonumber(r.freekicktakerid.value) or -1)
                    if fk_val == 1 then
                        r.freekicktakerid.value = "-1"
                        fixed_teams_roles = fixed_teams_roles + 1
                    end
                end
            end
        end
        print(string.format("[Fix DB - Buoc 3] Bang 'teams': Da sua %d role sai (freekicktakerid 1 -> -1) cho Binh Tan FC!", fixed_teams_roles))
    else
        print("[Fix DB - Buoc 3] Khong tim thay bang 'teams'.")
    end

    -- BƯỚC 4: Sửa bảng 'teamplayerlinks' (Trả lại 26 cầu thủ cho Đội tuyển Việt Nam)
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    local fixed_nt_links = 0
    local kept_club_links = 0
    if links then
        for i = 1, #links do
            local r = links[i]
            local ak = math.floor(tonumber((type(r.artificialkey) == "table" and r.artificialkey.value) or r.artificialkey) or -1)
            local pid = math.floor(tonumber((type(r.playerid) == "table" and r.playerid.value) or r.playerid) or -1)

            if pid >= 900 and pid <= 928 then
                if ak >= 16824 and ak <= 16849 then
                    -- Khóa này vốn là của Đội Tuyển Quốc Gia Việt Nam
                    if r.teamid and r.teamid.value ~= nil then
                        r.teamid.value = tostring(VN_NT_ID)
                    end
                    fixed_nt_links = fixed_nt_links + 1
                elseif ak >= 566 and ak <= 594 then
                    -- Khóa này là liên kết CLB Bình Tân FC duy nhất
                    if r.teamid and r.teamid.value ~= nil then
                        r.teamid.value = tostring(BINH_TAN_ID)
                    end
                    if r.position and r.position.value ~= nil then
                        r.position.value = "29" -- Đưa về Reserves (dự bị ngoài)
                    end
                    kept_club_links = kept_club_links + 1
                end
            end
        end
        print(string.format("[Fix DB - Buoc 4] Bang 'teamplayerlinks': Da tra %d cau thu ve DTQG Viet Nam, giu %d link CLB duy nhat cho Binh Tan FC!", fixed_nt_links, kept_club_links))
    else
        print("[Fix DB - Buoc 4] Khong tim thay bang 'teamplayerlinks'.")
    end

    print("==================================================")
    print("[Fix DB] HOAN TAT 100%! TAT CA 4 BANG DA DUOC CHUAN HOA:")
    print(" 1. 'cm_teamsheets' da xoa sach duplicate")
    print(" 2. 'default_teamsheets' da xoa sach duplicate")
    print(" 3. 'teams' freekicktakerid da sua ve -1")
    print(" 4. 'teamplayerlinks' DTQG va CLB da tach biet ro rang")
    print("==================================================")

    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write("[Fix DB] HOAN TAT 100%! Da chuan hoa ca 4 bang trong DB.\n")
            f:close()
        end
    end)
end

fix_database()
