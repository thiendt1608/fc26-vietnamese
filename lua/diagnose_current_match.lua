-- lua/diagnose_current_match.lua
-- Script chan doan chinh xac doi thu, doi hinh va nguyen nhan crash offset +0x4

MEMORY = require 'imports/core/common'
if not MEMORY then MEMORY = require 'imports/core/memory' end

local function safe_call(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function diagnose()
    print("==================================================")
    print("[Diagnose Match] BAT DAU CHAN DOAN TRAN DAU...")
    print("==================================================")

    -- 1. Kiem tra doi hinh Binh Tan FC (115486)
    local BINH_TAN_ID = 115486
    local cm_ts = safe_call(GetDBTableRows, "cm_teamsheets")
    local bt_sheet = nil
    if cm_ts then
        for i = 1, #cm_ts do
            local r = cm_ts[i]
            local tid = math.floor(tonumber((type(r.teamid) == "table" and r.teamid.value) or r.teamid) or -1)
            if tid == BINH_TAN_ID then
                bt_sheet = r
                break
            end
        end
    end

    if bt_sheet then
        print("[Diagnose Match] Tim thay cm_teamsheets cua Binh Tan FC:")
        local starters = {}
        for slot = 0, 10 do
            local f = bt_sheet["playerid" .. slot]
            local pid = math.floor(tonumber((type(f) == "table" and f.value) or f) or -1)
            table.insert(starters, string.format("Slot %d: %d", slot, pid))
        end
        print("  11 Da chinh: " .. table.concat(starters, ", "))
    else
        print("[Diagnose Match] [!] CANH BAO: KHONG TIM THAY cm_teamsheets cua Binh Tan FC!")
    end

    -- 2. Kiem tra formations cua Binh Tan FC
    local formations = safe_call(GetDBTableRows, "formations")
    local bt_form = nil
    if formations then
        for i = 1, #formations do
            local r = formations[i]
            local tid = math.floor(tonumber((type(r.teamid) == "table" and r.teamid.value) or r.teamid) or -1)
            if tid == BINH_TAN_ID then
                bt_form = r
                break
            end
        end
    end

    if bt_form then
        local fid = math.floor(tonumber((type(bt_form.formationid) == "table" and bt_form.formationid.value) or bt_form.formationid) or -1)
        print(string.format("[Diagnose Match] Formation cua Binh Tan FC hop le: formationid = %d", fid))
    else
        print("[Diagnose Match] [!] CANH BAO NGUY HIEM: Binh Tan FC KHONG CO formation trong bang 'formations'!")
    end

    -- 3. Kiem tra lich thi dau va doi thu (Fixtures) qua FCEDataManager
    pcall(function()
        local IFCEInterface = safe_call(GetPlugin, ENUM_djb2IFCEInterface_CLSS)
        if IFCEInterface and MEMORY and MEMORY.ReadMultilevelPointer then
            local FCEDataManager = MEMORY:ReadMultilevelPointer(IFCEInterface, {0x18, 0x10, 0x08, 0x00})
            if FCEDataManager and FCEDataManager > 0 then
                local FixtureDataList = MEMORY:ReadPointer(FCEDataManager + 0x60)
                local StandingsDataList = MEMORY:ReadPointer(FCEDataManager + 0x88)
                print(string.format("[Diagnose Match] FCEDataManager = 0x%X", FCEDataManager))
            end
        end
    end)

    -- 4. Kiem tra giai dau cua Binh Tan FC trong leagueteamlinks
    local ltl = safe_call(GetDBTableRows, "leagueteamlinks")
    local found_ltl = false
    if ltl then
        for i = 1, #ltl do
            local r = ltl[i]
            local tid = math.floor(tonumber((type(r.teamid) == "table" and r.teamid.value) or r.teamid) or -1)
            if tid == BINH_TAN_ID then
                local lid = math.floor(tonumber((type(r.leagueid) == "table" and r.leagueid.value) or r.leagueid) or -1)
                print(string.format("[Diagnose Match] Binh Tan FC thuoc League ID: %d", lid))
                found_ltl = true
                break
            end
        end
    end
    if not found_ltl then
        print("[Diagnose Match] [!] CANH BAO: Binh Tan FC KHONG CO trong bang leagueteamlinks!")
    end

    print("==================================================")
end

diagnose()
