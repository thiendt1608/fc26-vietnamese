-- lua/move_all_script_vn_to_free_agents.lua
-- Script chuyen TOAN BO 29 cau thu Viet Nam (900-928) sang FREE AGENTS (111592).
--
-- LY DO: ca 29 cau thu VN deu co previousteam = 241 (Barcelona) -> tat ca deu duoc chuyen
--        bang script (Barcelona -> Binh Tan FC), khong chi 10 nguoi jersey 99. Cai nao
--        chuyen bang script deu thieu object runtime -> crash khi da chinh.
--
-- IDEMPOTENT (chay lai lan 2 AN TOAN): chi doi neu con dang o Binh Tan (115486).
--   * teamplayerlinks: chi doi link CLB (115486) -> Free Agents (111592). KHONG dung link DTQG (111527).
--   * cm_teamsheets: chi xoa slot neu con chua cau thu VN (dat ve -1).
--   * career_playercontract: chi doi neu con teamid 115486.
--
-- 29 cau thu VN: 900-928 (Dang Van Lam -> Nguyen Tai Loc).

local BINH_TAN_ID = 115486
local FREE_AGENTS_ID = 111592
local VN_NT_ID = 111527
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

local function is_vn(pid)
    return pid >= PID_MIN and pid <= PID_MAX
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
    log("[Move VN -> FA] BAT DAU CHUYEN TOAN BO 29 CAU THU VN SANG FREE AGENTS...")
    log("==================================================")

    local links_fixed = 0
    local links_skipped = 0
    local nt_kept = 0
    local sheet_removed = 0
    local contract_fixed = 0
    local contract_skipped = 0

    -- BUOC 1: teamplayerlinks - doi link CLB (115486) -> Free Agents (111592)
    --         KHONG dung link DTQG (111527). IDEMPOTENT: skip neu da la free agent.
    local tpl = safe_call(GetDBTableRows, "teamplayerlinks")
    if tpl then
        for i = 1, #tpl do
            local r = tpl[i]
            local pid = toint(fval(r.playerid), -1)
            local tid = toint(fval(r.teamid), -1)
            if is_vn(pid) then
                if tid == BINH_TAN_ID then
                    if commit(r.teamid, FREE_AGENTS_ID) then
                        links_fixed = links_fixed + 1
                        log(string.format("[Move VN -> FA] Player %d: link CLB 115486 -> Free Agents.", pid))
                    end
                elseif tid == VN_NT_ID then
                    nt_kept = nt_kept + 1  -- giu nguyen link DTQG Viet Nam
                elseif tid == FREE_AGENTS_ID then
                    links_skipped = links_skipped + 1  -- da la free agent, bo qua
                end
            end
        end
    else
        log("[Move VN -> FA] LOI: khong doc duoc teamplayerlinks!")
    end

    -- BUOC 2: cm_teamsheets - xoa slot cua cau thu VN (dat ve -1). IDEMPOTENT.
    local cm = safe_call(GetDBTableRows, "cm_teamsheets")
    if cm then
        for i = 1, #cm do
            local r = cm[i]
            local tid = toint(fval(r.teamid), -1)
            if tid == BINH_TAN_ID then
                for slot = 0, 51 do
                    local field = r["playerid" .. slot]
                    if field then
                        local pid = toint(fval(field), -1)
                        if is_vn(pid) then
                            if commit(field, -1) then
                                sheet_removed = sheet_removed + 1
                                log(string.format("[Move VN -> FA] cm_teamsheets slot %d: %d -> -1.", slot, pid))
                            end
                        end
                    end
                end
            end
        end
    else
        log("[Move VN -> FA] LOI: khong doc duoc cm_teamsheets!")
    end

    -- BUOC 3: career_playercontract - dong bo teamid ve Free Agents. IDEMPOTENT.
    local cpc = safe_call(GetDBTableRows, "career_playercontract")
    if cpc then
        for i = 1, #cpc do
            local r = cpc[i]
            local pid = toint(fval(r.playerid), -1)
            local tid = toint(fval(r.teamid), -1)
            if is_vn(pid) then
                if tid == BINH_TAN_ID then
                    if commit(r.teamid, FREE_AGENTS_ID) then
                        contract_fixed = contract_fixed + 1
                        log(string.format("[Move VN -> FA] Player %d: hop dong teamid -> Free Agents.", pid))
                    end
                elseif tid == FREE_AGENTS_ID then
                    contract_skipped = contract_skipped + 1
                end
            end
        end
    else
        log("[Move VN -> FA] LOI: khong doc duoc career_playercontract!")
    end

    log("==================================================")
    log(string.format("[Move VN -> FA] HOAN TAT! link CLB doi %d (skip %d da FA), link DTQG giu %d, slot xoa %d, hop dong doi %d (skip %d).",
        links_fixed, links_skipped, nt_kept, sheet_removed, contract_fixed, contract_skipped))
    log("[Move VN -> FA] LUU GAME ngay, THOAT ra menu chinh roi VAO LAI Career de game nap lai du lieu!")
    log("[Move VN -> FA] Script IDEMPOTENT - chay lai lan 2 se bao 'skip' (khong doi gi them).")
    log("==================================================")
end

main()
