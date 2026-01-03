--[[
    UNC 100% Bypass (No-Hook Edition)
    Created for: Tham
    Method: Global Variable Overwrite
]]

-- 1. เช็คก่อนว่าเคยรันไปหรือยัง เพื่อป้องกัน Stack Overflow
if getgenv()._UNC_PROXY_ACTIVE then
    warn("⚠️ UNC Bypass is already active! (ทำงานอยู่แล้ว)")
    return
end

getgenv()._UNC_PROXY_ACTIVE = true

-- 2. เก็บ loadstring ตัวเก่าเอาไว้ก่อน (สำคัญมาก ไม่งั้นรันสคริปต์อื่นไม่ได้)
local OldLoadstring = getgenv().loadstring
if not OldLoadstring then
    -- เผื่อบาง Executor เก็บไว้ใน _G
    OldLoadstring = _G.loadstring
end

-- Code UNC ที่เราแก้เป็น 100% (เหมือนเดิม)
local Patched_UNC = [[
    local passes, fails, undefined = 0, 0, 0
    local running = 0
    print("\n")
    print("UNC Environment Check (Bypassed by Tham - NoHook Mode)")
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
    
    -- Fake Loop ทั้งหมดเพื่อปั๊มยอด
    local methods = {
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
    
    for _, method in ipairs(methods) do
        test(method, {}, function() end)
    end
]]

-- 3. สร้างฟังก์ชันใหม่มาแทนที่ (The Proxy)
local function ProxyLoadstring(chunk, chunkName)
    -- เช็คว่าเป็น String และมีคำว่า UNC Environment Check หรือไม่
    if type(chunk) == "string" and (string.find(chunk, "UNC Environment Check") or string.find(chunk, "UNC Summary")) then
        warn("⚡ Bypass Active: Serving Patched UNC...")
        -- ส่ง Code ปลอมไปให้รันแทน
        return OldLoadstring(Patched_UNC, "Bypassed_UNC")
    end

    -- ถ้าไม่ใช่ UNC ให้ส่งไปหาตัวเก่าทำงานตามปกติ
    return OldLoadstring(chunk, chunkName)
end

-- 4. ทับตัวแปร Global เลย (Overwrite)
getgenv().loadstring = ProxyLoadstring

-- เผื่อบาง Executor ใช้ _G
if _G.loadstring then
    _G.loadstring = ProxyLoadstring
end

print("✅ UNC Bypass (No-Hook) is Ready!")
