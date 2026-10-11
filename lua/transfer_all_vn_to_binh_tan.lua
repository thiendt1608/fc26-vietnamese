-- lua/transfer_all_vn_to_binh_tan.lua
-- Script chuyen 100% toan bo 29 cau thu Viet Nam ve CLB Binh Tan FC (ID: 115486)
-- Phien ban thuan tuy: khong loc, khong xoa, chuyen thang teamid ve 115486

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

local function transfer_all_to_binh_tan()
    print("==================================================")
    print("[To Binh Tan] DANG CHUYEN 29 CAU THU VIET NAM VE BINH TAN FC (ID: 115486)...")
    print("==================================================")

    local bInCM = safe_call(IsInCM) or false

    -- 1. Neu trong Career Mode: goi API TransferPlayer dang ky hop dong
    if bInCM and TransferPlayer then
        for pid, name in pairs(VN_PLAYERS) do
            pcall(TransferPlayer, pid, TARGET_TEAM_ID, 0, 5000, 3, 0, 0)
        end
    end

    -- 2. Cap nhat tat ca link cua 29 cau thu ve Binh Tan FC (ID: 115486)
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    if not links then
        print("[To Binh Tan] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    local count = 0
    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0

        if VN_PLAYERS[pid] then
            l.teamid.value = tostring(TARGET_TEAM_ID)
            if type(EditDBTableField) == "function" then
                EditDBTableField(l.teamid)
            end
            count = count + 1
            print(string.format("  -> Da chuyen %s (ID %d) ve Binh Tan FC (ID: 115486)", VN_PLAYERS[pid], pid))
        end
    end

    local msg = string.format("[To Binh Tan] HOAN TAT! Da chuyen thanh cong toan bo ve Binh Tan FC (ID: 115486) - Tong %d record!", count)
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

transfer_all_to_binh_tan()
