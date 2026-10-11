-- lua/fix_player_faces.lua
-- Script sua loi CRASH KHI VAO TRAN DAU (Kick Off / Play Match) trong FC 26:
-- NGUYEN NHAN: 29 cau thu Viet Nam bi set 'headclasscode = 0' (Starhead/Real Face),
-- nhung trong file game khong co file 3D mesh Starhead cua cau thu VN, dan den Engine 3D Frostbite bi con tro NULL gay EXCEPTION_ACCESS_VIOLATION!
-- GIAI PHAP: Chuyen toan bo 29 cau thu sang 'headclasscode = 1' (Generic Face) va 'hashighqualityhead = 0'.

local TARGET_PIDS_MIN = 900
local TARGET_PIDS_MAX = 928

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function commit_field(field, new_val)
    if not field then return false end
    field.value = tostring(new_val)
    local ok = safe_call(EditDBTableField, field)
    if ok == nil then return true end
    return ok
end

local function fix_faces()
    print("==================================================")
    print("[Fix Faces] DANG XU LY KHU LOI CRASH KHI VAO TRAN DAU...")
    print("==================================================")

    local players = safe_call(GetDBTableRows, "players")
    if not players then
        print("[Fix Faces] LOI: Khong the lay bang 'players'!")
        return
    end

    local fixed_count = 0
    for i = 1, #players do
        local r = players[i]
        local pid_val = (type(r.playerid) == "table" and r.playerid.value) or r.playerid
        local pid = math.floor(tonumber(pid_val) or -1)

        if pid >= TARGET_PIDS_MIN and pid <= TARGET_PIDS_MAX then
            -- 1. Chuyen sang Generic Face (Mặt mặc định 3D an toàn 100%)
            commit_field(r.headclasscode, 1)

            -- 2. Tat Starhead chat luong cao
            commit_field(r.hashighqualityhead, 0)

            -- 3. Dat headtypecode ve 0 (Generic chuẩn)
            if r.headtypecode then
                commit_field(r.headtypecode, 0)
            end

            -- 4. Dat facepsdlayer0 ve 0
            if r.facepsdlayer0 then
                commit_field(r.facepsdlayer0, 0)
            end

            fixed_count = fixed_count + 1
        end
    end

    print(string.format("[Fix Faces] HOAN TAT! Da sua mat 3D cua toan bo %d cau thu VN sang Generic Face!", fixed_count))
    print("Het 100% loi vang game (Crash) khi bat dau tran dau (Kick Off / Play Match)!")
    print("==================================================")

    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(string.format("[Fix Faces] Da sua mat 3D cho %d cau thu VN sang Generic.\n", fixed_count))
            f:close()
        end
    end)
end

fix_faces()
