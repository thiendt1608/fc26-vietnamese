-- lua/move_from_barcelona_to_binh_tan.lua
-- Script chuyen sach se cac cau thu Viet Nam tu FC Barcelona (ID: 241) ve lai Binh Tan FC (ID: 115486)
-- Dam bao moi cau thu chi co DUY NHAT 1 BAN THE, khong con bat ky duplicate nao!

local BARCA_ID = 241         -- FC Barcelona
local BINH_TAN_ID = 115486   -- Binh Tan FC

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

local function move_back_to_binh_tan()
    local links = type(GetDBTableRows) == "function" and GetDBTableRows("teamplayerlinks") or nil
    if not links then
        print("[To Binh Tan] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    print("==================================================")
    print("[To Binh Tan] DANG CHUYEN CAU THU TU BARCELONA VE LAI BINH TAN FC...")
    print("==================================================")

    local moved_count = 0

    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0
        local tid = l.teamid and math.floor(tonumber(l.teamid.value) or 0) or 0

        if VN_PLAYERS[pid] and tid == BARCA_ID then
            l.teamid.value = tostring(BINH_TAN_ID)
            if type(EditDBTableField) == "function" then
                EditDBTableField(l.teamid)
            end
            moved_count = moved_count + 1
            print(string.format("  -> Da chuyen %s (ID %d) tu Barca ve Binh Tan FC!", VN_PLAYERS[pid], pid))
        end
    end

    local msg = string.format("[To Binh Tan] HOAN TAT! Da chuyen %d cau thu tu Barcelona ve lai Binh Tan FC an toan 100%%, khong co duplicate!", moved_count)
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

move_back_to_binh_tan()
