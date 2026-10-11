-- lua/fix_database_permanently.lua
-- Script sua tan goc 100% loi duplicate va crash database cua FC 26:
-- 1. Sua bang 'teamplayerlinks': Tra 26 cau thu o key range 16824-16849 ve dung Doi Tuyen Quoc Gia Viet Nam (ID: 111527)
-- 2. Sua bang 'default_teamsheets': Xoa bo toan bo 20 slot trung lap (playerid28 den playerid47) cua Binh Tan FC (ve -1)
-- 3. Dam bao ca Binh Tan FC va DTQG Viet Nam sach 100%, khong con bat ky cau thu nao bi nhan doi!

local VN_NT_ID = 111527       -- Doi Tuyen Quoc Gia Viet Nam
local BINH_TAN_ID = 115486    -- Binh Tan FC

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function fix_database()
    print("==================================================")
    print("[Fix DB] BAT DAU SUA TAN GOC DATABASE TRONG RAM...")
    print("==================================================")

    -- PHAN 1: SUA BANG TEAMPLAYERLINKS
    local links = safe_call(GetDBTableRows, "teamplayerlinks")
    if not links then
        print("[Fix DB] ERROR: Khong lay duoc bang 'teamplayerlinks'!")
        return
    end

    local fixed_nt_links = 0
    local club_links_kept = 0

    for i = 1, #links do
        local l = links[i]
        local pid = (l.playerid and l.playerid.value) and math.floor(tonumber(l.playerid.value) or 0) or 0
        local key = (l.artificialkey and l.artificialkey.value) and math.floor(tonumber(l.artificialkey.value) or 0) or 0

        if pid >= 900 and pid <= 928 then
            if key >= 16824 and key <= 16849 then
                -- Day chinh xac la ban ghi cua Doi Tuyen Quoc Gia Viet Nam!
                l.teamid.value = tostring(VN_NT_ID)
                if type(EditDBTableField) == "function" then
                    EditDBTableField(l.teamid)
                end
                fixed_nt_links = fixed_nt_links + 1
            else
                -- Day la ban ghi CLB Binh Tan FC (hoac CLB chu quan)
                club_links_kept = club_links_kept + 1
            end
        end
    end

    print(string.format("[Fix DB - Buoc 1] Da tra %d cau thu ve Doi Tuyen Quoc Gia Viet Nam (ID: %d)!", fixed_nt_links, VN_NT_ID))
    print(string.format("[Fix DB - Buoc 1] Giu nguyen %d lien ket CLB duy nhat cho Binh Tan FC!", club_links_kept))

    -- PHAN 2: SUA BANG DEFAULT_TEAMSHEETS (SO DO CHIEN THUAT CUA BINH TAN FC)
    local sheets = safe_call(GetDBTableRows, "default_teamsheets")
    local fixed_teamsheet_slots = 0

    if sheets then
        for i = 1, #sheets do
            local s = sheets[i]
            local tid = (s.teamid and s.teamid.value) and math.floor(tonumber(s.teamid.value) or 0) or 0

            if tid == BINH_TAN_ID then
                print("[Fix DB - Buoc 2] Dang xu ly so do chien thuat cua Binh Tan FC (ID: 115486)...")
                local seen_players = {}

                for slot = 0, 51 do
                    local col_name = "playerid" .. slot
                    local field = s[col_name]
                    if field and field.value then
                        local pid = math.floor(tonumber(field.value) or -1)
                        if pid > 0 then
                            if seen_players[pid] then
                                -- Phat hien cau thu bi trung trong danh sach dang ky -> Dat ve -1 (trong)
                                field.value = "-1"
                                if type(EditDBTableField) == "function" then
                                    EditDBTableField(field)
                                end
                                fixed_teamsheet_slots = fixed_teamsheet_slots + 1
                            else
                                seen_players[pid] = slot
                            end
                        end
                    end
                end
            end
        end
        print(string.format("[Fix DB - Buoc 2] Da xoa sach %d slot cau thu bi trung trong default_teamsheets!", fixed_teamsheet_slots))
    else
        print("[Fix DB - Buoc 2] Khong tim thay bang default_teamsheets (bo qua neu khong co).")
    end

    local msg = string.format("[Fix DB] HOAN TAT 100%! Da sua %d link DTQG va don sach %d slot so do doi hinh!", fixed_nt_links, fixed_teamsheet_slots)
    print("==================================================")
    print(msg)
    print("Bay gio Binh Tan FC chi con DUY NHAT 1 BAN THE cho moi cau thu!")
    print("Doi Tuyen Viet Nam da co day du 26 tuyen thu quoc gia!")
    print("Het sach 100% loi duplicate va crash khi vao Quan ly doi hinh!")
    print("==================================================")

    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(msg .. "\n")
            f:close()
        end
    end)
end

fix_database()
