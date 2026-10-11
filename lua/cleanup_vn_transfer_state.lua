-- lua/cleanup_vn_transfer_state.lua
-- Don sach toan bo du lieu chuyen nhuong con sot cua 29 cau thu Viet Nam (900-928),
-- de ho tro thanh cau thu TU DO (Free Agents) sach se, khong con tro toi Binh Tan/Barcelona.
--
-- NGUYEN NHAN "da nam trong CLB" con sot:
--  1. career_playercontract: 29 hop dong cu (teamid=111592 Free Agents, status=0 active).
--     Cau thu tu do KHONG nen co hop dong -> xoa.
--  2. previousteam: 29 dong previousteamid = 241 (Barcelona) -> doi ve 111592 (Free Agents).
--
-- CACH LAM:
--  1. Xoa hop dong bang DeleteDBTableRowByAddr(row.addr); fallback: contract_status = -1.
--  2. Doi previousteamid 241 -> 111592 bang EditDBTableField.
--
-- IDEMPOTENT: chay lai lan 2 se khong con gi de xu ly.

local FREE_AGENTS_ID = 111592
local PID_MIN = 900
local PID_MAX = 928

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
    log("[Cleanup VN Transfer] BAT DAU DON SACH DU LIEU CHUYEN NHUONG CUA CAU THU VN...")
    log("==================================================")

    local cpc_deleted = 0
    local cpc_invalidated = 0
    local pt_reset = 0

    -- BUOC 1: Xoa hop dong (career_playercontract) cua cau thu VN
    local cpc = safe_call(GetDBTableRows, "career_playercontract")
    if cpc then
        for i = 1, #cpc do
            local r = cpc[i]
            local pid = toint(fval(r.playerid), -1)
            if pid >= PID_MIN and pid <= PID_MAX then
                local addr = fval(r.addr)
                local del_ok = nil
                if addr then
                    del_ok = safe_call(DeleteDBTableRowByAddr, addr)
                end
                if del_ok ~= nil and del_ok ~= false then
                    cpc_deleted = cpc_deleted + 1
                    log(string.format("[Cleanup VN Transfer] Xoa hop dong player %d (addr=%s).", pid, tostring(addr)))
                else
                    -- fallback: vo hieu hoa hop dong
                    if r.contract_status and commit(r.contract_status, -1) then
                        cpc_invalidated = cpc_invalidated + 1
                        log(string.format("[Cleanup VN Transfer] Vo hieu hop dong player %d (contract_status=-1).", pid))
                    end
                end
            end
        end
    else
        log("[Cleanup VN Transfer] LOI: khong doc duoc career_playercontract!")
    end

    -- BUOC 2: Doi previousteam 241 (Barcelona) -> Free Agents (111592)
    local pt = safe_call(GetDBTableRows, "previousteam")
    if pt then
        for i = 1, #pt do
            local r = pt[i]
            local pid = toint(fval(r.playerid), -1)
            local prev = toint(fval(r.previousteamid), -1)
            if pid >= PID_MIN and pid <= PID_MAX and prev == 241 then
                if commit(r.previousteamid, FREE_AGENTS_ID) then
                    pt_reset = pt_reset + 1
                    log(string.format("[Cleanup VN Transfer] Doi previousteam player %d: 241 -> Free Agents.", pid))
                end
            end
        end
    else
        log("[Cleanup VN Transfer] LOI: khong doc duoc previousteam!")
    end

    log("==================================================")
    log(string.format("[Cleanup VN Transfer] HOAN TAT! Xoa %d hop dong, vo hieu %d, doi previousteam %d.", cpc_deleted, cpc_invalidated, pt_reset))
    log("[Cleanup VN Transfer] LUU GAME ngay roi thu tim cau thu VN trong thi truong chuyen nhuong!")
    log("==================================================")
end

main()
