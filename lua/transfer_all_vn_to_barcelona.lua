-- lua/transfer_all_vn_to_barcelona.lua
-- Script chuyen 100% TOAN BO 29 cau thu Viet Nam sang CLB FC Barcelona (ID: 241)
-- Triet tieu toan bo duplicate thua, dam bao moi cau thu chi co DUY NHAT 1 BAN THE o Barcelona!

local BARCA_ID = 241         -- FC Barcelona
local FREE_AGENTS_ID = 111592

local VN_PLAYERS = {
    [900] = "Dang Van Lam", [901] = "Nguyen Van Toan", [902] = "Ho Tan Tai",
    [903] = "Nguyen Quang Hai", [904] = "Nguyen Trong Dai", [905] = "Doan Van Hau",
    [906] = "Vu Van Thanh", [907] = "B H Viet Anh", [908] = "Nguyen Hoang Duc",
    [909] = "Nguyen Cong Phuong", [910] = "Do Hung Dung", [911] = "Do Duy Manh",
    [912] = "Nguyen Tien Linh", [913] = "Nguyen Tuan Anh", [914] = "Bui Tien Dung",
    [915] = "Que Ngoc Hai", [916] = "Luong Xuan Truong", [917] = "Pham Tuan Hai",
    [918] = "Nguyen Thanh Chung", [919] = "Bui Tan Truong", [920] = "Phi Minh Long",
    [921] = "Nguyen Xuan Son", [922] = "Do Hoang Hen", [923] = "Nguyen Dinh Bac",
    [924] = "Khuat Van Khang", [925] = "Nguyen Van Vi", [926] = "Nguyen Nhat Minh",
    [927] = "Do Phi Long", [928] = "Nguyen Tai Loc"
}

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function transfer_all_to_barca()
    print("==================================================")
    print("[To Barca] DANG CHUYEN TOAN BO 29 CAU THU VIET NAM SANG BARCELONA (ID: 241)...")
    print("==================================================")

    local bInCM = safe_call(IsInCM) or false

    -- 1. Neu trong Career Mode: goi API TransferPlayer de dang ky hop dong o Barca
    if bInCM and TransferPlayer then
        for pid, name in pairs(VN_PLAYERS) do
            pcall(TransferPlayer, pid, BARCA_ID, 0, 5000, 3, 0, 0)
        end
    end

    -- 2. Cap nhat bang teamplayerlinks trong RAM database de dong bo sach se
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    if not links then
        print("[To Barca] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

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

    for pid, name in pairs(VN_PLAYERS) do
        local rows = player_rows[pid]
        if rows and #rows > 0 then
            -- Dong 1: Chuyen chinh thuc sang Barcelona (ID 241)
            rows[1].teamid.value = tostring(BARCA_ID)
            if type(EditDBTableField) == "function" then
                EditDBTableField(rows[1].teamid)
            end
            moved_count = moved_count + 1

            -- Cac dong thua (duplicate tu dong 2 tro di): chuyen sang Free Agents
            if #rows > 1 then
                for k = 2, #rows do
                    rows[k].teamid.value = tostring(FREE_AGENTS_ID)
                    if type(EditDBTableField) == "function" then
                        EditDBTableField(rows[k].teamid)
                    end
                    dedup_count = dedup_count + 1
                end
            end
            print(string.format("  -> Da chuyen %s (ID %d) sang Barcelona (xoa %d link thua)", name, pid, #rows - 1))
        end
    end

    local msg = string.format("[To Barca] HOAN TAT! Da chuyen %d / 29 cau thu sang Barcelona (ID 241), triet tieu %d duplicate!", moved_count, dedup_count)
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

transfer_all_to_barca()
