-- lua/move_duplicates_to_barcelona.lua
-- Script chuyen tat ca cau thu Viet Nam bi TRUNG LAP sang FC Barcelona (ID: 241)
-- Dong thoi xoa bo ban sao thu 2 (ve Free Agents) de Binh Tan FC hoan toan sach se!

local BARCA_ID = 241         -- FC Barcelona
local BINH_TAN_ID = 115486   -- Binh Tan FC
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

local function move_to_barca()
    local links = type(GetDBTableRows) == "function" and GetDBTableRows("teamplayerlinks") or nil
    if not links then
        print("[To Barca] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    print("==================================================")
    print("[To Barca] DANG QUET CAU THU TRUNG LAP VA CHUYEN SANG BARCELONA (ID: 241)...")
    print("==================================================")

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
    local dup_cleaned = 0

    for pid, rows in pairs(player_rows) do
        local name = VN_PLAYERS[pid]
        local binhtan_links = {}

        for _, r in ipairs(rows) do
            local tid = r.teamid and math.floor(tonumber(r.teamid.value) or 0) or 0
            if tid == BINH_TAN_ID then
                table.insert(binhtan_links, r)
            end
        end

        -- Neu cau thu bi trung lap (>= 2 ban the o Binh Tan FC):
        if #binhtan_links > 1 then
            -- Ban the 1: Chuyen sang Barcelona (241)
            binhtan_links[1].teamid.value = tostring(BARCA_ID)
            if type(EditDBTableField) == "function" then
                EditDBTableField(binhtan_links[1].teamid)
            end
            moved_count = moved_count + 1

            -- Cac ban the thua (tu ban the 2 tro di): chuyen sang Free Agents de triet tieu
            for k = 2, #binhtan_links do
                binhtan_links[k].teamid.value = tostring(FREE_AGENTS_ID)
                if type(EditDBTableField) == "function" then
                    EditDBTableField(binhtan_links[k].teamid)
                end
                dup_cleaned = dup_cleaned + 1
            end

            print(string.format("  -> %s (ID %d): Da chuyen sang Barca, xoa %d duplicate", name, pid, #binhtan_links - 1))
        end
    end

    local msg = string.format("[To Barca] HOAN TAT! Da chuyen %d cau thu bi trung sang Barcelona (ID 241), va xoa %d ban sao thua!", moved_count, dup_cleaned)
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

move_to_barca()
