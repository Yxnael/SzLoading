-- ===== SP HUB | MM2 v3.0 (FULL - SZDUNIS + TODAS AS FEATURES) =====
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera = Workspace:WaitForChild("Camera")

-- ===== GUARD (re-executar sem travar) =====
if getgenv and getgenv().SZHUB then
    pcall(function()
        if getgenv().SZHUB_GUI then getgenv().SZHUB_GUI:Destroy() end
        local lg = CoreGui:FindFirstChild("Loading SP Hub")
        if lg then lg:Destroy() end
    end)
    getgenv().SZHUB = nil
end
if getgenv then getgenv().SZHUB = true end
local ACTIVE = true

-- ===== DETECÇÃO MM2 =====
local IS_MM2 = (game.PlaceId == 142823291) or (tostring(game.GameId) == "66654135")

local function Notif(t, x)
    pcall(function() StarterGui:SetCore("SendNotification", { Title = t, Text = x, Duration = 5 }) end)
end

-- ===== IDIOMAS =====
local Languages = {
    { Code = "en", Name = "English", Display = "EN  English" },
    { Code = "pt", Name = "Brazil",  Display = "PT  Portugues" },
    { Code = "es", Name = "Espanola",Display = "ES  Espanola" },
    { Code = "ar", Name = "Arabic",  Display = "AR  Arabic" },
    { Code = "ru", Name = "Russian", Display = "RU  Russian" },
    { Code = "fr", Name = "France",  Display = "FR  Francais" },
    { Code = "de", Name = "Germany", Display = "DE  Deutsch" },
    { Code = "tr", Name = "Turkey",  Display = "TR  Turkce" }
}
local Tr = {
    en = { Skip = "Skip", Box = "Don't show this again", Select = "Select Language",
           Sp = "Speed", Fl = "Fly", Nc = "Noclip", EspR = "ESP Roles", EspG = "ESP Gun", Xr = "Xray",
           Sa = "Silent Aim", At = "Auto Shoot", Kill = "Kill Aura", Cf = "Coin Farm",
           Ag = "Auto Gun", Afk = "Anti AFK", Ac = "Auto Click", Ul = "Unload (Close All)",
           Loaded = "Loaded | RightShift = menu", Unloaded = "Unloaded", Unsupported = "Run only on MM2",
           Tabs = { "Mov", "Vis", "Aim", "Farm", "Tools" } },
    pt = { Skip = "Pular", Box = "Nao mostrar novamente", Select = "Escolha o Idioma",
           Sp = "Velocidade", Fl = "Voar", Nc = "Noclip", EspR = "ESP Papeis", EspG = "ESP Arma", Xr = "Xray",
           Sa = "Silent Aim", At = "Tiro Auto", Kill = "Kill Aura", Cf = "Farm Moedas",
           Ag = "Arma Auto", Afk = "Anti AFK", Ac = "Auto Click", Ul = "Descarregar (Fechar)",
           Loaded = "Carregado | RightShift = menu", Unloaded = "Descarregado", Unsupported = "Rodar apenas no MM2",
           Tabs = { "Mov", "Vis", "Aim", "Farm", "Ferr" } }
}
local DEFAULT_LANG = "en"
local function T(k)
    local t = Tr[DEFAULT_LANG] or Tr.en
    return t[k] or Tr.en[k] or k
end

-- ===== PERSISTÊNCIA =====
local HAS_FS = (type(readfile) == "function")
local function loadLang()
    if HAS_FS then pcall(function()
        local d = HttpService:JSONDecode(readfile("SZHUB_lang.json"))
        if type(d) == "table" and d.lang then DEFAULT_LANG = d.lang end
    end) end
end
local function saveLang(l)
    if HAS_FS then pcall(function() writefile("SZHUB_lang.json", HttpService:JSONEncode({ lang = l })) end) end
end

-- ===== ESTADO =====
local st = { sp=false, fl=false, nc=false, espR=false, espG=false, xr=false,
             sa=false, at=false, kill=false, cf=false, ag=false, afk=false, ac=false }

-- ===== HELPERS =====
local function HRP() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function alive() return LP:GetAttribute("Alive") ~= false end
local function has(p, n)
    local c = p.Character
    return (c and c:FindFirstChild(n)) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild(n) ~= nil)
end
local function findTarget(onlyKnife)
    local hrp = HRP(); if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and (not onlyKnife or has(p, "Knife")) then
            local c = p.Character
            local t = c and (c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso"))
            if t and t.Parent then
                local d = (t.Position - hrp.Position).Magnitude
                if d < bestD then bestD, best = d, t end
            end
        end
    end
    return best
end
local function pred(t)
    local hrp = HRP()
    local d = hrp and (t.Position - hrp.Position).Magnitude or 50
    return t.CFrame + (t.Velocity * (0.06 + d * 0.002))
end

-- ===== HOOKS SEGUROS (silent aim redireciona o mouse) =====
local HAS_CC = (type(checkcaller) == "function" and type(newcclosure) == "function")
local SAok, NCok = false, false
if HAS_CC then
    pcall(function()
        local oi
        local Mouse = LP:GetMouse()
        local function vm() if not Mouse or not Mouse.Parent then Mouse = LP:GetMouse() end return Mouse end
        oi = hookmetamethod(game, "__index", newcclosure(function(s, k)
            if getgenv().SZHUB and st.sa and (not checkcaller()) and rawequal(s, vm()) then
                if k == "Hit" then local t = findTarget(true); if t then return pred(t) end end
                if k == "Target" then return findTarget(true) end
            end
            return oi(s, k)
        end))
        SAok = true
    end)
    pcall(function()
        local on
        local SHOOT = { Shoot=true, Fire=true, GunFired=true, PlayerShoot=true, ShootRemote=true, FireRemote=true }
        on = hookmetamethod(game, "__namecall", newcclosure(function(s, ...)
            if getgenv().SZHUB and st.sa and (not checkcaller())
               and typeof(s) == "userdata" and s:IsA("RemoteEvent") and SHOOT[s.Name] then
                local a = { ... }; local t = findTarget(true)
                if t then
                    for i, v in ipairs(a) do
                        if typeof(v) == "CFrame" then a[i] = CFrame.new(t.Position) end
                        if typeof(v) == "Vector3" then a[i] = t.Position end
                    end
                    return on(s, unpack(a))
                end
            end
            return on(s, ...)
        end))
        NCok = true
    end)
end

-- ===== FLY KEYS =====
local keys = {}
local FLYKEYS = { W=true, A=true, S=true, D=true, Space=true, LeftShift=true }
UserInputService.InputBegan:Connect(function(i) if FLYKEYS[i.KeyCode.Name] then keys[i.KeyCode.Name] = true end end)
UserInputService.InputEnded:Connect(function(i) if FLYKEYS[i.KeyCode.Name] then keys[i.KeyCode.Name] = nil end end)

-- ===== ESP =====
local espTags, gunTag = {}, nil
local function setTag(p, txt, col, showName, dist)
    local h = p.Character and p.Character:FindFirstChild("Head")
    if not h then return end
    local e = espTags[p]
    if not e or not e.gui.Parent then
        local b = Instance.new("BillboardGui")
        b.Size = UDim2.new(0, 140, 0, 28); b.AlwaysOnTop = true
        b.MaxDistance = 800; b.StudsOffset = Vector3.new(0, 3, 0)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold; l.TextScaled = true; l.TextStrokeTransparency = .2
        e = { gui = b, label = l }; espTags[p] = e
    end
    e.gui.Parent = h
    e.label.Text = txt .. (showName and (" | " .. p.Name) or "") .. (dist and (" | " .. dist .. "m") or "")
    e.label.TextColor3 = col
end
local function clearESP()
    for _, e in pairs(espTags) do pcall(function() e.gui:Destroy() end) end
    espTags = {}
end
local function refreshESP()
    local hrp = HRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("Head")
            local dist = hrp and h and math.floor((h.Position - hrp.Position).Magnitude + .5) or nil
            if has(p, "Knife") then setTag(p, "ASSASSINO", Color3.fromRGB(255, 70, 70), true, dist)
            elseif has(p, "Gun") then setTag(p, "XERIFE", Color3.fromRGB(70, 160, 255), true, dist)
            else setTag(p, p.Name, Color3.fromRGB(0, 220, 120), false) end
        else
            local e = espTags[p]
            if e and e.gui.Parent then e.gui:Destroy() end
            espTags[p] = nil
        end
    end
end
local gunDropCache
local function gunDrop()
    if gunDropCache and gunDropCache.Parent then return gunDropCache end
    gunDropCache = Workspace:FindFirstChild("GunDrop", true)
    return gunDropCache
end
local function espGun(v)
    if gunTag then pcall(function() gunTag:Destroy() end); gunTag = nil end
    if not v then return end
    local g = gunDrop(); if not g then return end
    local part = g:IsA("BasePart") and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
    if part then
        local b = Instance.new("BillboardGui", part)
        b.Name = "SZGUN"; b.Size = UDim2.new(0, 100, 0, 24); b.AlwaysOnTop = true
        b.StudsOffset = Vector3.new(0, 1, 0)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold; l.TextScaled = true
        l.Text = "ARMA"; l.TextColor3 = Color3.fromRGB(255, 200, 60); l.TextStrokeTransparency = .2
        gunTag = b
    end
end

-- ===== NOCLIP =====
local myParts, myPartsCC = {}, {}
local function cacheMyParts(c)
    myParts = {}; myPartsCC = {}
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then myParts[#myParts + 1] = v; myPartsCC[v] = v.CanCollide end
    end
end

-- ===== XRAY =====
local xrayParts, xrayOn = {}, false
local function enableXray()
    xrayOn = true; xrayParts = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not (LP.Character and v:IsDescendantOf(LP.Character)) then
            v.LocalTransparencyModifier = .75; xrayParts[#xrayParts + 1] = v
        end
    end
end
local function disableXray()
    xrayOn = false
    for _, v in ipairs(xrayParts) do if v and v.Parent then v.LocalTransparencyModifier = 0 end end
    xrayParts = {}
end
Workspace.DescendantAdded:Connect(function(v)
    if xrayOn and v:IsA("BasePart") and not (LP.Character and v:IsDescendantOf(LP.Character)) then
        v.LocalTransparencyModifier = .75; xrayParts[#xrayParts + 1] = v
    end
end)
LP.CharacterAdded:Connect(function(c)
    task.wait(.5); cacheMyParts(c); clearESP()
    if st.nc then for _, v in ipairs(myParts) do if v and v.Parent then v.CanCollide = false end end end
end)
if LP.Character then cacheMyParts(LP.Character) end

-- ===== COIN FARM =====
local CF = { farming = false, collected = false, tw = nil, cool = 0, parts = {}, origCF = nil, coinStart = 0 }
local coinBoxCache
local function coinBox()
    if coinBoxCache and coinBoxCache.Parent then return coinBoxCache end
    coinBoxCache = Workspace:FindFirstChild("CoinContainer", true)
    return coinBoxCache
end
local function okCoin(cn)
    return cn and cn:GetAttribute("CoinID") == "Coin" and cn:FindFirstChild("TouchInterest") and cn.Transparency == 1
end
local function nearCoin()
    local hrp = HRP(); local b = coinBox()
    if not (hrp and b) then return nil end
    local n, d = nil, math.huge
    for _, cn in ipairs(b:GetChildren()) do
        if okCoin(cn) then
            local q = (cn.Position - hrp.Position).Magnitude
            if q < d then d, n = q, cn end
        end
    end
    return n
end
local function startFarm()
    local c = LP.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    CF.parts = {}
    for _, v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then CF.parts[v] = v.CanCollide end end
    for p, cc in pairs(CF.parts) do p.CanCollide = false end
    CF.origCF = hrp.CFrame
    hrp.CFrame = (hrp.CFrame - Vector3.new(0, 2.5, 0)) * CFrame.Angles(math.rad(90), 0, 0)
    hum.PlatformStand = true
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    CF.farming = true; CF.coinStart = os.clock()
end
local function stopFarm()
    CF.farming = false
    if CF.tw then CF.tw:Cancel(); CF.tw = nil end
    local c = LP.Character
    if c then
        for p, cc in pairs(CF.parts) do if p and p.Parent then p.CanCollide = cc end end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
            if CF.origCF then hrp.CFrame = CF.origCF end
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    CF.parts = {}; CF.origCF = nil
end
local function getR(n)
    local rm = ReplicatedStorage:FindFirstChild("Remotes")
    local gp = rm and rm:FindFirstChild("Gameplay")
    return gp and gp:FindFirstChild(n)
end
local CCr = getR("CoinCollected")
if CCr then CCr.OnClientEvent:Connect(function(tp, a, b) if tp == "Coin" then CF.collected = (tonumber(a) == tonumber(b)) end end) end
local RSt = getR("RoundStart")
if RSt then RSt.OnClientEvent:Connect(function() CF.collected = false end) end
local RE = getR("RoundEndFade")
if RE then RE.OnClientEvent:Connect(function() CF.collected = false; if CF.farming then stopFarm() end end) end

-- ===== UNLOAD =====
local function unload()
    ACTIVE = false
    stopFarm()
    if xrayOn then disableXray() end
    clearESP(); espGun(false)
    if getgenv then getgenv().SZHUB = nil end
    pcall(function()
        if getgenv and getgenv().SZHUB_GUI then getgenv().SZHUB_GUI:Destroy() end
        local lg = CoreGui:FindFirstChild("Loading SP Hub")
        if lg then lg:Destroy() end
    end)
    Notif("SP Hub", T("Unloaded"))
end

-- ===== MAIN LOOP =====
RunService.Heartbeat:Connect(function(dt)
    if not ACTIVE then return end
    pcall(function()
        local c = LP.Character
        local hrp = HRP()
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        -- Speed
        if hum then
            local ws = st.sp and 32 or 16
            if hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end
        end
        -- Fly
        if st.fl and hrp then
            local bv = hrp:FindFirstChild("SZBVF")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "SZBVF"; bv.MaxForce = Vector3.new(1e5, 1e5, 1e5); bv.Parent = hrp
            end
            local f = (keys.W and 1 or 0) - (keys.S and 1 or 0)
            local r = (keys.D and 1 or 0) - (keys.A and 1 or 0)
            local u = (keys.Space and 1 or 0) - (keys.LeftShift and 1 or 0)
            bv.Velocity = (Camera.CFrame.LookVector * f + Camera.CFrame.RightVector * r + Vector3.new(0, u, 0)) * 50
        elseif hrp then
            local bv = hrp:FindFirstChild("SZBVF")
            if bv then bv:Destroy() end
        end
        -- Noclip
        if st.nc then
            for i = 1, #myParts do local v = myParts[i]; if v and v.Parent then v.CanCollide = false end end
        end
        -- ESP
        if st.espR then refreshESP() else clearESP() end
        if st.espG and not (gunTag and gunTag.Parent) then espGun(true) end
        -- Auto Shoot
        if st.at then
            local g = (c and c:FindFirstChild("Gun")) or (LP.Backpack and LP.Backpack:FindFirstChild("Gun"))
            local t = findTarget(true)
            if g and t then
                if g.Parent ~= c and hum then hum:EquipTool(g) end
                g:Activate()
            end
        end
        -- Kill Aura
        if st.kill then
            local k = c and c:FindFirstChild("Knife")
            local hd = findTarget(false)
            if hrp and k and hd and hd.Parent then
                local r = hd.Parent:FindFirstChild("HumanoidRootPart")
                if r then
                    local goal = hrp.CFrame + hrp.CFrame.LookVector * 4
                    local spd = (goal.Position - r.Position).Magnitude / 0.15
                    r.AssemblyLinearVelocity = (goal.Position - r.Position).Unit * spd
                end
                local hp = k:FindFirstChild("Handle")
                local hdl = hd.Parent:FindFirstChild("Handle") or hd.Parent:FindFirstChild("Torso")
                if hp and hdl then
                    pcall(function()
                        if hdl:FindFirstChild("TouchInterest") then
                            firetouchinterest(hp, hdl, 0); firetouchinterest(hp, hdl, 1)
                        end
                    end)
                end
                k:Activate()
            end
        end
        -- Auto Gun
        if st.ag then
            local g = gunDrop()
            local part = g and (g:IsA("BasePart") and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart"))
            if alive() and part and part.Parent and hrp then
                hrp.CFrame = part.CFrame * CFrame.new(0, 0, 2)
                task.wait(.08)
                pcall(function()
                    for _, v in ipairs(g:GetDescendants()) do
                        if v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
                            firetouchinterest(hrp, v, 0); firetouchinterest(hrp, v, 1)
                        end
                    end
                end)
            end
        end
        -- Anti AFK
        if st.afk then
            pcall(function()
                local VU = game:GetService("VirtualUser")
                VU:CaptureController(); VU:ClickButton2(Vector2.new())
            end)
        end
        -- Auto Click
        if st.ac then
            pcall(function() mouse1click() end)
        end
    end)
end)
-- Silent Aim: lock de câmera (fallback sem hooks)
RunService.RenderStepped:Connect(function()
    if not ACTIVE then return end
    if st.sa and alive() then
        local t = findTarget(true)
        if t then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
        end
    end
end)
-- Coin Farm loop
RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    local hrp = HRP()
    if CF.farming and hrp then
        hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
    end
    if not st.cf then if CF.farming then stopFarm() end return end
    if not (hrp and alive()) then if CF.farming then stopFarm() end return end
    local cn = nearCoin()
    if cn and not CF.collected and not (CF.cool and os.clock() < CF.cool) then
        if CF.farming and (os.clock() - CF.coinStart) > 8 then
            CF.collected = true; CF.cool = os.clock() + 0.5; stopFarm(); return
        end
        local d = (cn.Position - hrp.Position).Magnitude
        if d > 5 then
            if not CF.farming then startFarm() end
            if CF.farming then
                if CF.tw then CF.tw:Cancel(); CF.tw = nil end
                local tw = TweenService:Create(hrp, TweenInfo.new(math.clamp(d / 23, .1, 6), Enum.EasingStyle.Linear), {
                    CFrame = CFrame.new(cn.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(math.rad(90), 0, 0) })
                CF.tw = tw; tw:Play()
                task.delay(math.clamp(d / 23, .1, 6) + 1.2, function()
                    if CF.tw == tw then CF.tw:Cancel(); CF.tw = nil; CF.cool = os.clock() + 1 end
                end)
            end
        else
            if cn.Parent then pcall(function() firetouchinterest(hrp, cn, 0); firetouchinterest(hrp, cn, 1) end) end
        end
    elseif CF.farming and (not cn or CF.collected) then
        stopFarm()
    end
end)

-- ===== CONFIG =====
local CFG_FILE = "SzDunamisConfig.json"
local function saveCfg() if HAS_FS then pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(st)) end) end end
local function loadCfg()
    if HAS_FS then pcall(function()
        local txt = readfile(CFG_FILE)
        if txt and #txt > 0 then
            local d = HttpService:JSONDecode(txt)
            if type(d) == "table" then
                for k, v in pairs(d) do if st[k] ~= nil and type(v) == "boolean" then st[k] = v end end
            end
        end
    end) end
end

-- ===== UI =====
loadLang()
local PUR = Color3.fromRGB(150, 20, 255)
local ROW = Color3.fromRGB(26, 26, 36)
local CARD = Color3.fromRGB(24, 24, 32)
local IMG = "rbxassetid://112169216"
local function mk(n, p, cls)
    local i = Instance.new(cls or "Frame", p); i.Name = n; return i
end
local function drag(frame, handle)
    local d, di, ds, sp = false
    local function upd(inp)
        local delta = inp.Position - ds
        frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ds = i.Position; sp = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
    end)
    UserInputService.InputChanged:Connect(function(i) if i == di and d then upd(i) end end)
    handle.InputEnded:Connect(function() d = false end)
end

-- Loading + menu
local oldUI = PlayerGui:FindFirstChild("Loading SP Hub") or CoreGui:FindFirstChild("Loading SP Hub")
if oldUI then oldUI:Destroy() end
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "Loading SP Hub"; LoadingGui.ResetOnSpawn = false
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() LoadingGui.Parent = CoreGui end)

local LoadingFrame = mk("LoadingScreen", LoadingGui)
LoadingFrame.BackgroundColor3 = ROW; LoadingFrame.BorderSizePixel = 0
LoadingFrame.AnchorPoint = Vector2.new(0.5, 0.5); LoadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingFrame.Size = UDim2.new(0, 0, 0, 0); LoadingFrame.ClipsDescendants = true; LoadingFrame.Visible = false
Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 20)
local LoadStroke = Instance.new("UIStroke", LoadingFrame); LoadStroke.Thickness = 2; LoadStroke.Color = Color3.fromRGB(60, 60, 80)
Instance.new("UIAspectRatioConstraint", LoadingFrame).AspectRatio = 1.3
local LogoImage = mk("LogoImage", LoadingFrame, "ImageLabel")
LogoImage.BackgroundTransparency = 1; LogoImage.BorderSizePixel = 0
LogoImage.Position = UDim2.new(0.05, 0, 0.05, 0); LogoImage.Size = UDim2.new(0.9, 0, 0.9, 0)
LogoImage.Image = "rbxassetid://95309586448728"; LogoImage.Visible = false

local MainFrame = mk("MainFrame", LoadingGui)
MainFrame.BackgroundColor3 = ROW; MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0.32, 0, 0.32, 0); MainFrame.ClipsDescendants = true; MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2; MainStroke.Color = Color3.fromRGB(60, 60, 80)
local MainRatio = Instance.new("UIAspectRatioConstraint", MainFrame); MainRatio.AspectRatio = 1.48
local Title = mk("Title", MainFrame, "TextLabel")
Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0.1, 0, 0.08, 0); Title.Size = UDim2.new(0.8, 0, 0.22, 0)
Title.Font = Enum.Font.FredokaOne; Title.Text = "SP Hub"; Title.TextColor3 = Color3.new(1, 1, 1); Title.TextScaled = true
local TitleGlow = mk("Glow", Title)
TitleGlow.BackgroundColor3 = PUR; TitleGlow.BorderSizePixel = 0
TitleGlow.Position = UDim2.new(0.4, 0, 1.05, 0); TitleGlow.Size = UDim2.new(0.2, 0, 0, 2)
local GameLabel = mk("GameName", MainFrame, "TextLabel")
GameLabel.BackgroundTransparency = 1; GameLabel.Position = UDim2.new(0.1, 0, 0.32, 0); GameLabel.Size = UDim2.new(0.8, 0, 0.16, 0)
GameLabel.Font = Enum.Font.FredokaOne; GameLabel.TextColor3 = Color3.fromRGB(180, 180, 200); GameLabel.TextScaled = true
GameLabel.Text = IS_MM2 and "Murder Mystery 2 v3.0" or (T("Unsupported") .. " | " .. tostring(game.PlaceId))
drag(MainFrame, Title)

-- ===== CONSTRUÇÃO DO GUI DE CHEATS =====
local function buildCheatGUI()
    local G = Instance.new("ScreenGui")
    G.Name = "SZHUB_GUI"; G.ResetOnSpawn = false; G.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local okP = pcall(function() G.Parent = PlayerGui end)
    if not okP then pcall(function() G.Parent = CoreGui end) end
    if getgenv then getgenv().SZHUB_GUI = G end

    local Pn = mk("Main", G)
    Pn.Position = UDim2.new(0.5, 0, 0.5, 0); Pn.Size = UDim2.new(0, 480, 0, 320)
    Pn.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
    Instance.new("UICorner", Pn).CornerRadius = UDim.new(0, 18)
    local PS = Instance.new("UIStroke", Pn); PS.Thickness = 2; PS.Color = PUR; PS.Transparency = .4
    local Bg = Instance.new("ImageLabel", Pn)
    Bg.Size = UDim2.new(1, 0, 1, 0); Bg.BackgroundTransparency = 1; Bg.Image = IMG
    Bg.ScaleType = Enum.ScaleType.Crop; Bg.ImageTransparency = .88
    local TB = mk("TB", Pn)
    TB.Size = UDim2.new(1, 0, .13, 0); TB.BackgroundTransparency = 1
    drag(Pn, TB)
    local Tt = mk("Title", TB, "TextLabel")
    Tt.Position = UDim2.new(.05, 0, .1, 0); Tt.Size = UDim2.new(.6, 0, .5, 0); Tt.BackgroundTransparency = 1
    Tt.Text = "SP Hub"; Tt.Font = Enum.Font.Michroma; Tt.TextScaled = true; Tt.TextColor3 = Color3.new(1, 1, 1)
    local Sub = mk("Sub", TB, "TextLabel")
    Sub.Position = UDim2.new(.05, 0, .58, 0); Sub.Size = UDim2.new(.6, 0, .35, 0); Sub.BackgroundTransparency = 1
    Sub.Text = "Murder Mystery 2"; Sub.Font = Enum.Font.GothamBold; Sub.TextScaled = true
    Sub.TextColor3 = Color3.fromRGB(150, 150, 170); Sub.TextXAlignment = Enum.TextXAlignment.Left
    local X = mk("X", TB, "TextButton")
    X.Size = UDim2.fromOffset(28, 28); X.AnchorPoint = Vector2.new(1, .5); X.Position = UDim2.new(.97, 0, .5, 0)
    X.BackgroundColor3 = Color3.fromRGB(255, 60, 60); X.Text = "X"; X.Font = Enum.Font.SourceSansBold
    X.TextScaled = true; X.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", X).CornerRadius = UDim.new(1, 0)
    X.MouseButton1Click:Connect(unload)

    local Tabs = T("Tabs")
    local TBs, Pgs = {}, {}
    local function Show(i)
        for j, pg in ipairs(Pgs) do pg.Visible = (j == i) end
        for j, b in ipairs(TBs) do
            TweenService:Create(b, TweenInfo.new(.2), { BackgroundColor3 = (j == i) and PUR or ROW }):Play()
            TweenService:Create(b, TweenInfo.new(.2), { TextColor3 = (j == i) and Color3.new(1, 1, 1) or Color3.fromRGB(190, 190, 210) }):Play()
        end
    end
    local TBr = mk("TBr", Pn)
    TBr.Position = UDim2.new(0, 0, .13, 0); TBr.Size = UDim2.new(1, 0, .08, 0); TBr.BackgroundTransparency = 1
    for i, nm in ipairs(Tabs) do
        local b = mk("Tab", TBr, "TextButton")
        b.Size = UDim2.new(.19, 0, .72, 0); b.Position = UDim2.new(.015 + (i - 1) * .198, 0, .14, 0)
        b.BackgroundColor3 = ROW; b.Text = nm; b.Font = Enum.Font.GothamBold; b.TextScaled = true
        b.TextColor3 = Color3.fromRGB(190, 190, 210)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        TBs[i] = b; b.MouseButton1Click:Connect(function() Show(i) end)
    end
    local Ct = mk("Ct", Pn)
    Ct.Position = UDim2.new(.04, 0, .23, 0); Ct.Size = UDim2.new(.92, 0, .74, 0); Ct.BackgroundTransparency = 1
    for i = 1, #Tabs do
        local pg = Instance.new("ScrollingFrame", Ct)
        pg.Size = UDim2.new(1, 0, 1, 0); pg.BackgroundTransparency = 1
        pg.ScrollingDirection = Enum.ScrollingDirection.Y; pg.ScrollBarThickness = 3
        pg.ScrollBarImageColor3 = PUR; pg.CanvasSize = UDim2.new(0, 0, 0, 0)
        Pgs[i] = pg
    end
    local function MkToggle(pg, label, state)
        local i = #pg:GetChildren() + 1
        local row = mk("T", pg)
        row.Size = UDim2.new(1, 0, 0, 56); row.Position = UDim2.new(0, 0, 0, 6 + (i - 1) * 66)
        row.BackgroundColor3 = ROW
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
        local lb = mk("L", row, "TextLabel")
        lb.Size = UDim2.new(.6, 0, 1, 0); lb.Position = UDim2.new(.06, 0, 0, 0); lb.BackgroundTransparency = 1
        lb.Text = label; lb.Font = Enum.Font.GothamBold; lb.TextScaled = true
        lb.TextXAlignment = Enum.TextXAlignment.Left; lb.TextColor3 = Color3.fromRGB(235, 235, 245)
        local sw = mk("S", row, "TextButton")
        sw.Size = UDim2.fromOffset(48, 26); sw.AnchorPoint = Vector2.new(1, .5); sw.Position = UDim2.new(.94, 0, .5, 0)
        sw.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
        local on = mk("ON", sw, "TextLabel")
        on.Size = UDim2.new(1, 0, 1, 0); on.BackgroundTransparency = 1; on.Text = "ON"
        on.Font = Enum.Font.GothamBold; on.TextScaled = true; on.TextColor3 = Color3.new(1, 1, 1)
        local off = mk("OFF", sw, "TextLabel")
        off.Size = UDim2.new(1, 0, 1, 0); off.BackgroundTransparency = 1; off.Text = "OFF"
        off.Font = Enum.Font.GothamBold; off.TextScaled = true; off.TextColor3 = Color3.fromRGB(130, 130, 150)
        local function set(v)
            st[state] = v
            TweenService:Create(sw, TweenInfo.new(.22), { BackgroundColor3 = v and PUR or Color3.fromRGB(24, 24, 32) }):Play()
            on.Visible = v; off.Visible = not v
            if not v then
                if state == "nc" then for i, p in ipairs(myParts) do if p and p.Parent and myPartsCC[p] then p.CanCollide = myPartsCC[p] end end end
                if state == "xr" then disableXray() end
                if state == "espR" then clearESP() end
                if state == "espG" then espGun(false) end
            else
                if state == "nc" then for _, p in ipairs(myParts) do if p and p.Parent then p.CanCollide = false end end end
                if state == "xr" then enableXray() end
                if state == "espR" then refreshESP() end
                if state == "espG" then espGun(true) end
            end
            saveCfg()
        end
        sw.MouseButton1Click:Connect(function() set(not st[state]) end)
        set(st[state])
    end
    local function MkBtn(pg, label, fn)
        local i = #pg:GetChildren() + 1
        local row = mk("B", pg, "TextButton")
        row.Size = UDim2.new(1, 0, 0, 76); row.Position = UDim2.new(0, 0, 0, 6 + (i - 1) * 86)
        row.BackgroundColor3 = ROW; row.Text = label; row.Font = Enum.Font.GothamBold; row.TextScaled = true
        row.TextColor3 = Color3.fromRGB(235, 235, 245)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
        row.MouseButton1Click:Connect(function() if fn then fn() end end)
    end
    MkToggle(Pgs[1], T("Sp"), "sp")
    MkToggle(Pgs[1], T("Fl"), "fl")
    MkToggle(Pgs[1], T("Nc"), "nc")
    MkToggle(Pgs[2], T("EspR"), "espR")
    MkToggle(Pgs[2], T("EspG"), "espG")
    MkToggle(Pgs[2], T("Xr"), "xr")
    MkToggle(Pgs[3], T("Sa"), "sa")
    MkToggle(Pgs[3], T("At"), "at")
    MkToggle(Pgs[3], T("Kill"), "kill")
    MkToggle(Pgs[4], T("Cf"), "cf")
    MkToggle(Pgs[4], T("Ag"), "ag")
    MkToggle(Pgs[4], T("Afk"), "afk")
    MkToggle(Pgs[5], T("Ac"), "ac")
    MkBtn(Pgs[5], T("Ul"), unload)
    for _, pg in ipairs(Pgs) do
        local h = 12
        for _, ch in ipairs(pg:GetChildren()) do h = h + (ch.Size.Y.Offset or 0) + 6 end
        pg.CanvasSize = UDim2.new(0, 0, 0, h)
    end
    Show(1)

    local Orb = mk("Orb", G, "TextButton")
    Orb.Size = UDim2.fromOffset(36, 36); Orb.AnchorPoint = Vector2.new(.5, .5); Orb.Position = UDim2.new(0, 36, 1, -46)
    Orb.BackgroundColor3 = Color3.new(0, 0, 0); Orb.Text = "sz"; Orb.Font = Enum.Font.Michroma; Orb.TextScaled = true
    Orb.TextColor3 = Color3.new(1, 1, 1); Orb.ZIndex = 5
    Instance.new("UICorner", Orb).CornerRadius = UDim.new(1, 0)
    local OS = Instance.new("UIStroke", Orb); OS.Thickness = 2; OS.Color = PUR
    local OG = mk("OG", G)
    OG.Size = UDim2.fromOffset(46, 46); OG.AnchorPoint = Vector2.new(.5, .5); OG.Position = Orb.Position
    OG.BackgroundColor3 = PUR; OG.BackgroundTransparency = .7; OG.ZIndex = 4
    Instance.new("UICorner", OG).CornerRadius = UDim.new(1, 0)
    local odrag, oisDrag, ostPt = false, false
    Orb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            odrag = true; ostPt = i.Position; oisDrag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if odrag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            if (i.Position - ostPt).Magnitude > 12 then oisDrag = true end
            if oisDrag then
                local p = UDim2.fromOffset(i.Position.X, i.Position.Y)
                Orb.Position = p; OG.Position = p
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if odrag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then
            odrag = false
            if not oisDrag and Pn then Pn.Visible = not Pn.Visible end
        end
    end)
    UserInputService.InputBegan:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.RightShift and Pn and ACTIVE then Pn.Visible = not Pn.Visible end
    end)
    Notif("SP Hub", T("Loaded"))
    return G
end

-- ===== TRANSIÇÃO (corrigida: não some mais) =====
local function openCheats()
    -- fecha o loading/idioma
    pcall(function() LoadingGui:Destroy() end)
    -- constrói o GUI de cheats; se der erro, mostra na tela
    local ok, err = pcall(buildCheatGUI)
    if not ok then
        warn("ERRO ao abrir cheats:", err)
        Notif("SP Hub ERRO", tostring(err))
    end
end

-- ===== MENU DE IDIOMA =====
if IS_MM2 then
    local Play = mk("Play", MainFrame, "TextButton")
    Play.Position = UDim2.new(0.3, 0, 0.62, 0); Play.Size = UDim2.new(0.4, 0, 0.22, 0)
    Play.Font = Enum.Font.GothamBold; Play.Text = "Play"; Play.TextColor3 = Color3.new(1, 1, 1); Play.TextScaled = true
    Play.BackgroundColor3 = PUR
    Instance.new("UICorner", Play).CornerRadius = UDim.new(0, 12)
    local PlayStroke = Instance.new("UIStroke", Play); PlayStroke.Thickness = 1.5; PlayStroke.Color = Color3.fromRGB(180, 60, 255)
    Play.MouseEnter:Connect(function() TweenService:Create(Play, TweenInfo.new(.2), { BackgroundColor3 = Color3.fromRGB(180, 30, 255) }):Play() end)
    Play.MouseLeave:Connect(function() TweenService:Create(Play, TweenInfo.new(.2), { BackgroundColor3 = PUR }):Play() end)

    local dontAgain = false
    local DontFrame = mk("DontFrame", MainFrame)
    DontFrame.BackgroundTransparency = 1; DontFrame.Position = UDim2.new(0.15, 0, 0.79, 0); DontFrame.Size = UDim2.new(0.7, 0, 0.06, 0); DontFrame.Visible = false
    local CB = mk("CB", DontFrame, "TextButton")
    CB.BackgroundColor3 = CARD; CB.Size = UDim2.new(1, 0, 1, 0); CB.Text = ""
    Instance.new("UIAspectRatioConstraint", CB).AspectRatio = 1
    Instance.new("UICorner", CB).CornerRadius = UDim.new(0, 4)
    local CBStroke = Instance.new("UIStroke", CB); CBStroke.Thickness = 1.5; CBStroke.Color = Color3.fromRGB(60, 60, 80)
    local CBText = mk("CBText", DontFrame, "TextLabel")
    CBText.BackgroundTransparency = 1; CBText.Position = UDim2.new(0.15, 0, 0, 0); CBText.Size = UDim2.new(0.85, 0, 1, 0)
    CBText.Font = Enum.Font.GothamBold; CBText.TextColor3 = Color3.fromRGB(220, 220, 235); CBText.TextXAlignment = Enum.TextXAlignment.Left; CBText.TextScaled = true
    CBText.Text = T("Box")
    CB.MouseButton1Click:Connect(function()
        dontAgain = not dontAgain
        TweenService:Create(CBStroke, TweenInfo.new(.2), { Color = dontAgain and PUR or Color3.fromRGB(60, 60, 80) }):Play()
    end)

    local Grid = mk("Grid", MainFrame)
    Grid.BackgroundTransparency = 1; Grid.Position = UDim2.new(0.05, 0, 0.30, 0); Grid.Size = UDim2.new(0.9, 0, 0.46, 0); Grid.Visible = false
    local Layout = Instance.new("UIGridLayout", Grid)
    Layout.CellSize = UDim2.new(0.44, 0, 0.20, 0); Layout.CellPadding = UDim2.new(0.04, 0, 0.03, 0)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; Layout.VerticalAlignment = Enum.VerticalAlignment.Center

    local Skip = mk("Skip", MainFrame, "TextButton")
    Skip.BackgroundColor3 = CARD; Skip.Position = UDim2.new(0.35, 0, 0.88, 0); Skip.Size = UDim2.new(0.3, 0, 0.08, 0)
    Skip.Font = Enum.Font.GothamBold; Skip.TextColor3 = Color3.fromRGB(200, 200, 220); Skip.TextScaled = true; Skip.Visible = false
    Instance.new("UICorner", Skip).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Skip).Color = Color3.fromRGB(60, 60, 80)
    Skip.Text = T("Skip")
    Skip.MouseButton1Click:Connect(openCheats)

    for _, lang in ipairs(Languages) do
        local b = mk(lang.Name, Grid, "TextButton")
        b.BackgroundColor3 = CARD; b.Text = lang.Display; b.TextColor3 = Color3.fromRGB(220, 220, 235)
        b.TextScaled = true; b.Font = Enum.Font.GothamBold
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", b).Color = Color3.fromRGB(60, 60, 80)
        b.MouseButton1Click:Connect(function()
            DEFAULT_LANG = lang.Code; saveLang(lang.Code)
            openCheats()
        end)
    end
    Play.MouseButton1Click:Connect(function()
        if dontAgain then
            openCheats()
        else
            Play.Visible = false; Skip.Visible = true; DontFrame.Visible = true; Grid.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(.4), { Size = UDim2.new(0.35, 0, 0.45, 0) }):Play()
            TweenService:Create(MainRatio, TweenInfo.new(.4), { AspectRatio = 1.2 }):Play()
        end
    end)
else
    Notif("SP Hub", T("Unsupported"))
end

-- ===== LOADING =====
task.spawn(function()
    LoadingFrame.Visible = true
    local t = TweenService:Create(LoadingFrame, TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0.3, 0, 0.3, 0) })
    t:Play(); t.Completed:Wait()
    LogoImage.Visible = true; LogoImage.ImageTransparency = 1
    TweenService:Create(LogoImage, TweenInfo.new(.3), { ImageTransparency = 0 }):Play()
    task.wait(1)
    TweenService:Create(LogoImage, TweenInfo.new(.4), { ImageTransparency = 1 }):Play()
    task.wait(.4)
    LoadingFrame.Visible = false
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
end)
