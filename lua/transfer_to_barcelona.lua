-- lua/transfer_to_barcelona.lua
-- Script chuyen 100% toan bo 29 cau thu Viet Nam sang FC Barcelona (ID: 241)
-- Phien ban don gian thuan tuy: khong loc, khong xoa, chi chuyen teamid sang 241

local BARCA_ID = 241 -- FC Barcelona

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

    -- 1. Neu trong Career Mode: goi API TransferPlayer dang ky hop dong
    if bInCM and TransferPlayer then
        for pid, name in pairs(VN_PLAYERS) do
            pcall(TransferPlayer, pid, BARCA_ID, 0, 5000, 3, 0, 0)
        end
    end

    -- 2. Cap nhat tat ca link cua 29 cau thu sang Barcelona (ID: 241)
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    if not links then
        print("[To Barca] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    local count = 0
    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0

        if VN_PLAYERS[pid] then
            l.teamid.value = tostring(BARCA_ID)
            if type(EditDBTableField) == "function" then
                EditDBTableField(l.teamid)
            end
            count = count + 1
            print(string.format("  -> Da chuyen %s (ID %d) sang Barcelona (ID: 241)", VN_PLAYERS[pid], pid))
        end
    end

    local msg = string.format("[To Barca] HOAN TAT! Da chuyen thanh cong toan bo sang Barcelona (ID: 241) - Tong %d record!", count)
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

transfer_to_barcelona()
