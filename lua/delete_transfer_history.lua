-- lua/delete_transfer_history.lua
-- Xoa lich su chuyen nhuong (bang persistent_events) cua 29 cau thu Viet Nam (900-928).
--
-- VAN DE: sau khi chuyen cau thu VN sang Free Agents, game van hien "da nam trong CLB"
--        vi bang persistent_events van con cac su kien "-> Binh Tan (115486)".
--        Can xoa cac su kien nay de co the chuyen nhuong lai.
--
-- CACH LAM (thu theo thu tu):
--  1. DeleteDBTableRowByAddr(row.addr) - xoa dong theo dia chi (neu row co field .addr).
--  2. Fallback: dat eventid = -1 va team2id = -1 (lam vo hieu su kien) qua EditDBTableField.
--
-- IDEMPOTENT: chay lai lan 2 se khong con su kien nao de xoa (tu dong skip).

local BINH_TAN_ID = 115486
local PID_MIN = 900
local PID_MAX = 928

-- Cau thu DA DUOC chuyen nhuong DUNG CACH -> giu nguyen lich su (khong xoa).
local EXCLUDED = {
    [907] = true,  -- B H Viet Anh (Bui Hoang Viet Anh) - da chuyen nhuong dung cach
}

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function fval(f)
    return (type(f) == "table" and f.value) or f
end

local function toint(v, def)
    return math.floor(tonumber(v) or def)
end

local function commit(field, val)
    if not field then return false end
    field.value = tostring(val)
    local ok = safe_call(EditDBTableField, field)
    return ok ~= nil
end

local function log(msg)
    print(msg)
    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then f:write(msg .. "\n"); f:close() end
    end)
end

local function main()
    log("==================================================")
    log("[Delete Transfer History] BAT DAU XOA LICH SU CHUYEN NHUONG CUA CAU THU VN...")
    log("==================================================")

    local rows = safe_call(GetDBTableRows, "persistent_events")
    if not rows then
        log("[Delete Transfer History] LOI: khong doc duoc persistent_events!")
        return
    end

    local deleted = 0
    local invalidated = 0
    local skipped = 0

    for i = 1, #rows do
        local r = rows[i]
        local pid = toint(fval(r.player1id), -1)

        if pid >= PID_MIN and pid <= PID_MAX and not EXCLUDED[pid] then
            -- Thu xoa theo dia chi (row.addr)
            local addr = fval(r.addr)
            local del_ok = nil
            if addr then
                del_ok = safe_call(DeleteDBTableRowByAddr, addr)
            end

            if del_ok ~= nil and del_ok ~= false then
                deleted = deleted + 1
                log(string.format("[Delete Transfer History] Xoa dong su kien player %d (addr=%s).", pid, tostring(addr)))
            else
                -- Fallback: lam vo hieu su kien (dat team2id ve Free Agents, eventid ve -1)
                local inv = false
                if r.eventid and commit(r.eventid, -1) then inv = true end
                if r.team2id and commit(r.team2id, 111592) then inv = true end
                if inv then
                    invalidated = invalidated + 1
                    log(string.format("[Delete Transfer History] Lam vo hieu su kien player %d (eventid=-1, team2id=Free Agents).", pid))
                else
                    skipped = skipped + 1
                    log(string.format("[Delete Transfer History] KHONG xu ly duoc su kien player %d!", pid))
                end
            end
        end
    end

    log("==================================================")
    log(string.format("[Delete Transfer History] HOAN TAT! Da xoa %d dong, lam vo hieu %d dong, skip %d.", deleted, invalidated, skipped))
    log("[Delete Transfer History] LUU GAME ngay roi thu chuyen nhuong lai cau thu VN!")
    log("==================================================")
end

main()
