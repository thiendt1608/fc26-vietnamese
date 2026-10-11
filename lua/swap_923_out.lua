-- lua/swap_923_out.lua
-- TEST DUT DIEM: doi cau thu 923 (Dinh Bac - chuyen nhuong bang script) RA KHOI doi hinh chinh,
-- thay bang cau thu 917 (cau thu GOC cua save) dang o du bi.
--
-- Muc dich: xac nhan gia thuyet "cau thu chuyen nhuong bang script khi DA CHINH gay crash".
--  * 923 = Dinh Bac (chuyen nhuong bang script, DANG da chinh o slot 10).
--  * 917 = cau thu goc (da o du bi slot 13).
--
-- Sau khi doi:
--  * Neu HET crash -> nguyen nhan la "cau thu script da chinh". Workaround: khong cho ho da chinh.
--  * Neu van crash -> nguyen nhan khac (slot/position 27/ST hoac runtime).

local PID_OUT = 923
local PID_IN = 917

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
    log("[Swap 923] BAT DAU DOI 923 (Dinh Bac) RA KHOI DA CHINH...")
    log("==================================================")

    local cm = safe_call(GetDBTableRows, "cm_teamsheets")
    if not cm then
        log("[Swap 923] LOI: khong doc duoc cm_teamsheets!")
        return
    end

    local swapped = 0
    for i = 1, #cm do
        local r = cm[i]
        local tid = toint(fval(r.teamid), -1)
        if tid == 115486 then
            -- Buoc 1: tim slot 923 -> dat thanh 917 (da chinh)
            for slot = 0, 51 do
                local field = r["playerid" .. slot]
                if field and toint(fval(field), -1) == PID_OUT then
                    commit(field, PID_IN)
                    swapped = swapped + 1
                    log(string.format("[Swap 923] Slot %d (da chinh): 923 -> 917.", slot))
                end
            end
            -- Buoc 2: tim slot 917 DAU TIEN o du bi (slot>=11) -> dat thanh 923 (du bi)
            for slot = 11, 51 do
                local field = r["playerid" .. slot]
                if field and toint(fval(field), -1) == PID_IN then
                    commit(field, PID_OUT)
                    swapped = swapped + 1
                    log(string.format("[Swap 923] Slot %d (du bi): 917 -> 923.", slot))
                    break
                end
            end
        end
    end

    log(string.format("[Swap 923] HOAN TAT! Da doi %d slot.", swapped))
    log("[Swap 923] LUU GAME ngay roi thu mo phong tran dau lai!")
    log("==================================================")
end

main()
