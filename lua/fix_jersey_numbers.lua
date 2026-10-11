-- lua/fix_jersey_numbers.lua
-- Script gan so ao hop le cho 10 cau thu chuyen nhuong bang script (dang co jerseynumber = 99 placeholder).
--
-- PHAT HIEN (da xac nhan): crash site 2 (RVA 0x85d51f2) chi xay ra voi cau thu "chuyen nhuong bang script"
--  * Crash chuyen tu 923 (Dinh Bac) -> 925 (Nguyen Van Vi) sau khi doi doi hinh.
--  * Diem khac biet DUY NHAT giua cau thu script vs cau thu goc: jerseynumber = 99 (placeholder).
--
-- GIAI PHAP TEST: gan so ao duy nhat, hop le cho 10 cau thu script (ca link CLB lan DTQG).

local BINH_TAN_ID = 115486
local VN_NT_ID = 111527

-- mapping playerid -> so ao moi (tranh trung voi so ao cau thu goc: 3,6,7,10,18,19,20,21,22,25,26,27,29,30,31,32,33,34,35)
local NEW_JERSEY = {
    [902] = 2,   -- Ho Tan Tai (CB)
    [904] = 4,   -- Nguyen Trong Dai (CM)
    [909] = 9,   -- Cong Phuong (LW)
    [919] = 1,   -- Bui Tan Truong (GK)
    [920] = 12,  -- Phi Minh Long (GK)
    [923] = 11,  -- Dinh Bac (ST)
    [924] = 14,  -- Khuat Van Khang (LM)
    [925] = 5,   -- Nguyen Van Vi (LB)
    [926] = 13,  -- Nguyen Nhat Minh (CB)
    [927] = 8,   -- Do Phi Long (ST)
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
    log("[Fix Jersey] BAT DAU GAN SO AO HOP LE CHO CAU THU SCRIPT...")
    log("==================================================")

    local tpl = safe_call(GetDBTableRows, "teamplayerlinks")
    if not tpl then
        log("[Fix Jersey] LOI: khong doc duoc teamplayerlinks!")
        return
    end

    local fixed = 0
    for i = 1, #tpl do
        local r = tpl[i]
        local pid = toint(fval(r.playerid), -1)
        local tid = toint(fval(r.teamid), -1)
        if NEW_JERSEY[pid] and (tid == BINH_TAN_ID or tid == VN_NT_ID) then
            local cur = toint(fval(r.jerseynumber), -1)
            if cur == 99 or cur ~= NEW_JERSEY[pid] then
                if commit(r.jerseynumber, NEW_JERSEY[pid]) then
                    fixed = fixed + 1
                    log(string.format("[Fix Jersey] Player %d (team %d): jersey %d -> %d.", pid, tid, cur, NEW_JERSEY[pid]))
                end
            end
        end
    end

    log(string.format("[Fix Jersey] HOAN TAT! Da sua %d link.", fixed))
    log("[Fix Jersey] LUU GAME ngay roi thu mo phong tran dau lai!")
    log("==================================================")
end

main()
