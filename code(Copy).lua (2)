-- ===== SZ HUB | SZDUNIS v1.3 =====
-- PARTE 1/13: CABECALHO + HELPERS
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local R = game:GetService("RunService")
local S = game:GetService("StarterGui")
local W = workspace
local C = W.CurrentCamera
local RS = game:GetService("ReplicatedStorage")
local LP = P.LocalPlayer
local HS = game:GetService("HttpService")

if getgenv().SZDUN then return end
getgenv().SZDUN = true

if not ((game.PlaceId == 142823291) or (game.GameId == 66654135)) then
    S:SetCore("SendNotification", { Title = "SzHub | SzDunamis", Text = "Jogo nao suportado", Duration = 3 })
    return
end

local IMG = "rbxassetid://112169216"
local PUR = Color3.fromRGB(150, 20, 255)
local ROW = Color3.fromRGB(26, 26, 36)
local WHT = Color3.new(1, 1, 1)

local st = {
    sp = false, fl = false, nc = false, espR = false, espG = false,
    xr = false, sa = false, at = false, kill = false, cf = false,
    ag = false, afk = false, ac = false
}

local G
local CF
local startFarm
local stopFarm
local unload

local function N(t, x)
    S:SetCore("SendNotification", { Title = t, Text = x, Duration = 3 })
end

local function HRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function alive()
    return LP:GetAttribute("Alive") ~= false
end

local function has(p, n)
    local c = p.Character
    return (c and c:FindFirstChild(n)) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild(n) ~= nil)
end

local function tgt()
    local hrp = HRP()
    if not hrp then return nil end
    local b, d = nil, math.huge
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP then
            local c = p.Character
            local t = c and (c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso"))
            if t and t.Parent then
                local q = (t.Position - hrp.Position).Magnitude
                if q < d then d, b = q, t end
            end
        end
    end
    return b
end

local function tgtA()
    local hrp = HRP()
    if not hrp then return nil end
    local b, d = nil, math.huge
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and has(p, "Knife") then
            local c = p.Character
            local t = c and (c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso"))
            if t and t.Parent then
                local q = (t.Position - hrp.Position).Magnitude
                if q < d then d, b = q, t end
            end
        end
    end
    return b
end

local function pred(t)
    return t.CFrame + (t.Velocity * .165)
end

local function fetchScript(url)
    for i = 1, 3 do
        local ok, src = pcall(game.HttpGet, game, url)
        if ok and src and #src > 100 then return src end
        task.wait(1)
    end
    return nil
end
-- ===== PARTE 2/13: HOOKS + TECLAS =====
local oi
local M = LP:GetMouse()
local function validMouse()
    if not M or not M.Parent then M = LP:GetMouse() end
    return M
end

local SAok = pcall(function()
    oi = hookmetamethod(game, "__index", newcclosure(function(s, k)
        if st.sa and (not checkcaller or not checkcaller()) and rawequal(s, validMouse()) then
            if k == "Hit" then
                local t = tgtA()
                if t then return pred(t) end
            end
            if k == "Target" then return tgtA() end
        end
        return oi(s, k)
    end))
end)

local on
local NCok = pcall(function()
    on = hookmetamethod(game, "__namecall", newcclosure(function(s, ...)
        local a = { ... }
        if st.sa and (not checkcaller or not checkcaller()) and typeof(s) == "userdata" and s:IsA("RemoteEvent") then
            local n = string.lower(s.Name)
            if n:find("hoot") or n:find("ire") or n:find("gun") or n:find("weapon") then
                local t = tgtA()
                if t then
                    for i, v in ipairs(a) do
                        if typeof(v) == "CFrame" then a[i] = CFrame.new(t.Position) end
                        if typeof(v) == "Vector3" then a[i] = t.Position end
                    end
                end
            end
        end
        return on(s, unpack(a))
    end))
end)

local keys = {}
local FLYKEYS = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true, [Enum.KeyCode.LeftShift] = true
}
U.InputBegan:Connect(function(i)
    if FLYKEYS[i.KeyCode] then keys[i.KeyCode] = true end
end)
U.InputEnded:Connect(function(i)
    if FLYKEYS[i.KeyCode] then keys[i.KeyCode] = nil end
end)
-- ===== PARTE 3/13: ESP =====
local espTags = {}
local gunTag

local function setTag(p, txt, col, showName, dist)
    local h = p.Character and p.Character:FindFirstChild("Head")
    if not h then return end
    local e = espTags[p]
    if not e or not e.gui.Parent then
        local b = Instance.new("BillboardGui")
        b.Size = UDim2.new(0, 130, 0, 28)
        b.AlwaysOnTop = true
        b.MaxDistance = 700
        b.StudsOffset = Vector3.new(0, 3, 0)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextScaled = true
        l.TextStrokeTransparency = .2
        e = { gui = b, label = l }
        espTags[p] = e
    end
    e.gui.Parent = h
    e.label.Text = txt .. (showName and (" | " .. p.Name) or "") .. (dist and (" | " .. dist .. "m") or "")
    e.label.TextColor3 = col
end

local function clear()
    for _, e in pairs(espTags) do
        pcall(function() e.gui:Destroy() end)
    end
    espTags = {}
end

local function refresh()
    local hrp = HRP()
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("Head")
            local dist = hrp and h and math.floor((h.Position - hrp.Position).Magnitude + .5) or nil
            if has(p, "Knife") then
                setTag(p, "ASSASSINO", Color3.fromRGB(255, 70, 70), true, dist)
            elseif has(p, "Gun") then
                setTag(p, "XERIFE", Color3.fromRGB(70, 160, 255), true, dist)
            else
                setTag(p, p.Name, Color3.fromRGB(0, 220, 120), false)
            end
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
    gunDropCache = W:FindFirstChild("GunDrop", true)
    return gunDropCache
end

local function espGun(v)
    if gunTag then
        pcall(function() gunTag:Destroy() end)
        gunTag = nil
    end
    if not v then return end
    local g = gunDrop()
    if not g then return end
    local part = g:IsA("BasePart") and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
    if part then
        local b = Instance.new("BillboardGui", part)
        b.Name = "SZGUN"
        b.Size = UDim2.new(0, 100, 0, 24)
        b.AlwaysOnTop = true
        b.StudsOffset = Vector3.new(0, 1, 0)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextScaled = true
        l.Text = "ARMA"
        l.TextColor3 = Color3.fromRGB(255, 200, 60)
        l.TextStrokeTransparency = .2
        gunTag = b
    end
end
-- ===== PARTE 4/13: CACHES + RESPAWN =====
local myParts = {}
local function cacheMyParts(c)
    myParts = {}
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then myParts[#myParts + 1] = v end
    end
end

local xrayParts = {}
local xrayOn = false
local function enableXray()
    xrayOn = true
    xrayParts = {}
    for _, v in ipairs(W:GetDescendants()) do
        if v:IsA("BasePart") and not (LP.Character and v:IsDescendantOf(LP.Character)) then
            v.LocalTransparencyModifier = .75
            xrayParts[#xrayParts + 1] = v
        end
    end
end
local function disableXray()
    xrayOn = false
    for _, v in ipairs(xrayParts) do
        if v and v.Parent then v.LocalTransparencyModifier = 0 end
    end
    xrayParts = {}
end

W.DescendantAdded:Connect(function(v)
    if xrayOn and v:IsA("BasePart") and not (LP.Character and v:IsDescendantOf(LP.Character)) then
        v.LocalTransparencyModifier = .75
        xrayParts[#xrayParts + 1] = v
    end
end)

LP.CharacterAdded:Connect(function(c)
    task.wait(.5)
    cacheMyParts(c)
    clear()
    if CF and CF.farming then stopFarm() end
end)
if LP.Character then cacheMyParts(LP.Character) end
-- ===== PARTE 5/13: LOOP PRINCIPAL (A) =====
task.spawn(function()
    local t1, t2, t3, t4 = 0, 0, 0, 0
    local lastAt, lastAC = 0, 0
    while true do
        local dt = task.wait()
        local okLoop, errLoop = pcall(function()
            local c = LP.Character
            local hrp = HRP()
            local hum = c and c:FindFirstChildOfClass("Humanoid")

            if hum then
                local ws = st.sp and 32 or 16
                if hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end
            end

            if st.fl and hrp then
                local bv = hrp:FindFirstChild("SZBV")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "SZBV"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.Parent = hrp
                end
                local f = (keys[Enum.KeyCode.W] and 1 or 0) - (keys[Enum.KeyCode.S] and 1 or 0)
                local r = (keys[Enum.KeyCode.D] and 1 or 0) - (keys[Enum.KeyCode.A] and 1 or 0)
                local u = (keys[Enum.KeyCode.Space] and 1 or 0) - (keys[Enum.KeyCode.LeftShift] and 1 or 0)
                bv.Velocity = (C.CFrame.LookVector * f + C.CFrame.RightVector * r + Vector3.new(0, u, 0)) * 50
            elseif hrp then
                local bv = hrp:FindFirstChild("SZBV")
                if bv then bv:Destroy() end
            end

            if st.nc then
                for i = 1, #myParts do
                    local v = myParts[i]
                    if v and v.Parent then v.CanCollide = false end
                end
            end

            t1 = t1 + dt
            if t1 > .5 then
                t1 = 0
                if st.nc then
                    for _, p in ipairs(P:GetPlayers()) do
                        if p ~= LP and p.Character then
                            for _, v in ipairs(p.Character:GetDescendants()) do
                                if v:IsA("BasePart") then v.CanCollide = false end
                            end
                        end
                    end
                end
            end

            t4 = t4 + dt
            if t4 >= 1 then
                t4 = 0
                if st.espR then refresh() else clear() end
                if st.espG and not (gunTag and gunTag.Parent) then espGun(true) end
            end
-- ===== PARTE 6/13: LOOP PRINCIPAL (B) =====
            if st.at then
                local g = (c and c:FindFirstChild("Gun")) or (LP.Backpack and LP.Backpack:FindFirstChild("Gun"))
                local t = tgtA()
                if g and t then
                    if g.Parent ~= c then
                        local h = c and c:FindFirstChildOfClass("Humanoid")
                        if h then h:EquipTool(g) end
                    end
                    if os.clock() - lastAt > .15 then
                        g:Activate()
                        lastAt = os.clock()
                    end
                end
            end

            if st.kill then
                local k = c and c:FindFirstChild("Knife")
                local hd = tgt()
                if hrp and k and hd and hd.Parent then
                    local r = hd.Parent:FindFirstChild("HumanoidRootPart")
                    if r then r.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 4 end
                    local hp = k:FindFirstChild("Handle")
                    if hp then
                        for _, v in ipairs(hd.Parent:GetDescendants()) do
                            if v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
                                firetouchinterest(hp, v, 0)
                                firetouchinterest(hp, v, 1)
                            end
                        end
                    end
                    k:Activate()
                end
            end

            t2 = t2 + dt
            if st.ag and t2 > .6 then
                t2 = 0
                local g = gunDrop()
                local part = g and (g:IsA("BasePart") and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart"))
                if alive() and part and hrp then
                    hrp.CFrame = part.CFrame * CFrame.new(0, 0, 2)
                    task.wait(.08)
                    for _, v in ipairs(g:GetDescendants()) do
                        if v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
                            firetouchinterest(hrp, v, 0)
                            firetouchinterest(hrp, v, 1)
                        end
                    end
                end
            end

            t3 = t3 + dt
            if st.afk and t3 > 30 then
                t3 = 0
                pcall(function()
                    local VU = game:GetService("VirtualUser")
                    VU:CaptureController()
                    VU:ClickButton2(Vector2.new())
                end)
            end

            if st.ac then
                if os.clock() - lastAC > .08 then
                    lastAC = os.clock()
                    pcall(function() mouse1click() end)
                    pcall(function()
                        local VU = game:GetService("VirtualUser")
                        VU:CaptureController()
                        VU:ClickButton1(Vector2.new())
                    end)
                end
            end
        end)
        if not okLoop then warn("SzDunamis loop:", errLoop) end
    end
end)

R.RenderStepped:Connect(function()
    if st.sa and alive() then
        local t = tgtA()
        if t and C then
            C.CFrame = C.CFrame:Lerp(CFrame.lookAt(C.CFrame.Position, t.Position), 0.35)
        end
    end
end)
-- ===== PARTE 7/13: COIN FARM =====
local coinBoxCache
local function box()
    if coinBoxCache and coinBoxCache.Parent then return coinBoxCache end
    coinBoxCache = W:FindFirstChild("CoinContainer", true)
    return coinBoxCache
end

local function okCoin(cn)
    return cn and cn:GetAttribute("CoinID") == "Coin" and cn:FindFirstChild("TouchInterest") and cn.Transparency == 1
end

local function nearCoin()
    local hrp = HRP()
    local b = box()
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

CF = { farming = false, collected = false, tw = nil, cool = 0, parts = {} }

startFarm = function()
    local c = LP.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    CF.parts = {}
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then CF.parts[v] = v.CanCollide end
    end
    for p, cc in pairs(CF.parts) do p.CanCollide = false end
    hrp.CFrame = (hrp.CFrame - Vector3.new(0, 2.5, 0)) * CFrame.Angles(math.rad(90), 0, 0)
    hum.PlatformStand = true
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    CF.farming = true
end

stopFarm = function()
    CF.farming = false
    if CF.tw then CF.tw:Cancel() CF.tw = nil end
    local c = LP.Character
    if c then
        for p, cc in pairs(CF.parts) do
            if p and p.Parent then p.CanCollide = cc end
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-90), 0, 0) + Vector3.new(0, 2.5, 0)
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
    CF.parts = {}
end

local function getR(n)
    local rm = RS:FindFirstChild("Remotes")
    local gp = rm and rm:FindFirstChild("Gameplay")
    return gp and gp:FindFirstChild(n)
end

local CC = getR("CoinCollected")
if CC then
    CC.OnClientEvent:Connect(function(tp, a, b)
        if tp == "Coin" then CF.collected = (tonumber(a) == tonumber(b)) end
    end)
end
local RSt = getR("RoundStart")
if RSt then
    RSt.OnClientEvent:Connect(function() CF.collected = false end)
end
local RE = getR("RoundEndFade")
if RE then
    RE.OnClientEvent:Connect(function()
        CF.collected = false
        if CF.farming then stopFarm() end
    end)
end

R.Heartbeat:Connect(function()
    local hrp = HRP()
    if CF.farming and hrp then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
    end
    if not st.cf then
        if CF.farming then stopFarm() end
        return
    end
    if not (hrp and alive()) then
        if CF.farming then stopFarm() end
        return
    end
    local cn = nearCoin()
    if cn and not CF.collected and not (CF.cool and os.clock() < CF.cool) then
        local d = (cn.Position - hrp.Position).Magnitude
        if d > 5 then
            if not CF.farming then startFarm() end
            if CF.farming then
                if CF.tw then CF.tw:Cancel() CF.tw = nil end
                local tw = T:Create(hrp, TweenInfo.new(math.clamp(d / 23, .1, 6), Enum.EasingStyle.Linear), {
                    CFrame = CFrame.new(cn.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(math.rad(90), 0, 0)
                })
                CF.tw = tw
                tw:Play()
                task.delay(math.clamp(d / 23, .1, 6) + 1.2, function()
                    if CF.tw == tw then
                        CF.tw:Cancel()
                        CF.tw = nil
                        CF.cool = os.clock() + 1
                    end
                end)
            end
        else
            firetouchinterest(hrp, cn, 0)
            firetouchinterest(hrp, cn, 1)
        end
    elseif CF.farming and (not cn or CF.collected) then
        stopFarm()
    end
end)
-- ===== PARTE 8/13: UNLOAD + CONFIG =====
local CFG_FILE = "SzDunamisConfig.json"

local function saveCfg()
    pcall(function()
        writefile(CFG_FILE, HS:JSONEncode(st))
    end)
end

local function loadCfg()
    pcall(function()
        local txt = readfile(CFG_FILE)
        if txt and #txt > 0 then
            local d = HS:JSONDecode(txt)
            if type(d) == "table" then
                for k, v in pairs(d) do
                    if st[k] ~= nil and type(v) == "boolean" then st[k] = v end
                end
            end
        end
    end)
end

unload = function()
    if not getgenv().SZDUN then return end
    getgenv().SZDUN = false
    stopFarm()
    if xrayOn then disableXray() end
    clear()
    espGun(false)
    saveCfg()
    if G then pcall(function() G:Destroy() end) end
    N("SzHub | SzDunamis", "Script descarregado")
end
-- ===== PARTE 9/13: JANELA =====
local PW, PH = 480, 320
local G = Instance.new("ScreenGui")
G.Name = "SZDUN_GUI"
G.ResetOnSpawn = false
G.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
G.Parent = LP:WaitForChild("PlayerGui")

local Pn = Instance.new("Frame", G)
Pn.Position = UDim2.new(.5, 0, .5, 0)
Pn.Size = UDim2.new(0, PW, 0, PH)
Pn.BackgroundColor3 = Color3.fromRGB(13, 13, 19)
Pn.ZIndex = 1
Instance.new("UICorner", Pn).CornerRadius = UDim.new(0, 18)
local PS = Instance.new("UIStroke", Pn)
PS.Thickness = 2
PS.Color = PUR
PS.Transparency = .4

local Bg = Instance.new("ImageLabel", Pn)
Bg.Size = UDim2.new(1, 0, 1, 0)
Bg.BackgroundTransparency = 1
Bg.Image = IMG
Bg.ScaleType = Enum.ScaleType.Crop
Bg.ImageTransparency = .88
Bg.ZIndex = 1

local TB = Instance.new("Frame", Pn)
TB.Size = UDim2.new(1, 0, .13, 0)
TB.BackgroundTransparency = 1
TB.ZIndex = 3

local wDrag, wStart, wPos
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        wDrag = true
        wStart = i.Position
        wPos = Pn.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then wDrag = false end
        end)
    end
end)
U.InputChanged:Connect(function(i)
    if wDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - wStart
        Pn.Position = UDim2.new(wPos.X.Scale, wPos.X.Offset + d.X, wPos.Y.Scale, wPos.Y.Offset + d.Y)
    end
end)

local Lg = Instance.new("ImageLabel", TB)
Lg.Size = UDim2.fromOffset(38, 38)
Lg.Position = UDim2.new(.04, 0, .5, 0)
Lg.AnchorPoint = Vector2.new(0, .5)
Lg.Image = IMG
Lg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Lg.BackgroundTransparency = .25
Instance.new("UICorner", Lg).CornerRadius = UDim.new(1, 0)
local Ls = Instance.new("UIStroke", Lg)
Ls.Thickness = 2
Ls.Color = PUR

local Tt = Instance.new("TextLabel", TB)
Tt.Position = UDim2.new(.18, 0, .12, 0)
Tt.Size = UDim2.new(.6, 0, .4, 0)
Tt.BackgroundTransparency = 1
Tt.Text = "SzHub"
Tt.Font = Enum.Font.Michroma
Tt.TextScaled = true
Tt.TextColor3 = WHT
local tg = Instance.new("UIGradient", Tt)
tg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PUR),
    ColorSequenceKeypoint.new(.5, WHT),
    ColorSequenceKeypoint.new(1, PUR)
})
tg.Rotation = 90

local Sub = Instance.new("TextLabel", TB)
Sub.Position = UDim2.new(.18, 0, .55, 0)
Sub.Size = UDim2.new(.6, 0, .35, 0)
Sub.BackgroundTransparency = 1
Sub.Text = "SzDunamis"
Sub.Font = Enum.Font.GothamBold
Sub.TextScaled = true
Sub.TextColor3 = Color3.fromRGB(150, 150, 170)
Sub.TextXAlignment = Enum.TextXAlignment.Left

local XBtn = Instance.new("TextButton", TB)
XBtn.Size = UDim2.fromOffset(30, 30)
XBtn.AnchorPoint = Vector2.new(1, .5)
XBtn.Position = UDim2.new(.97, 0, .5, 0)
XBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
XBtn.Text = "X"
XBtn.Font = Enum.Font.SourceSansBold
XBtn.TextScaled = true
XBtn.TextColor3 = WHT
XBtn.ZIndex = 4
Instance.new("UICorner", XBtn).CornerRadius = UDim.new(1, 0)
local XS = Instance.new("UIStroke", XBtn)
XS.Thickness = 1.5
XS.Color = Color3.fromRGB(255, 120, 120)

XBtn.MouseEnter:Connect(function()
    T:Create(XBtn, TweenInfo.new(.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = 90,
        BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    }):Play()
end)
XBtn.MouseLeave:Connect(function()
    T:Create(XBtn, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = 0,
        BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    }):Play()
end)
XBtn.MouseButton1Click:Connect(function()
    task.spawn(unload)
end)
-- ===== PARTE 10/13: ABAS + CONTEUDO =====
local Tabs = { "Mov", "Vis", "Aim", "Farm", "Tools" }
local TBs, Pgs = {}, {}

local function Show(i)
    for j, pg in ipairs(Pgs) do pg.Visible = (j == i) end
    for j, b in ipairs(TBs) do
        local v = j == i
        T:Create(b, TweenInfo.new(.2), { BackgroundColor3 = v and PUR or ROW }):Play()
        T:Create(b, TweenInfo.new(.2), { TextColor3 = v and WHT or Color3.fromRGB(190, 190, 210) }):Play()
    end
end

local TBr = Instance.new("Frame", Pn)
TBr.Position = UDim2.new(0, 0, .13, 0)
TBr.Size = UDim2.new(1, 0, .08, 0)
TBr.BackgroundTransparency = 1
TBr.ZIndex = 3

for i, nm in ipairs(Tabs) do
    local b = Instance.new("TextButton", TBr)
    b.Size = UDim2.new(.19, 0, .72, 0)
    b.Position = UDim2.new(.015 + (i - 1) * .198, 0, .14, 0)
    b.BackgroundColor3 = ROW
    b.Text = nm
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextColor3 = Color3.fromRGB(190, 190, 210)
    b.ZIndex = 2
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    TBs[i] = b
    b.MouseButton1Click:Connect(function() Show(i) end)
end

local Ct = Instance.new("Frame", Pn)
Ct.Position = UDim2.new(.04, 0, .23, 0)
Ct.Size = UDim2.new(.92, 0, .74, 0)
Ct.BackgroundTransparency = 1
Ct.ZIndex = 3

for i = 1, #Tabs do
    local pg = Instance.new("ScrollingFrame", Ct)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.ZIndex = 3
    pg.ScrollingDirection = Enum.ScrollingDirection.Y
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = PUR
    pg.CanvasSize = UDim2.new(0, 0, 0, 0)
    Pgs[i] = pg
end
-- ===== PARTE 11/13: TOGGLES + BOTOES =====
local toggles = {}

local function Mk(pg, label, state, fn)
    local i = #pg:GetChildren() + 1
    local row = Instance.new("Frame", pg)
    row.Size = UDim2.new(1, 0, 0, 56)
    row.Position = UDim2.new(0, 0, 0, 6 + (i - 1) * 66)
    row.BackgroundColor3 = ROW
    row.ZIndex = 2
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local rs = Instance.new("UIStroke", row)
    rs.Thickness = 1.5
    rs.Color = Color3.fromRGB(60, 60, 80)

    local lb = Instance.new("TextLabel", row)
    lb.Size = UDim2.new(.6, 0, 1, 0)
    lb.Position = UDim2.new(.06, 0, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.Font = Enum.Font.GothamBold
    lb.TextScaled = true
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextColor3 = Color3.fromRGB(235, 235, 245)
    lb.ZIndex = 3

    local sw = Instance.new("TextButton", row)
    sw.Size = UDim2.fromOffset(48, 26)
    sw.AnchorPoint = Vector2.new(1, .5)
    sw.Position = UDim2.new(.94, 0, .5, 0)
    sw.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    sw.ZIndex = 3
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local ss = Instance.new("UIStroke", sw)
    ss.Thickness = 1.5
    ss.Color = Color3.fromRGB(60, 60, 80)

    local on = Instance.new("TextLabel", sw)
    on.Size = UDim2.new(1, 0, 1, 0)
    on.BackgroundTransparency = 1
    on.Text = "ON"
    on.Font = Enum.Font.GothamBold
    on.TextScaled = true
    on.TextColor3 = WHT
    on.ZIndex = 4

    local off = Instance.new("TextLabel", sw)
    off.Size = UDim2.new(1, 0, 1, 0)
    off.BackgroundTransparency = 1
    off.Text = "OFF"
    off.Font = Enum.Font.GothamBold
    off.TextScaled = true
    off.TextColor3 = Color3.fromRGB(130, 130, 150)
    off.ZIndex = 4

    local gl = Instance.new("Frame", row)
    gl.Size = UDim2.new(1, 0, 1, 0)
    gl.BackgroundColor3 = PUR
    gl.BackgroundTransparency = 1
    gl.ZIndex = 1
    gl.Visible = false
    Instance.new("UICorner", gl).CornerRadius = UDim.new(0, 10)

    local set = function(v)
        st[state] = v
        T:Create(sw, TweenInfo.new(.22), { BackgroundColor3 = v and PUR or Color3.fromRGB(24, 24, 32) }):Play()
        T:Create(ss, TweenInfo.new(.22), { Color = v and PUR or Color3.fromRGB(60, 60, 80) }):Play()
        on.Visible = v
        off.Visible = not v
        gl.Visible = v
        if v then
            T:Create(gl, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = .5 }):Play()
        end
        if fn then fn(state, v) end
        saveCfg()
    end
    sw.MouseButton1Click:Connect(function() set(not st[state]) end)
    toggles[state] = set
end

local function MkBtn(pg, label, fn)
    local i = #pg:GetChildren() + 1
    local row = Instance.new("TextButton", pg)
    row.Size = UDim2.new(1, 0, 0, 76)
    row.Position = UDim2.new(0, 0, 0, 6 + (i - 1) * 86)
    row.BackgroundColor3 = ROW
    row.Text = label
    row.Font = Enum.Font.GothamBold
    row.TextScaled = true
    row.TextColor3 = Color3.fromRGB(235, 235, 245)
    row.ZIndex = 2
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local bs = Instance.new("UIStroke", row)
    bs.Thickness = 1.5
    bs.Color = Color3.fromRGB(60, 60, 80)
    row.MouseEnter:Connect(function()
        T:Create(row, TweenInfo.new(.2), { BackgroundColor3 = Color3.fromRGB(40, 40, 52) }):Play()
        T:Create(bs, TweenInfo.new(.2), { Color = PUR }):Play()
    end)
    row.MouseLeave:Connect(function()
        T:Create(row, TweenInfo.new(.2), { BackgroundColor3 = ROW }):Play()
        T:Create(bs, TweenInfo.new(.2), { Color = Color3.fromRGB(60, 60, 80) }):Play()
    end)
    row.MouseButton1Click:Connect(function()
        if fn then fn() end
    end)
end
-- ===== PARTE 12/13: FEATURES NA UI =====
Mk(Pgs[1], "Speed", "sp")
Mk(Pgs[1], "Fly", "fl")
Mk(Pgs[1], "Noclip", "nc")

Mk(Pgs[2], "ESP Roles", "espR", function(_, v) if v then refresh() else clear() end end)
Mk(Pgs[2], "ESP Gun", "espG", function(_, v) espGun(v) end)
Mk(Pgs[2], "Xray", "xr", function(_, v) if v then enableXray() else disableXray() end end)

Mk(Pgs[3], "Silent Aim", "sa", function(_, v)
    if v and not SAok and not NCok then
        N("SzHub | SzDunamis", "Sem hooks: silent aim usara lock de camera")
    end
end)
Mk(Pgs[3], "Auto Shoot", "at")
Mk(Pgs[3], "Kill Aura", "kill")

Mk(Pgs[4], "Coin Farm", "cf")
Mk(Pgs[4], "Auto Gun", "ag")
Mk(Pgs[4], "Anti AFK", "afk")

Mk(Pgs[5], "Auto Click", "ac")
MkBtn(Pgs[5], "Emotes", function()
    N("SzHub | SzDunamis", "Carregando Emotes...")
    task.spawn(function()
        local src = fetchScript("https://raw.githubusercontent.com/as6cd0/SP_Hub/main/Animations")
        if src then
            local ok, fn = pcall(loadstring, src)
            if ok then ok, fn = pcall(fn) end
            if not ok then N("SzHub | SzDunamis", "Erro: " .. tostring(fn)) end
        else
            N("SzHub | SzDunamis", "Falha ao baixar Emotes")
        end
    end)
end)
MkBtn(Pgs[5], "Unload (Fechar Tudo)", function()
    task.spawn(unload)
end)

for _, pg in ipairs(Pgs) do
    local h = 12
    for _, ch in ipairs(pg:GetChildren()) do
        h = h + (ch.Size.Y.Offset or 0) + 6
    end
    pg.CanvasSize = UDim2.new(0, 0, 0, h)
end
Show(1)
-- ===== PARTE 13/13: ORB + KEYBIND + FIM =====
local Orb = Instance.new("TextButton", G)
Orb.Size = UDim2.fromOffset(36, 36)
Orb.AnchorPoint = Vector2.new(.5, .5)
Orb.Position = UDim2.new(0, 36, 1, -46)
Orb.BackgroundColor3 = Color3.new(0, 0, 0)
Orb.Text = "sz"
Orb.Font = Enum.Font.Michroma
Orb.TextScaled = true
Orb.TextColor3 = WHT
Orb.Visible = true
Orb.ZIndex = 5
Instance.new("UICorner", Orb).CornerRadius = UDim.new(1, 0)
local OS = Instance.new("UIStroke", Orb)
OS.Thickness = 2
OS.Color = PUR

local OG = Instance.new("Frame", G)
OG.Size = UDim2.fromOffset(46, 46)
OG.AnchorPoint = Vector2.new(.5, .5)
OG.Position = Orb.Position
OG.BackgroundColor3 = PUR
OG.BackgroundTransparency = .7
OG.ZIndex = 4
OG.Visible = true
Instance.new("UICorner", OG).CornerRadius = UDim.new(1, 0)

local dragging = false
local isDrag = false
local stPt

Orb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        stPt = i.Position
        isDrag = false
    end
end)
U.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        if (i.Position - stPt).Magnitude > 12 then isDrag = true end
        if isDrag then
            local p = UDim2.fromOffset(i.Position.X, i.Position.Y)
            Orb.Position = p
            OG.Position = p
        end
    end
end)
U.InputEnded:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then
        dragging = false
        if not isDrag and Pn then
            Pn.Visible = not Pn.Visible
        end
    end
end)

-- Keybind: RightShift alterna a janela
U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift and Pn then
        Pn.Visible = not Pn.Visible
    end
end)

-- FIM: aplica a config salva e liga os toggles restaurados
loadCfg()
for k in pairs(st) do
    local set = toggles[k]
    if set then set(st[k]) end
end
N("SzHub | SzDunamis", "Carregado | v1.3 | RightShift = janela")
