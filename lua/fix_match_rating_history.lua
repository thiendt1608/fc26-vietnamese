-- lua/fix_match_rating_history.lua
-- Script fix crash site 2 (RVA 0x85d51f2, "movsx rax, byte ptr [r8+4]" voi r8=NULL, xu ly player 923).
--
-- PHAT HIEN (tu disassembly RAM da giai ma + register tai crash):
--  * R15 = 923 (Dinh Bac) -> crash khi tinh phong do/rating cua player 923.
--  * r8 = NULL -> mot struct lookup tra ve NULL.
--  * So sanh toan bo 236 bang: 'career_playermatchratinghistory' la bang DUY NHAT
--    ma 923 (va 29 cau thu VN) THIEU, trong khi cac cau thu ngoai da da duoc (460001...) CO.
--  => Match Engine doc lich su diem tran de tinh phong do; khong co record -> NULL -> crash.
--
-- GIAI PHAP: Them 1 record 'career_playermatchratinghistory' trung tinh (rating 6) cho toan bo
--            29 cau thu Viet Nam (idempotent - chi them cho cau thu CHUA co record).

local BINH_TAN_ID = 115486

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function field_val(f)
    return (type(f) == "table" and f.value) or f
end

local function toint(v, def)
    return math.floor(tonumber(v) or def)
end

local function log(msg)
    print(msg)
    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(msg .. "\n")
            f:close()
        end
    end)
end

local function main()
    log("==================================================")
    log("[Fix Rating History] BAT DAU BO SUNG LICH SU DIEM TRAN...")
    log("==================================================")

    -- 1. Doc bang players de lay overall + preferred position
    local players = safe_call(GetDBTableRows, "players")
    if not players then
        log("[Fix Rating History] LOI: khong doc duoc bang 'players'!")
        return
    end

    local pmap = {}
    for i = 1, #players do
        local r = players[i]
        local pid = toint(field_val(r.playerid), -1)
        if pid >= 900 and pid <= 928 then
            local pos = toint(field_val(r.preferredposition1), 0)
            pmap[pid] = pos
        end
    end

    -- 2. Doc bang career_playermatchratinghistory
    local rows = safe_call(GetDBTableRows, "career_playermatchratinghistory")
    if not rows then
        log("[Fix Rating History] LOI: khong doc duoc bang 'career_playermatchratinghistory'!")
        return
    end

    local existing = {}
    local max_ak = 0
    local latest_date = 20260801
    for i = 1, #rows do
        local r = rows[i]
        local pid = toint(field_val(r.playerid), -1)
        local ak = toint(field_val(r.artificialkey), 0)
        local dt = toint(field_val(r.date), 0)
        if ak > max_ak then max_ak = ak end
        if dt > latest_date then latest_date = dt end
        if pid >= 900 and pid <= 928 then
            existing[pid] = true
        end
    end

    -- 3. Them record trung tinh cho cac cau thu VN chua co
    local inserted = 0
    local skipped = 0
    for pid = 900, 928 do
        if existing[pid] then
            skipped = skipped + 1
        else
            max_ak = max_ak + 1
            local pos = pmap[pid] or 0
            local data = {
                artificialkey = tostring(max_ak),
                date = tostring(latest_date),
                minsplayed = "90",
                playerid = tostring(pid),
                position = tostring(pos),
                rating = "6"
            }
            local row = safe_call(InsertDBTableRow, "career_playermatchratinghistory", data)
            if row and tostring(row.addr) ~= "0" then
                inserted = inserted + 1
                log(string.format("[Fix Rating History] + Them rating history cho Player %d (rating 6, pos %d).", pid, pos))
            else
                log(string.format("[Fix Rating History] - KHONG them duoc rating history cho Player %d!", pid))
            end
        end
    end

    log("==================================================")
    log(string.format("[Fix Rating History] HOAN TAT! Da them %d record, %d cau thu da co san.", inserted, skipped))
    log("Khuyen nghi: LUU GAME (Save Game) ngay, sau do thu mo phong tran dau lai!")
    log("==================================================")
end

main()
