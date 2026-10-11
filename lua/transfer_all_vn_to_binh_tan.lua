-- lua/transfer_all_vn_to_binh_tan.lua
-- Script gom 100% toan bo 29 cau thu Viet Nam ve CLB Binh Tan FC (ID: 115486)
-- Tich hop co che tu dong chan duplicate, dam bao moi cau thu chi co dung 1 ban the!

local TARGET_TEAM_ID = 115486 -- Binh Tan FC

local VN_PLAYERS = {
    [900] = "Dang Van Lam",
    [901] = "Nguyen Van Toan",
    [902] = "Ho Tan Tai",
    [903] = "Nguyen Quang Hai",
    [904] = "Nguyen Trong Dai",
    [905] = "Doan Van Hau",
    [906] = "Vu Van Thanh",
    [907] = "B H Viet Anh",
    [908] = "Nguyen Hoang Duc",
    [909] = "Nguyen Cong Phuong",
    [910] = "Do Hung Dung",
    [911] = "Do Duy Manh",
    [912] = "Nguyen Tien Linh",
    [913] = "Nguyen Tuan Anh",
    [914] = "Bui Tien Dung",
    [915] = "Que Ngoc Hai",
    [916] = "Luong Xuan Truong",
    [917] = "Pham Tuan Hai",
    [918] = "Nguyen Thanh Chung",
    [919] = "Bui Tan Truong",
    [920] = "Phi Minh Long",
    [921] = "Nguyen Xuan Son",
    [922] = "Do Hoang Hen",
    [923] = "Nguyen Dinh Bac",
    [924] = "Khuat Van Khang",
    [925] = "Nguyen Van Vi",
    [926] = "Nguyen Nhat Minh",
    [927] = "Do Phi Long",
    [928] = "Nguyen Tai Loc"
}

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function transfer_and_clean()
    local bInCM = safe_call(IsInCM) or false
    local team_id = TARGET_TEAM_ID

    if bInCM then
        local user_tid = safe_call(GetUserTeamID)
        if user_tid and tonumber(user_tid) and tonumber(user_tid) > 0 then
            team_id = math.floor(tonumber(user_tid))
        end
    end

    local team_name = safe_call(GetTeamName, team_id) or "Binh Tan FC"
    print(string.format("=================================================="))
    print(string.format("[Transfer VN] GOM CAU THU VA CHONG DUPLICATE: %s (ID: %d)", team_name, team_id))
    print(string.format("=================================================="))

    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    if not links then
        print("[Transfer VN] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    -- 1. Gom toan bo lien ket cua 29 cau thu
    local player_rows = {}
    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0
        if VN_PLAYERS[pid] then
            if not player_rows[pid] then player_rows[pid] = {} end
            table.insert(player_rows[pid], l)
        end
    end

    local moved_count = 0
    local dedup_count = 0

    -- 2. Xu ly an toan tuyet doi: Moi cau thu chi duoc phep co DUY NHAT 1 dong o Binh Tan FC
    for pid, rows in pairs(player_rows) do
        local name = VN_PLAYERS[pid]
        local kept_one = false

        for _, r in ipairs(rows) do
            local cur_tid = r.teamid and math.floor(tonumber(r.teamid.value) or 0) or 0
            if cur_tid == team_id then
                if not kept_one then
                    kept_one = true -- Giu lai ban the duy nhat
                else
                    -- Duplicate thua: chuyen ve Free Agents (111592)
                    r.teamid.value = "111592"
                    if type(EditDBTableField) == "function" then
                        EditDBTableField(r.teamid)
                    end
                    dedup_count = dedup_count + 1
                    print(string.format("  -> Da xoa duplicate thua cua: %s (ID %d)", name, pid))
                end
            end
        end

        -- Neu cau thu chua co dong nao o Binh Tan FC (vi du o Free Agents hoac CLB ngoai)
        if not kept_one then
            local first_row = rows[1]
            if first_row then
                first_row.teamid.value = tostring(team_id)
                if type(EditDBTableField) == "function" then
                    EditDBTableField(first_row.teamid)
                end
                moved_count = moved_count + 1
                print(string.format("  -> Da chuyen: %s (ID %d) -> %s", name, pid, team_name))
            end
        end
    end

    local msg = string.format("[Transfer VN] HOAN TAT! Da chuyen %d cau thu va xoa %d dong duplicate. Moi cau thu chi co 1 ban the duy nhat!", moved_count, dedup_count)
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

transfer_and_clean()
