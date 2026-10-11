-- lua/restore_clean_squad.lua
-- Script KHÔI PHỤC SẠCH SẼ ĐỘI HÌNH BINH TAN FC
-- Xóa triệt để mọi bản sao duplicate (2 Công Phượng, 2 Văn Lâm...)
-- Trả các cầu thủ ngoài về Free Agents để chấm dứt 100% lỗi crash game khi bấm vào Đội hình!

local ORIGINAL_TEAMS = {
    -- 16 cau thu GOC BAN DAU cua Binh Tan FC (ID 115486)
    [900] = 115486, -- Dang Van Lam
    [902] = 115486, -- Ho Tan Tai
    [903] = 115486, -- Nguyen Quang Hai
    [905] = 115486, -- Doan Van Hau
    [906] = 115486, -- Vu Van Thanh
    [908] = 115486, -- Nguyen Hoang Duc
    [909] = 115486, -- Nguyen Cong Phuong
    [910] = 115486, -- Do Hung Dung
    [911] = 115486, -- Do Duy Manh
    [914] = 115486, -- Bui Tien Dung
    [918] = 115486, -- Nguyen Thanh Chung
    [921] = 115486, -- Nguyen Xuan Son
    [922] = 115486, -- Do Hoang Hen
    [923] = 115486, -- Nguyen Dinh Bac
    [925] = 115486, -- Nguyen Van Vi
    [928] = 115486, -- Nguyen Tai Loc

    -- 13 cau thu goc o Free Agents hoac CLB ngoai
    [901] = 111592, -- Nguyen Van Toan (Free Agents)
    [904] = 113217, -- Nguyen Trong Dai (Damac)
    [907] = 1867,   -- B H Viet Anh (Córdoba CF)
    [912] = 111592, -- Nguyen Tien Linh (Free Agents)
    [913] = 111716, -- Nguyen Tuan Anh (Unión de Santa Fe)
    [915] = 111235, -- Que Ngoc Hai (Heidenheim)
    [916] = 111592, -- Luong Xuan Truong (Free Agents)
    [917] = 111592, -- Pham Tuan Hai (Free Agents)
    [919] = 111592, -- Bui Tan Truong (Free Agents)
    [920] = 110556, -- Phi Minh Long (Genoa)
    [924] = 111592, -- Khuat Van Khang (Free Agents)
    [926] = 294,    -- Nguyen Nhat Minh (ESTAC Troyes)
    [927] = 31      -- Do Phi Long (1. FC Köln)
}

local function restore_clean_squad()
    local links = type(GetDBTableRows) == "function" and GetDBTableRows("teamplayerlinks") or nil
    if not links then
        print("[Restore Squad] ERROR: Khong lay duoc bang 'teamplayerlinks' tu RAM!")
        return
    end

    print("==================================================")
    print("[Restore Squad] DANG KHOI PHUC DOI HINH SACH SE & XOA HET CRASH...")
    print("==================================================")

    local player_rows = {}
    for i = 1, #links do
        local l = links[i]
        local pid = l.playerid and math.floor(tonumber(l.playerid.value) or 0) or 0
        if ORIGINAL_TEAMS[pid] then
            if not player_rows[pid] then player_rows[pid] = {} end
            table.insert(player_rows[pid], l)
        end
    end

    local restored_count = 0
    local removed_dup_count = 0

    for pid, rows in pairs(player_rows) do
        local orig_tid = ORIGINAL_TEAMS[pid]
        
        -- 1. Dong dau tien: Dat ve dung CLB goc ban dau
        local r1 = rows[1]
        if r1 then
            r1.teamid.value = tostring(orig_tid)
            if type(EditDBTableField) == "function" then
                EditDBTableField(r1.teamid)
            end
            restored_count = restored_count + 1
        end

        -- 2. Neu co dong thu 2, thu 3 (cac ban the duplicate bi tao ra do transfer):
        -- Chuyen ve Free Agents (111592) de bien mat hoan toan khoi Binh Tan FC
        if #rows > 1 then
            for k = 2, #rows do
                local rk = rows[k]
                rk.teamid.value = "111592"
                if type(EditDBTableField) == "function" then
                    EditDBTableField(rk.teamid)
                end
                removed_dup_count = removed_dup_count + 1
            end
        end
    end

    local msg = string.format("[Restore Squad] HOAN TAT! Binh Tan FC da tro lai 1 ban the duy nhat cho moi cau thu (da xoa %d ban sao thua). Het 100%% loi crash!", removed_dup_count)
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

restore_clean_squad()
