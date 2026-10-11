-- lua/move_script_players_to_free_agents.lua
-- Script chuyen 10 cau thu "chuyen nhuong bang script" (jersey 99, gay crash khi da chinh)
-- sang FREE AGENTS (teamid 111592) de don dep doi hinh Binh Tan FC.
--
-- NGUYEN NHAN (da xac nhan): cau thu them bang script thieu object runtime -> crash khi da chinh.
-- GIAI PHAP: dua ho ra Free Agents (khoi Binh Tan), sau do co the chuyen lai DUNG CACH bang game UI.
--
-- LUU Y LOI QUA KHU (da tranh triet de):
--  1. CHI doi link CLB (teamid 115486) -> Free Agents. KHONG DUNG vao link DTQG (teamid 111527).
--  2. Xoa slot khoi cm_teamsheets bang cach dat ve -1 (KHONG tao duplicate).
--  3. Cap nhat hop dong (career_playercontract) ve Free Agents de dong bo.

local BINH_TAN_ID = 115486
local FREE_AGENTS_ID = 111592
local VN_NT_ID = 111527

-- 10 cau thu chuyen nhuong bang script (jerseynumber = 99)
local SCRIPT_PLAYERS = {
    [902] = true, [904] = true, [909] = true, [919] = true, [920] = true,
    [923] = true, [924] = true, [925] = true, [926] = true, [927] = true,
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
    log("[Move to FA] BAT DAU CHUYEN CAU THU SCRIPT SANG FREE AGENTS...")
    log("==================================================")

    local links_fixed = 0
    local nt_kept = 0
    local sheet_removed = 0
    local contract_fixed = 0

    -- BUOC 1: teamplayerlinks - doi link CLB (115486) -> Free Agents (111592), KHONG dung NT (111527)
    local tpl = safe_call(GetDBTableRows, "teamplayerlinks")
    if tpl then
        for i = 1, #tpl do
            local r = tpl[i]
            local pid = toint(fval(r.playerid), -1)
            local tid = toint(fval(r.teamid), -1)
            if SCRIPT_PLAYERS[pid] then
                if tid == BINH_TAN_ID then
                    if commit(r.teamid, FREE_AGENTS_ID) then
                        links_fixed = links_fixed + 1
                        log(string.format("[Move to FA] Player %d: link CLB 115486 -> Free Agents (111592).", pid))
                    end
                elseif tid == VN_NT_ID then
                    -- GIU NGUYEN link DTQG (Viet Nam 111527)
                    nt_kept = nt_kept + 1
                end
            end
        end
    else
        log("[Move to FA] LOI: khong doc duoc teamplayerlinks!")
    end

    -- BUOC 2: cm_teamsheets - xoa cac slot cua cau thu script (dat ve -1)
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
                        if SCRIPT_PLAYERS[pid] then
                            if commit(field, -1) then
                                sheet_removed = sheet_removed + 1
                                log(string.format("[Move to FA] cm_teamsheets slot %d: %d -> -1.", slot, pid))
                            end
                        end
                    end
                end
            end
        end
    else
        log("[Move to FA] LOI: khong doc duoc cm_teamsheets!")
    end

    -- BUOC 3: career_playercontract - dong bo teamid ve Free Agents
    local cpc = safe_call(GetDBTableRows, "career_playercontract")
    if cpc then
        for i = 1, #cpc do
            local r = cpc[i]
            local pid = toint(fval(r.playerid), -1)
            local tid = toint(fval(r.teamid), -1)
            if SCRIPT_PLAYERS[pid] and tid == BINH_TAN_ID then
                if commit(r.teamid, FREE_AGENTS_ID) then
                    contract_fixed = contract_fixed + 1
                    log(string.format("[Move to FA] Player %d: hop dong teamid -> Free Agents.", pid))
                end
            end
        end
    else
        log("[Move to FA] LOI: khong doc duoc career_playercontract!")
    end

    log("==================================================")
    log(string.format("[Move to FA] HOAN TAT! link CLB doi %d, link DTQG giu %d, slot xoa %d, hop dong dong bo %d.",
        links_fixed, nt_kept, sheet_removed, contract_fixed))
    log("[Move to FA] LUU GAME ngay, roi THOAT ra menu chinh va VAO LAI Career de game nap lai du lieu!")
    log("==================================================")
end

main()
