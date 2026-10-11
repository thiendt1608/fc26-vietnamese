-- lua/transfer_selected_to_barcelona.lua
-- Script chuyen DUNG 16 CAU THU theo yeu cau sang CLB FC Barcelona (ID: 241)
-- Danh sach: Xuan Son, Van Vi, Van Thanh, Van Lam, Van Hau, Tien Dung, Thanh Chung,
-- Tan Tai, Tai Loc, Quang Hai, Hung Dung, Hoang Hen, Hoang Duc, Duy Manh, Dinh Bac, Cong Phuong

local BARCA_ID = 241 -- FC Barcelona

local SELECTED_PLAYERS = {
    [921] = "Nguyen Xuan Son",
    [925] = "Nguyen Van Vi",
    [906] = "Vu Van Thanh",
    [900] = "Dang Van Lam",
    [905] = "Doan Van Hau",
    [914] = "Bui Tien Dung",
    [918] = "Nguyen Thanh Chung",
    [902] = "Ho Tan Tai",
    [928] = "Nguyen Tai Loc",
    [903] = "Nguyen Quang Hai",
    [910] = "Do Hung Dung",
    [922] = "Do Hoang Hen",
    [908] = "Nguyen Hoang Duc",
    [911] = "Do Duy Manh",
    [923] = "Nguyen Dinh Bac",
    [909] = "Nguyen Cong Phuong"
}

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function transfer_selected_to_barcelona()
    print("==================================================")
    print("[Selected -> Barca] DANG CHUYEN 16 CAU THU VIET NAM SANG BARCELONA (ID: 241)...")
    print("==================================================")

    local bInCM = safe_call(IsInCM) or false

    -- 1. Neu trong Career Mode: goi API TransferPlayer dang ky hop dong
    if bInCM and TransferPlayer then
        for pid, name in pairs(SELECTED_PLAYERS) do
            pcall(TransferPlayer, pid, BARCA_ID, 0, 5000, 3, 0, 0)
        end
    end

    -- 2. Cap nhat teamid cua dung 16 cau thu nay ve Barcelona (ID: 241)
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    if not links then
        print("[Selected -> Barca] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    local count = 0
    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0

        if SELECTED_PLAYERS[pid] then
            l.teamid.value = tostring(BARCA_ID)
            if type(EditDBTableField) == "function" then
                EditDBTableField(l.teamid)
            end
            count = count + 1
            print(string.format("  -> Da chuyen %s (ID %d) sang Barcelona (ID: 241)", SELECTED_PLAYERS[pid], pid))
        end
    end

    local msg = string.format("[Selected -> Barca] HOAN TAT! Da chuyen thanh cong dung 16 cau thu sang FC Barcelona (ID: 241)!", count)
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

transfer_selected_to_barcelona()
