-- lua/fix_duplicate_and_clean_squad.lua
-- Script dọn sạch triệt để mọi cầu thủ bị nhân bản (duplicate) trong CLB Binh Tan FC (ID: 115486)
-- Đảm bảo mỗi cầu thủ Việt Nam chỉ có DUY NHẤT 1 bản thể trong đội hình!

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

local function clean_and_fix_squad()
    local links = type(GetDBTableRows) == "function" and GetDBTableRows("teamplayerlinks") or nil
    if not links then
        print("[Fix Squad] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    print("==================================================")
    print("[Fix Squad] DANG QUET VA DON SACH DUPLICATE TRONG BINH TAN FC...")
    print("==================================================")

    -- Gom toan bo record lien quan den 29 cau thu VN
    local player_rows = {}
    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0
        if VN_PLAYERS[pid] then
            if not player_rows[pid] then player_rows[pid] = {} end
            table.insert(player_rows[pid], l)
        end
    end

    local fixed_duplicates = 0
    local assigned_to_binhtan = 0

    for pid, rows in pairs(player_rows) do
        local name = VN_PLAYERS[pid]
        local binhtan_count = 0

        for _, r in ipairs(rows) do
            local tid = r.teamid and math.floor(tonumber(r.teamid.value) or 0) or 0
            if tid == TARGET_TEAM_ID then
                binhtan_count = binhtan_count + 1
            end
        end

        if binhtan_count > 1 then
            -- CO TRUNG LAP: Giu lai dung 1 dong cho Binh Tan FC, cac dong thua chuyen ve Free Agents (111592)
            local kept = false
            for _, r in ipairs(rows) do
                local tid = r.teamid and math.floor(tonumber(r.teamid.value) or 0) or 0
                if tid == TARGET_TEAM_ID then
                    if not kept then
                        kept = true -- Ban the chinh duy nhat
                    else
                        -- Ban the trung lap thua: chuyen sang Free Agents de bien mat khoi CLB
                        r.teamid.value = "111592"
                        if type(EditDBTableField) == "function" then
                            EditDBTableField(r.teamid)
                        end
                        fixed_duplicates = fixed_duplicates + 1
                        print(string.format("  -> Da xoa ban the duplicate cua: %s (ID %d)", name, pid))
                    end
                end
            end
        elseif binhtan_count == 0 then
            -- Chua co o Binh Tan FC: Chuyen dong dau tien ve Binh Tan FC
            local r = rows[1]
            if r then
                r.teamid.value = tostring(TARGET_TEAM_ID)
                if type(EditDBTableField) == "function" then
                    EditDBTableField(r.teamid)
                end
                assigned_to_binhtan = assigned_to_binhtan + 1
                print(string.format("  -> Da chuyen %s (ID %d) -> Binh Tan FC", name, pid))
            end
        end
    end

    local msg = string.format("[Fix Squad] HOAN TAT! Da xoa %d duplicate, moi cau thu gio day chi co DUY NHAT 1 BAN THE trong doi hinh Binh Tan FC!", fixed_duplicates)
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

clean_and_fix_squad()
