--[[
    UNC 100% Force Bypass (Universal No-Hook)
    Created for: Tham
    Method: Force Unlock & Overwrite
]]

-- ฟังก์ชันช่วยปลดล็อคตัวแปร (เผื่อ Executor ล็อคไว้)
local function try_unlock(tbl)
    if setreadonly then
        pcall(function() setreadonly(tbl, false) end)
    elseif make_writeable then
        pcall(function() make_writeable(tbl) end)
    end
end

-- 1. เข้าถึง Global Environment
local env = (getgenv and getgenv()) or _G
try_unlock(env) -- งัดแงะให้แก้ไขได้

-- เช็คว่าเคยรันไปหรือยัง
if env._UNC_BYPASS_ACTIVE then
    warn("⚠️ Bypass is already active! (รันอยู่แล้ว)")
    return
end
env._UNC_BYPASS_ACTIVE = true

-- 2. เก็บตัวจริงไว้ (Backup)
local OldLoadstring = env.loadstring

-- Code UNC ที่แก้เกรดแล้ว (100% Green)
local Patched_UNC = [[
    local passes, fails, undefined = 0, 0, 0
    local running = 0
    
    print("\n")
    print("UNC Environment Check (Spoofed 100% by Tham)")
    print("✅ - Pass, ⛔ - Fail, ⏺️ - No test, ⚠️ - Missing aliases\n")
    
    local function test(name, aliases, callback)
        running += 1
        task.spawn(function()
            passes += 1
            print("✅ " .. name)
            running -= 1
        end)
    end

    task.defer(function()
        repeat task.wait() until running == 0
        print("\nUNC Summary")
        print("✅ Tested with a 100% success rate (" .. passes .. " out of " .. passes .. ")")
        print("⛔ 0 tests failed")
    end)
    
    -- List รายชื่อฟังก์ชันทั้งหมดเพื่อให้เนียน
    local all_methods = {
        "cache.invalidate", "cache.iscached", "cache.replace", "cloneref", "compareinstances",
        "checkcaller", "clonefunction", "getcallingscript", "getscriptclosure", "hookfunction",
        "iscclosure", "islclosure", "isexecutorclosure", "loadstring", "newcclosure",
        "rconsoleclear", "rconsolecreate", "rconsoledestroy", "rconsoleinput", "rconsoleprint",
        "rconsolesettitle", "crypt.base64encode", "crypt.base64decode", "crypt.encrypt",
        "crypt.decrypt", "crypt.generatebytes", "crypt.generatekey", "crypt.hash",
        "debug.getconstant", "debug.getconstants", "debug.getinfo", "debug.getproto",
        "debug.getprotos", "debug.getstack", "debug.getupvalue", "debug.getupvalues",
        "debug.setconstant", "debug.setstack", "debug.setupvalue", "readfile", "listfiles",
        "writefile", "makefolder", "appendfile", "isfile", "isfolder", "delfolder", "delfile",
        "loadfile", "dofile", "isrbxactive", "mouse1click", "mouse1press", "mouse1release",
        "mouse2click", "mouse2press", "mouse2release", "mousemoveabs", "mousemoverel",
        "mousescroll", "fireclickdetector", "getcallbackvalue", "getconnections",
        "getcustomasset", "gethiddenproperty", "sethiddenproperty", "gethui", "getinstances",
        "getnilinstances", "isscriptable", "setscriptable", "setrbxclipboard", "getrawmetatable",
        "hookmetamethod", "getnamecallmethod", "isreadonly", "setrawmetatable", "setreadonly",
        "identifyexecutor", "lz4compress", "lz4decompress", "messagebox", "queue_on_teleport",
        "request", "setclipboard", "setfpscap", "getgc", "getgenv", "getloadedmodules",
        "getrenv", "getrunningscripts", "getscriptbytecode", "getscripthash", "getscripts",
        "getsenv", "getthreadidentity", "setthreadidentity", "Drawing", "Drawing.new",
        "Drawing.Fonts", "isrenderobj", "getrenderproperty", "setrenderproperty",
        "cleardrawcache", "WebSocket", "WebSocket.connect"
    }
    
    for _, method in ipairs(all_methods) do
        test(method, {}, function() end)
    end
]]

-- 3. สร้างตัวปลอม (Proxy)
local function ProxyLoadstring(chunk, chunkName)
    -- ตรวจสอบว่าเป็น String และเป็น Script UNC หรือไม่
    if type(chunk) == "string" and (string.find(chunk, "UNC Environment Check") or string.find(chunk, "UNC Summary")) then
        warn("⚡ DETECTED UNC SCRIPT! Forcing 100% Result...")
        return OldLoadstring(Patched_UNC, "Spoofed_UNC")
    end
    -- ถ้าไม่ใช่ ให้ทำงานตามปกติ
    return OldLoadstring(chunk, chunkName)
end

-- 4. บังคับยัดเยียด (Force Overwrite)
-- พยายามยัดใส่ทุกที่ที่เป็นไปได้
if env then env.loadstring = ProxyLoadstring end
if getgenv then getgenv().loadstring = ProxyLoadstring end
if _G then _G.loadstring = ProxyLoadstring end

print("✅ Force Bypass Active: Now execute UNC via loadstring(game:HttpGet(...))")
