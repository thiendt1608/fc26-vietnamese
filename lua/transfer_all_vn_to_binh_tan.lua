-- lua/transfer_all_vn_to_binh_tan.lua
-- Script chuyen 100% toan bo 29 cau thu Viet Nam ve CLB Binh Tan FC (ID: 115486)
-- Chay truc tiep trong Live Editor (Lua Engine) khi dang mo Career Mode

local TARGET_TEAM_ID = 115486 -- ID cua CLB Binh Tan FC

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
    local bInCM = safe_call(IsInCM) or false
    local team_id = TARGET_TEAM_ID

    -- Neu dang trong Career Mode, uu tien lay ID doi bong cua ban (chinh la Binh Tan FC)
    if bInCM then
        local user_tid = safe_call(GetUserTeamID)
        if user_tid and tonumber(user_tid) and tonumber(user_tid) > 0 then
            team_id = math.floor(tonumber(user_tid))
        end
    end

    local team_name = safe_call(GetTeamName, team_id) or "Binh Tan FC"
    print(string.format("=================================================="))
    print(string.format("[Transfer VN] DANG CHUYEN TOAN BO CAU THU VE: %s (ID: %d)", team_name, team_id))
    print(string.format("=================================================="))

    local count_transfer = 0

    -- 1. Chuyen nhuong trong Career Mode qua API TransferPlayer
    if bInCM and TransferPlayer then
        for pid, name in pairs(VN_PLAYERS) do
            local current_tid = safe_call(GetTeamIdFromPlayerId, pid) or -1
            current_tid = math.floor(tonumber(current_tid) or -1)

            if current_tid ~= team_id then
                -- 1. playerid
                -- 2. new_teamid
                -- 3. transfer_fee (0)
                -- 4. wage (5000 EUR/tuan)
                -- 5. contract_length (3 nam)
                -- 6. squad_role (0 = Crucial)
                -- 7. release_clause (0 = khong co)
                local ok, err = pcall(TransferPlayer, pid, team_id, 0, 5000, 3, 0, 0)
                if ok then
                    count_transfer = count_transfer + 1
                    print(string.format("[CM Transfer] Da chuyen: %s (ID %d) -> %s", name, pid, team_name))
                else
                    print(string.format("[CM Transfer] Loi khi chuyen %s: %s", name, tostring(err)))
                end
            end
        end
    end

    -- 2. Cap nhat truc tiep bang teamplayerlinks trong RAM database de dong bo tuyet doi
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    local db_count = 0
    if links then
        for i = 1, #links do
            local l = links[i]
            local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0

            if VN_PLAYERS[pid] then
                local cur_tid = l.teamid and math.floor(tonumber(l.teamid.value) or 0) or 0
                if cur_tid ~= team_id then
                    l.teamid.value = tostring(team_id)
                    if type(EditDBTableField) == "function" then
                        EditDBTableField(l.teamid)
                    end
                    db_count = db_count + 1
                end
            end
        end
    end

    local final_msg = string.format("[Transfer VN] HOAN TAT! Da chuyen thanh cong toan bo cau thu Viet Nam ve CLB %s (ID %d)!", team_name, team_id)
    print(final_msg)
    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(final_msg .. "\n")
            f:close()
        end
    end)
end

transfer_all_to_binh_tan()
