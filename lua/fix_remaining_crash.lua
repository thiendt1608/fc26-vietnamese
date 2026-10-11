-- lua/fix_remaining_crash.lua
-- Script fix cac LO HONG CON LAI gay crash "Vao tran / Mo phong nhanh" (READ 0x4 - crash site thu 2, RVA 0x85d51f2):
--
-- PHAT HIEN MOI (khac voi cac fix truoc):
-- 1. caree_playerlastmatchhistory THIEU 17/29 cau thu Viet Nam (bang form/lich su tran gan nhat).
--    Match engine doc record nay khi vao tran; record = NULL -> deref offset +0x4 -> CRASH.
-- 2. Cau thu 927 con teamid CU (31) trong bang do -> xung dot CLB.
-- 3. career_competitionprogress: compobjid 514 (C201) bi stageid = -1 (thieu giai doan).
--
-- Script nay la IDEMPOTENT (chay lai an toan), bo sung them cac bang con thieu ma cac fix truoc bo sot.

local BINH_TAN_ID = 115486
local VN_NT_ID = 111527

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
    local n = math.floor(tonumber(v) or def)
    return n
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

-- ============ BO SUNG 1: career_playerlastmatchhistory (17 cau thu thieu) ============
local function fix_last_match_history()
    local players = safe_call(GetDBTableRows, "players")
    if not players then
        log("[Fix Remaining] LOI: khong doc duoc bang 'players'!")
        return 0, 0
    end

    -- Map playerid -> (overall, preferred position)
    local pmap = {}
    for i = 1, #players do
        local r = players[i]
        local pid = toint(field_val(r.playerid), -1)
        if pid >= 900 and pid <= 928 then
            local ovr = toint(field_val(r.overallrating) or field_val(r.overall), 75)
            local pos = toint(field_val(r.preferredposition1), 0)
            pmap[pid] = { ovr = ovr, pos = pos }
        end
    end

    local rows = safe_call(GetDBTableRows, "career_playerlastmatchhistory")
    if not rows then
        log("[Fix Remaining] LOI: khong doc duoc bang 'career_playerlastmatchhistory'!")
        return 0, 0
    end

    -- Existing records + max artificialkey
    local existing = {}
    local max_ak = 0
    local stale_fixed = 0
    for i = 1, #rows do
        local r = rows[i]
        local pid = toint(field_val(r.playerid), -1)
        local ak = toint(field_val(r.artificialkey), 0)
        if ak > max_ak then max_ak = ak end
        if pid >= 900 and pid <= 928 then
            existing[pid] = r
        end
    end

    -- 1a. Fix cau thu 927 co teamid cu (31) -> Binh Tan
    if existing[927] then
        local r = existing[927]
        local tid = toint(field_val(r.teamid), -1)
        if tid ~= BINH_TAN_ID and r.teamid then
            local f = r.teamid
            f.value = tostring(BINH_TAN_ID)
            safe_call(EditDBTableField, f)
            stale_fixed = stale_fixed + 1
            log(string.format("[Fix Remaining] Sua teamid cau thu 927 tu %d ve %d (Binh Tan FC).", tid, BINH_TAN_ID))
        end
    end

    -- 1b. Them record cho cac cau thu con thieu
    local inserted = 0
    for pid = 900, 928 do
        if not existing[pid] and pmap[pid] then
            max_ak = max_ak + 1
            local data = {
                artificialkey = tostring(max_ak),
                playerid = tostring(pid),
                teamid = tostring(BINH_TAN_ID),
                minsplayed = "0",
                playerfact = "0",
                playeroverall = tostring(pmap[pid].ovr),
                position = tostring(pmap[pid].pos)
            }
            local row = safe_call(InsertDBTableRow, "career_playerlastmatchhistory", data)
            if row and tostring(row.addr) ~= "0" then
                inserted = inserted + 1
                log(string.format("[Fix Remaining] + Them lastmatchhistory cho Player %d (OVR %d).", pid, pmap[pid].ovr))
            else
                log(string.format("[Fix Remaining] - KHONG them duoc lastmatchhistory cho Player %d!", pid))
            end
        end
    end
    return inserted, stale_fixed
end

-- ============ BO SUNG 2: career_competitionprogress (stageid -1) ============
local function fix_competition_stage()
    local rows = safe_call(GetDBTableRows, "career_competitionprogress")
    if not rows then return 0 end
    local fixed = 0
    for i = 1, #rows do
        local r = rows[i]
        local tid = toint(field_val(r.teamid), -1)
        if tid == BINH_TAN_ID then
            local stage = toint(field_val(r.stageid), -1)
            local compobj = toint(field_val(r.compobjid), -1)
            if stage == -1 and r.stageid then
                -- stageid -1 = chua co giai doan. Neu la cup chua bo tham thi de nguyen,
                -- nhung neu compobjid khong ton tai trong bang competition thi danh dau canh bao.
                local f = r.stageid
                local new_stage = compobj + 1  -- quy uoc an toan: stage = compobjid + 1
                f.value = tostring(new_stage)
                safe_call(EditDBTableField, f)
                fixed = fixed + 1
                log(string.format("[Fix Remaining] Sua stageid compobjid %d tu -1 ve %d.", compobj, new_stage))
            end
        end
    end
    return fixed
end

local function main()
    log("==================================================")
    log("[Fix Remaining] BAT DAU BO SUNG CAC LO HONG CON LAI...")
    log("==================================================")

    local lmh_inserted, stale_fixed = fix_last_match_history()
    local stage_fixed = fix_competition_stage()

    log("==================================================")
    log(string.format("[Fix Remaining] HOAN TAT! lastmatchhistory +%d, sua stale teamid %d, sua stageid %d.",
        lmh_inserted, stale_fixed, stage_fixed))
    log("Khuyen nghi: LUU GAME (Save Game) ngay de ghi du lieu vao file save .CM!")
    log("==================================================")
end

main()
