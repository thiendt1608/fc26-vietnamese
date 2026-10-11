-- lua/transfer_to_barcelona.lua
-- Script chuyen 100% toan bo 29 cau thu Viet Nam sang CLB FC Barcelona (ID: 241)
-- Ap dung dung theo danh sach 29 ID tu hinh anh (ID: 900 den 928)
-- Triet tieu toan bo duplicate thua, dam bao moi nguoi chi co DUY NHAT 1 BAN THE o Barcelona!

local BARCA_ID = 241         -- FC Barcelona
local FREE_AGENTS_ID = 111592

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

local function transfer_to_barcelona()
    print("==================================================")
    print("[To Barca] DANG CHUYEN 29 CAU THU VIET NAM SANG BARCELONA (ID: 241)...")
    print("==================================================")

    local bInCM = safe_call(IsInCM) or false

    -- 1. Neu trong Career Mode: goi API TransferPlayer voi 7 tham so chuan FC 26
    if bInCM and TransferPlayer then
        for pid, name in pairs(VN_PLAYERS) do
            pcall(TransferPlayer, pid, BARCA_ID, 0, 5000, 3, 0, 0)
        end
    end

    -- 2. Cap nhat truc tiep bang teamplayerlinks trong RAM database
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    if not links then
        print("[To Barca] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    local assigned_to_barca = {}
    local moved_count = 0
    local dup_cleaned = 0

    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0

        if VN_PLAYERS[pid] then
            if not assigned_to_barca[pid] then
                -- Ban the dau tien: Chuyen sang FC Barcelona (ID 241)
                l.teamid.value = tostring(BARCA_ID)
                if type(EditDBTableField) == "function" then
                    EditDBTableField(l.teamid)
                end
                assigned_to_barca[pid] = true
                moved_count = moved_count + 1
                print(string.format("  -> Da chuyen %s (ID %d) sang Barcelona (ID: 241)", VN_PLAYERS[pid], pid))
            else
                -- Ban the trung lap thua: Chuyen ve Free Agents de Barcelona khong bi duplicate
                l.teamid.value = tostring(FREE_AGENTS_ID)
                if type(EditDBTableField) == "function" then
                    EditDBTableField(l.teamid)
                end
                dup_cleaned = dup_cleaned + 1
            end
        end
    end

    local msg = string.format("[To Barca] HOAN TAT! Da chuyen thanh cong %d / 29 cau thu sang Barcelona (ID: 241)!", moved_count)
    local msg2 = string.format("[To Barca] Da xoa sach %d duplicate thua, moi cau thu chi co 1 ban the duy nhat tai Barcelona!", dup_cleaned)
    print("==================================================")
    print(msg)
    print(msg2)
    print("==================================================")
    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(msg .. "\n" .. msg2 .. "\n")
            f:close()
        end
    end)
end

transfer_to_barcelona()
