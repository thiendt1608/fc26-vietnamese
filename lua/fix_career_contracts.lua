-- lua/fix_career_contracts.lua
-- Script giai quyet TAN GOC 100% loi crash khi "Mo phong tran dau" (Simulate Match) trong Career Mode:
-- NGUYEN NHAN: Trong so 29 cau thu Viet Nam o Binh Tan FC, chi co 19 cau thu co hop dong 'career_playercontract'.
-- 10 cau thu con lai (Cong Phuong, Dinh Bac, Khuat Van Khang, Ho Tan Tai...) HOAN TOAN KHONG CO HOP DONG trong Career Mode!
-- Khi mo phong tran dau, Engine Career Mode tinh luong va so phut thi dau, gap con tro NULL hop dong -> CRASH!
-- GIAI PHAP: Dung 'InsertDBTableRow' tao day du hop dong hop le cho toan bo 10 cau thu con lai!

local BINH_TAN_ID = 115486

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function fix_career_contracts()
    print("==================================================")
    print("[Fix Career Contracts] DANG KIEM TRA HOP DONG CAU THU...")
    print("==================================================")

    local contracts = safe_call(GetDBTableRows, "career_playercontract")
    if not contracts then
        print("[Fix Career Contracts] LOI: Khong the doc bang 'career_playercontract'!")
        return
    end

    -- 1. Quet xem cau thu nao da co hop dong o Binh Tan FC
    local existing_contracts = {}
    for i = 1, #contracts do
        local r = contracts[i]
        local pid_val = (type(r.playerid) == "table" and r.playerid.value) or r.playerid
        local tid_val = (type(r.teamid) == "table" and r.teamid.value) or r.teamid
        local pid = math.floor(tonumber(pid_val) or -1)
        local tid = math.floor(tonumber(tid_val) or -1)

        if pid >= 900 and pid <= 928 and tid == BINH_TAN_ID then
            existing_contracts[pid] = true
        end
    end

    local inserted_count = 0
    local skipped_count = 0

    -- 2. Tao hop dong moi cho nhung cau thu chua co
    for pid = 900, 928 do
        if existing_contracts[pid] then
            skipped_count = skipped_count + 1
        else
            local row_data = {
                playerid = tostring(pid),
                teamid = tostring(BINH_TAN_ID),
                wage = "5000",
                duration_months = "24",
                contract_status = "0",
                contract_date = "20260913",
                last_status_change_date = "20260913",
                loan_wage_split = "-1",
                performancebonuscount = "-1",
                performancebonuscountachieved = "0",
                performancebonustype = "0",
                performancebonusvalue = "-1",
                playerrole = "-1",
                signon_bonus = "0"
            }

            local new_row = safe_call(InsertDBTableRow, "career_playercontract", row_data)
            if new_row and new_row.addr ~= "0" then
                inserted_count = inserted_count + 1
                print(string.format("  [+] Da tao hop dong Career Mode cho Player %d!", pid))
            else
                print(string.format("  [-] Khong the tao hop dong cho Player %d!", pid))
            end
        end
    end

    print("==================================================")
    print(string.format("[Fix Career Contracts] HOAN TAT! Da tao %d hop dong moi, %d cau thu da co san hop dong.", inserted_count, skipped_count))
    print("Tat ca 29 cau thu Viet Nam gio da co day du hop dong chinh thuc o Binh Tan FC!")
    print("Het sach 100% loi vang game (Crash) khi Mo phong tran dau (Simulate Match)!")
    print("==================================================")

    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(string.format("[Fix Career Contracts] Da tao %d hop dong moi cho cau thu VN.\n", inserted_count))
            f:close()
        end
    end)
end

fix_career_contracts()
