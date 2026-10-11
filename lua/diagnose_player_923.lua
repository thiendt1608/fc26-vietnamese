-- lua/diagnose_player_923.lua
-- SCRIPT CHAN DOAN: xac dinh nguyen nhan crash site 2 (RVA 0x85d51f2) cua player 923 (Dinh Bac).
--
-- Bang chung da co:
--  * Crash = "movsx rax, byte ptr [r8+4]" voi r8=NULL -> doc "key attribute index" (1 byte).
--  * R15 = 923 (Dinh Bac) -> crash khi tinh rating/phong do cua 923.
--  * MOI bang career deu 29/29 (contract, growth, ranking, lastgrowth, lastmatchhistory, matchrating).
--  * position 27 (ST) va role1=42 deu la gia tri hop le.
--
-- 2 diem KHAC BIET duy nhat cua 923 so voi 10 starter con lai:
--  1. position 27 (ST) - buff script da DOI tu 25 (LW) -> 27 (ST).
--  2. role1=42 (duy nhat trong doi hinh; cac tien dao khac co role1 131/141).
--
-- GIAI PHAP TEST: Dua 923 ve giong mot tien dao DANG CHAY (921 - Xuan Son):
--  role1 = 141, role2 = 44, preferredposition1 = 25.
-- Neu crash het hoac doi player -> dung huong. Neu van crash -> thu benching 923.

local PID = 923
local TARGET_ROLE1 = 141
local TARGET_ROLE2 = 44
local TARGET_POS1 = 25

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
    safe_call(EditDBTableField, field)
    return true
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
    log("[Diagnose 923] BAT DAU SUA PLAYER 923 (Dinh Bac)...")
    log("==================================================")

    -- 1. Sua role1/role2/preferredposition1 trong bang 'players'
    local players = safe_call(GetDBTableRows, "players")
    local fixed = {}
    if players then
        for i = 1, #players do
            local r = players[i]
            local pid = toint(fval(r.playerid), -1)
            if pid == PID then
                if commit(r.role1, TARGET_ROLE1) then fixed.role1 = TARGET_ROLE1 end
                if commit(r.role2, TARGET_ROLE2) then fixed.role2 = TARGET_ROLE2 end
                if commit(r.preferredposition1, TARGET_POS1) then fixed.pos1 = TARGET_POS1 end
            end
        end
    end

    -- 2. Sua position trong bang 'teamplayerlinks' (ca CLB lan DTQG)
    local tpl = safe_call(GetDBTableRows, "teamplayerlinks")
    if tpl then
        for i = 1, #tpl do
            local r = tpl[i]
            local pid = toint(fval(r.playerid), -1)
            if pid == PID then
                if commit(r.position, TARGET_POS1) then fixed.tpl_position = TARGET_POS1 end
            end
        end
    end

    log(string.format("[Diagnose 923] Da sua: role1=%s, role2=%s, pos=%s, tpl_pos=%s.",
        tostring(fixed.role1 or "?"), tostring(fixed.role2 or "?"),
        tostring(fixed.pos1 or "?"), tostring(fixed.tpl_position or "?")))
    log("[Diagnose 923] LUU GAME ngay roi thu mo phong tran dau lai!")
    log("[Diagnose 923] Neu HET crash -> role/position 923 la nguyen nhan.")
    log("[Diagnose 923] Neu VAN crash -> thu doi 923 ra khoi doi hinh chinh (bench).")
    log("==================================================")
end

main()
