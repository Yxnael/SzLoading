-- ===== SP HUB LOADER (ORIGINAL) + SZDUNIS/MM2 v1.3.1 [MM2-ONLY FIXED] =====
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace
local Camera = Workspace.CurrentCamera

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Guard com RESET (nao trava mais em execucoes repetidas)
if getgenv().SZDUN then
    pcall(function()
        if getgenv().SZDUN_GUI then getgenv().SZDUN_GUI:Destroy() end
        local lg = CoreGui:FindFirstChild("Loading SP Hub")
        if lg then lg:Destroy() end
    end)
    getgenv().SZDUN = nil
end
getgenv().SZDUN = true

-- ================= DETECCAO SO MM2 =================
local IS_MM2 = (game.PlaceId == 142823291) or (tostring(game.GameId) == "66654135")

-- ================= IDIOMAS + PERSISTENCIA =================
local Languages = {
    { Code = "en", Name = "English",  Display = "EN  English" },
    { Code = "pt", Name = "Brazil",   Display = "PT  Portugues" },
    { Code = "es", Name = "Espanola", Display = "ES  Espanola" },
    { Code = "ar", Name = "Arabic",   Display = "AR  Arabic" },
    { Code = "ru", Name = "Russian",  Display = "RU  Russian" },
    { Code = "fr", Name = "France",   Display = "FR  Francais" },
    { Code = "de", Name = "Germany",  Display = "DE  Deutsch" },
    { Code = "tr", Name = "Turkey",   Display = "TR  Turkce" }
}
local SkipTranslations = {
    en = "Skip", ar = "Skip", es = "Omitir", tr = "Gec",
    ru = "Skip", fr = "Passer", de = "Uberspringen", pt = "Pular"
}
local CheckBoxTranslations = {
    en = "Don't show this again", ar = "Don't show again", es = "No mostrar de nuevo",
    tr = "Tekrar gosterme", ru = "Ne pokazyvat snova", fr = "Ne plus afficher",
    de = "Nicht mehr anzeigen", pt = "Nao mostrar novamente"
}

local function saveLanguageSetting(value)
    pcall(function()
        local json = {}
        local ok, data = pcall(readfile, "dropdowns.json")
        if ok and data then json = HttpService:JSONDecode(data) or {} end
        json["LanguageSetting"] = value
        writefile("dropdowns.json", HttpService:JSONEncode(json))
    end)
end
local function getSavedLanguageCode()
    local code = getgenv().SP_Hub_Language
    if code then return code end
    code = "en"
    pcall(function()
        local ok, data = pcall(readfile, "dropdowns.json")
        if ok and data then
            local json = HttpService:JSONDecode(data)
            local savedName = json and json["LanguageSetting"]
            if savedName then
                local Codes = { English="en", Brazil="pt", Espanola="es", Arabic="ar",
                    Russian="ru", France="fr", Germany="de", Turkey="tr" }
                code = Codes[savedName] or "en"
            end
        end
    end)
    return code
end
local function saveDontShowSetting(value)
    pcall(function()
        local json = {}
        local ok, data = pcall(readfile, "dropdowns.json")
        if ok and data then json = HttpService:JSONDecode(data) or {} end
        json["DontShowLanguageMenu"] = value
        writefile("dropdowns.json", HttpService:JSONEncode(json))
    end)
end
local function getSavedDontShowSetting()
    local dontShow = false
    pcall(function()
        local ok, data = pcall(readfile, "dropdowns.json")
        if ok and data then
            local json = HttpService:JSONDecode(data)
            if json and json["DontShowLanguageMenu"] ~= nil then dontShow = json["DontShowLanguageMenu"] end
        end
    end)
    return dontShow
end

-- Traducoes das features
local MM2T = {
    ["en"] = {
        Tabs={"Mov","Vis","Aim","Farm","Tools"},
        Sp="Speed", Fl="Fly", Nc="Noclip",
        EspR="ESP Roles", EspG="ESP Gun", Xr="Xray",
        Sa="Silent Aim", At="Auto Shoot", Kill="Kill Aura",
        Cf="Coin Farm", Ag="Auto Gun", Afk="Anti AFK", Ac="Auto Click",
        Em="Emotes", Ul="Unload (Close All)",
        Loaded="Loaded | v1.3.1 | RightShift = window",
        Unloaded="Script unloaded", Unsupported="Game not supported"
    },
    ["pt"] = {
        Tabs={"Mov","Vis","Aim","Farm","Ferr"},
        Sp="Velocidade", Fl="Voar", Nc="Noclip",
        EspR="ESP Papeis", EspG="ESP Arma", Xr="Xray",
        Sa="Silent Aim", At="Tiro Auto", Kill="Kill Aura",
        Cf="Farm de Moedas", Ag="Arma Auto", Afk="Anti AFK", Ac="Auto Click",
        Em="Emotes", Ul="Descarregar (Fechar Tudo)",
        Loaded="Carregado | v1.3.1 | RightShift = janela",
        Unloaded="Script descarregado", Unsupported="Jogo nao suportado"
    }
}
local function T(k) return (MM2T[getSavedLanguageCode()] or MM2T.en)[k] or MM2T.en[k] end

-- ================= LOADING SCREEN =================
local oldUI = PlayerGui:FindFirstChild("Loading SP Hub") or CoreGui:FindFirstChild("Loading SP Hub")
if oldUI then oldUI:Destroy() end

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "Loading SP Hub"
LoadingGui.ResetOnSpawn = false
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local successParent = pcall(function() LoadingGui.Parent = CoreGui end)
if not successParent then LoadingGui.Parent = PlayerGui end

local function mk(name, parent, class)
    local i = Instance.new(class or "Frame", parent); i.Name = name; return i
end

local LoadingFrame = mk("Loading Screen", LoadingGui)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(12,12,12); LoadingFrame.BorderSizePixel = 0
LoadingFrame.AnchorPoint = Vector2.new(0.5,0.5); LoadingFrame.Position = UDim2.new(0.5,0,0.5,0)
LoadingFrame.Size = UDim2.new(0,0,0,0); LoadingFrame.ClipsDescendants = true; LoadingFrame.Visible = false
Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0,20)
local UIStroke_Load = Instance.new("UIStroke", LoadingFrame)
UIStroke_Load.Thickness = 2; UIStroke_Load.Color = Color3.fromRGB(40,40,40)
local LoadingRatio = Instance.new("UIAspectRatioConstraint", LoadingFrame); LoadingRatio.AspectRatio = 1.3
local LogoImage = mk("LogoImage", LoadingFrame, "ImageLabel")
LogoImage.BackgroundTransparency = 1; LogoImage.BorderSizePixel = 0
LogoImage.Position = UDim2.new(0.05,0,0.05,0); LogoImage.Size = UDim2.new(0.9,0,0.9,0)
LogoImage.Image = "rbxassetid://95309586448728"; LogoImage.Visible = false

local MainFrame = mk("MainFrame", LoadingGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,15); MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5,0.5); MainFrame.Position = UDim2.new(0.5,0,1.5,0)
MainFrame.Size = UDim2.new(0.32,0,0.32,0); MainFrame.ClipsDescendants = true; MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,20)
local UIStroke_Main = Instance.new("UIStroke", MainFrame)
UIStroke_Main.Thickness = 2; UIStroke_Main.Color = Color3.fromRGB(45,45,45)
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", MainFrame); UIAspectRatioConstraint.AspectRatio = 1.48

local SPHub = mk("SP Hub", MainFrame, "TextLabel")
SPHub.BackgroundTransparency = 1; SPHub.Position = UDim2.new(0.1,0,0.08,0); SPHub.Size = UDim2.new(0.8,0,0.22,0)
SPHub.Font = Enum.Font.FredokaOne; SPHub.Text = "SP Hub"; SPHub.TextColor3 = Color3.fromRGB(255,255,255); SPHub.TextScaled = true; SPHub.ZIndex = 2
local SPHubGlow = mk("UnderGlow", SPHub)
SPHubGlow.BackgroundColor3 = Color3.fromRGB(255,60,60); SPHubGlow.BorderSizePixel = 0
SPHubGlow.Position = UDim2.new(0.4,0,1.05,0); SPHubGlow.Size = UDim2.new(0.2,0,0,2)

local GameNameLabel = mk("GameNameLabel", MainFrame, "TextLabel")
GameNameLabel.BackgroundTransparency = 1; GameNameLabel.Position = UDim2.new(0.1,0,0.32,0); GameNameLabel.Size = UDim2.new(0.8,0,0.16,0)
GameNameLabel.Font = Enum.Font.FredokaOne
GameNameLabel.Text = IS_MM2 and "Murder Mystery 2 v1.3" or (T("Unsupported") .. " | " .. tostring(game.PlaceId))
GameNameLabel.TextColor3 = Color3.fromRGB(160,160,160); GameNameLabel.TextScaled = true

local ExitButton = mk("ExitButton", MainFrame, "TextButton")
ExitButton.BackgroundColor3 = Color3.fromRGB(255,60,60); ExitButton.Position = UDim2.new(0.88,0,0.06,0); ExitButton.Size = UDim2.new(0.08,0,0.12,0)
ExitButton.Font = Enum.Font.SourceSansBold; ExitButton.Text = "X"; ExitButton.TextColor3 = Color3.fromRGB(255,255,255); ExitButton.TextScaled = true; ExitButton.ZIndex = 3
Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(1,0)
local ExitRatio = Instance.new("UIAspectRatioConstraint", ExitButton); ExitRatio.AspectRatio = 1
ExitButton.MouseEnter:Connect(function()
    TweenService:Create(ExitButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Rotation = 90, BackgroundColor3 = Color3.fromRGB(220,40,40) }):Play()
end)
ExitButton.MouseLeave:Connect(function()
    TweenService:Create(ExitButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0, BackgroundColor3 = Color3.fromRGB(255,60,60) }):Play()
end)
ExitButton.MouseButton1Click:Connect(function() LoadingGui:Destroy() end)

local function applyHoverEffect(button, defaultColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverColor,
            Size = button.Size + UDim2.new(0.02,0,0.02,0),
            Position = button.Position - UDim2.new(0.01,0,0.01,0)
        }):Play()
        if button:FindFirstChild("UIStroke") then
            TweenService:Create(button.UIStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(255,60,60) }):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = defaultColor,
            Size = button.Size - UDim2.new(0.02,0,0.02,0),
            Position = button.Position + UDim2.new(0.01,0,0.01,0)
        }):Play()
        if button:FindFirstChild("UIStroke") then
            TweenService:Create(button.UIStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(60,60,60) }):Play()
        end
    end)
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputState == Enum.UserInputState.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end
makeDraggable(MainFrame, SPHub)

local function closeMenu()
    local slideOut = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.new(0.5,0,1.5,0) })
    slideOut:Play(); slideOut.Completed:Wait(); LoadingGui:Destroy()
end

local SkipButton = nil
local CheckBoxText = nil
local function updateUIText(langCode)
    local langMap = { en="English", es="Espanola", tr="Turkce", ru="Russian", fr="Francais", de="Deutsch", pt="Portugues" }
    local currentName = langMap[langCode] or "English"
    SPHub.Text = "Select Language"
    GameNameLabel.Text = "Current Language: " .. currentName
    if SkipButton then SkipButton.Text = SkipTranslations[langCode] or "Skip" end
    if CheckBoxText then CheckBoxText.Text = CheckBoxTranslations[langCode] or "Don't show this again" end
end

local launchMM2

-- ================= MENU =================
if IS_MM2 then
    local PlayButton = mk("PlayButton", MainFrame, "TextButton")
    PlayButton.Position = UDim2.new(0.3,0,0.62,0); PlayButton.Size = UDim2.new(0.4,0,0.22,0)
    PlayButton.Font = Enum.Font.SourceSansBold; PlayButton.Text = "Play"; PlayButton.TextColor3 = Color3.fromRGB(255,255,255); PlayButton.TextScaled = true
    PlayButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Instance.new("UICorner", PlayButton).CornerRadius = UDim.new(0,12)
    local UIStroke_Play = Instance.new("UIStroke", PlayButton); UIStroke_Play.Thickness = 1.5; UIStroke_Play.Color = Color3.fromRGB(60,60,60)
    applyHoverEffect(PlayButton, Color3.fromRGB(30,30,30), Color3.fromRGB(45,45,45))

    local dontShowAgain = false
    local DontShowFrame = mk("DontShowFrame", MainFrame)
    DontShowFrame.BackgroundTransparency = 1; DontShowFrame.Position = UDim2.new(0.15,0,0.79,0); DontShowFrame.Size = UDim2.new(0.7,0,0.06,0); DontShowFrame.Visible = false

    local CheckBoxButton = mk("CheckBoxButton", DontShowFrame, "TextButton")
    CheckBoxButton.BackgroundColor3 = Color3.fromRGB(30,30,30); CheckBoxButton.Size = UDim2.new(1,0,1,0); CheckBoxButton.Text = ""; CheckBoxButton.BackgroundTransparency = 0
    local CheckBoxRatio = Instance.new("UIAspectRatioConstraint", CheckBoxButton); CheckBoxRatio.AspectRatio = 1
    local CheckBoxCorner = Instance.new("UICorner", CheckBoxButton); CheckBoxCorner.CornerRadius = UDim.new(0,4)
    local CheckBoxStroke = Instance.new("UIStroke", CheckBoxButton); CheckBoxStroke.Thickness = 1.5; CheckBoxStroke.Color = Color3.fromRGB(60,60,60)
    local CheckMark = mk("CheckMark", CheckBoxButton, "TextLabel")
    CheckMark.BackgroundTransparency = 1; CheckMark.Size = UDim2.new(1,0,1,0); CheckMark.Font = Enum.Font.SourceSansBold
    CheckMark.Text = ""; CheckMark.TextColor3 = Color3.fromRGB(255,60,60); CheckMark.TextScaled = true
    CheckBoxText = mk("CheckBoxText", DontShowFrame, "TextLabel")
    CheckBoxText.BackgroundTransparency = 1; CheckBoxText.Position = UDim2.new(0.12,0,0,0); CheckBoxText.Size = UDim2.new(0.88,0,1,0)
    CheckBoxText.Font = Enum.Font.SourceSansBold; CheckBoxText.TextColor3 = Color3.fromRGB(180,180,180); CheckBoxText.TextXAlignment = Enum.TextXAlignment.Left; CheckBoxText.TextScaled = true
    local TriggerButton = mk("TriggerButton", DontShowFrame, "TextButton")
    TriggerButton.BackgroundTransparency = 1; TriggerButton.Size = UDim2.new(1,0,1,0); TriggerButton.Text = ""; TriggerButton.ZIndex = 4
    TriggerButton.MouseButton1Click:Connect(function()
        dontShowAgain = not dontShowAgain
        CheckMark.Text = dontShowAgain and "V" or ""
        TweenService:Create(CheckBoxStroke, TweenInfo.new(0.2), { Color = dontShowAgain and Color3.fromRGB(255,60,60) or Color3.fromRGB(60,60,60) }):Play()
    end)

    local ButtonsFrame = mk("ButtonsFrame", MainFrame)
    ButtonsFrame.BackgroundTransparency = 1; ButtonsFrame.Position = UDim2.new(0.05,0,0.30,0); ButtonsFrame.Size = UDim2.new(0.9,0,0.46,0); ButtonsFrame.Visible = false
    local UIGridLayout = Instance.new("UIGridLayout", ButtonsFrame)
    UIGridLayout.CellSize = UDim2.new(0.44,0,0.20,0); UIGridLayout.CellPadding = UDim2.new(0.04,0,0.03,0)
    UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    SkipButton = mk("SkipButton", MainFrame, "TextButton")
    SkipButton.BackgroundColor3 = Color3.fromRGB(25,25,25); SkipButton.Position = UDim2.new(0.35,0,0.88,0); SkipButton.Size = UDim2.new(0.3,0,0.08,0)
    SkipButton.Font = Enum.Font.SourceSansBold; SkipButton.TextColor3 = Color3.fromRGB(200,200,200); SkipButton.TextScaled = true; SkipButton.Visible = false
    Instance.new("UICorner", SkipButton).CornerRadius = UDim.new(0,8)
    local UIStroke_Skip = Instance.new("UIStroke", SkipButton); UIStroke_Skip.Thickness = 1; UIStroke_Skip.Color = Color3.fromRGB(40,40,40)
    applyHoverEffect(SkipButton, Color3.fromRGB(25,25,25), Color3.fromRGB(35,35,35))

    SkipButton.MouseButton1Click:Connect(function()
        local ct = TweenService:Create(SkipButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = SkipButton.Size - UDim2.new(0.04,0,0.04,0), Position = SkipButton.Position + UDim2.new(0.02,0,0.02,0) })
        ct:Play(); ct.Completed:Wait()
        saveDontShowSetting(dontShowAgain)
        task.spawn(launchMM2, getSavedLanguageCode())
        closeMenu()
    end)

    for _, lang in ipairs(Languages) do
        local btn = mk(lang.Name .. "Button", ButtonsFrame, "TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(30,30,30); btn.Text = lang.Display; btn.TextColor3 = Color3.fromRGB(255,255,255); btn.TextScaled = true; btn.Font = Enum.Font.SourceSansBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        local btnStroke = Instance.new("UIStroke", btn); btnStroke.Thickness = 1.5; btnStroke.Color = Color3.fromRGB(60,60,60)
        applyHoverEffect(btn, Color3.fromRGB(30,30,30), Color3.fromRGB(45,45,45))
        btn.MouseButton1Click:Connect(function()
            local ct = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = btn.Size - UDim2.new(0.04,0,0.04,0), Position = btn.Position + UDim2.new(0.02,0,0.02,0) })
            ct:Play(); ct.Completed:Wait()
            saveLanguageSetting(lang.Name)
            saveDontShowSetting(dontShowAgain)
            updateUIText(lang.Code)
            task.wait(0.3)
            task.spawn(launchMM2, lang.Code)
            closeMenu()
        end)
    end

    PlayButton.MouseButton1Click:Connect(function()
        local ct = TweenService:Create(PlayButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = PlayButton.Size - UDim2.new(0.04,0,0.04,0), Position = PlayButton.Position + UDim2.new(0.02,0,0.02,0) })
        ct:Play(); ct.Completed:Wait()
        if getSavedDontShowSetting() then
            task.spawn(launchMM2, getSavedLanguageCode())
            closeMenu()
            return
        end
        PlayButton.Visible = false; ExitButton.Visible = false
        local activeCode = getSavedLanguageCode()
        updateUIText(activeCode)
        TweenService:Create(SPHub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.05,0,0.05,0), Size = UDim2.new(0.9,0,0.12,0) }):Play()
        TweenService:Create(GameNameLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.05,0,0.22,0), Size = UDim2.new(0.9,0,0.08,0) }):Play()
        local resizeTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0.35,0,0.45,0) })
        local ratioTween = TweenService:Create(UIAspectRatioConstraint, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { AspectRatio = 1.2 })
        resizeTween:Play(); ratioTween:Play(); resizeTween.Completed:Wait()
        ButtonsFrame.Visible = true; DontShowFrame.Visible = true; SkipButton.Visible = true
    end)
else
    StarterGui:SetCore("SendNotification", { Title = "SP Hub | MM2", Text = T("Unsupported"), Duration = 3 })
end

-- ================= SECAO MM2 =================
local st = { sp=false, fl=false, nc=false, espR=false, espG=false, xr=false, sa=false, at=false, kill=false, cf=false, ag=false, afk=false, ac=false }
local G, CF, startFarm, stopFarm, unload
local running = true
local function Notif(t,x) StarterGui:SetCore("SendNotification", { Title = t, Text = x, Duration = 3 }) end
local function HRP() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function alive() return LP:GetAttribute("Alive") ~= false end
local function has(p,n)
    local c = p.Character
    return (c and c:FindFirstChild(n)) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild(n) ~= nil)
end
local function tgt()
    local hrp = HRP(); if not hrp then return nil end
    local b, d = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
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
    local hrp = HRP(); if not hrp then return nil end
    local b, d = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
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
    local hrp = HRP()
    local d = hrp and (t.Position - hrp.Position).Magnitude or 50
    return t.CFrame + (t.Velocity * (0.06 + d * 0.002))
end

-- HOOKS SEGUROS
local oi
local M = LP:GetMouse()
local function validMouse() if not M or not M.Parent then M = LP:GetMouse() end return M end
local HAS_CC = (checkcaller ~= nil)
local SAok = pcall(function()
    oi = hookmetamethod(game, "__index", newcclosure(function(s,k)
        if getgenv().SZDUN and st.sa and (not HAS_CC or not checkcaller()) and rawequal(s, validMouse()) then
            if k == "Hit" then local t = tgtA(); if t then return pred(t) end end
            if k == "Target" then return tgtA() end
        end
        return oi(s,k)
    end))
end)
local on
local SHOOT_REMOTES = { Shoot=true, Fire=true, GunFired=true, PlayerShoot=true, ShootRemote=true, FireRemote=true }
local NCok = pcall(function()
    on = hookmetamethod(game, "__namecall", newcclosure(function(s,...)
        if getgenv().SZDUN and st.sa and HAS_CC and not checkcaller()
           and typeof(s) == "userdata" and s:IsA("RemoteEvent") and SHOOT_REMOTES[s.Name] then
            local a = { ... }; local t = tgtA()
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
end)

local keys = {}
local FLYKEYS = { [Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,[Enum.KeyCode.Space]=true,[Enum.KeyCode.LeftShift]=true }
UserInputService.InputBegan:Connect(function(i) if FLYKEYS[i.KeyCode] then keys[i.KeyCode]=true end end)
UserInputService.InputEnded:Connect(function(i) if FLYKEYS[i.KeyCode] then keys[i.KeyCode]=nil end end)

-- ESP
local espTags, gunTag = {}, nil
local function setTag(p,txt,col,showName,dist)
    local h = p.Character and p.Character:FindFirstChild("Head"); if not h then return end
    local e = espTags[p]
    if not e or not e.gui.Parent then
        local b = Instance.new("BillboardGui")
        b.Size = UDim2.new(0,130,0,28); b.AlwaysOnTop = true; b.MaxDistance = 700; b.StudsOffset = Vector3.new(0,3,0)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamBold; l.TextScaled = true; l.TextStrokeTransparency = .2
        e = { gui = b, label = l }; espTags[p] = e
    end
    e.gui.Parent = h
    e.label.Text = txt .. (showName and (" | "..p.Name) or "") .. (dist and (" | "..dist.."m") or "")
    e.label.TextColor3 = col
end
local function clear()
    for _, e in pairs(espTags) do pcall(function() e.gui:Destroy() end) end
    espTags = {}
end
local function refresh()
    local hrp = HRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("Head")
            local dist = hrp and h and math.floor((h.Position-hrp.Position).Magnitude+.5) or nil
            if has(p, "Knife") then setTag(p, "ASSASSINO", Color3.fromRGB(255,70,70), true, dist)
            elseif has(p, "Gun") then setTag(p, "XERIFE", Color3.fromRGB(70,160,255), true, dist)
            else setTag(p, p.Name, Color3.fromRGB(0,220,120), false) end
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
    gunDropCache = Workspace:FindFirstChild("GunDrop", true); return gunDropCache
end
local function espGun(v)
    if gunTag then pcall(function() gunTag:Destroy() end); gunTag = nil end
    if not v then return end
    local g = gunDrop(); if not g then return end
    local part = g:IsA("BasePart") and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
    if part then
        local b = Instance.new("BillboardGui", part)
        b.Name = "SZGUN"; b.Size = UDim2.new(0,100,0,24); b.AlwaysOnTop = true; b.StudsOffset = Vector3.new(0,1,0)
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamBold; l.TextScaled = true
        l.Text = "ARMA"; l.TextColor3 = Color3.fromRGB(255,200,60); l.TextStrokeTransparency = .2
        gunTag = b
    end
end

-- CACHES + NOCLIP
local myParts, myPartsCC = {}, {}
local function cacheMyParts(c)
    myParts = {}; myPartsCC = {}
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then myParts[#myParts+1] = v; myPartsCC[v] = v.CanCollide end
    end
end
local HumC = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if HumC then
    HumC:GetPropertyChangedSignal("EquipTool"):Connect(function() local c = LP.Character; if c then cacheMyParts(c) end end)
end
local xrayParts, xrayOn = {}, false
local function enableXray()
    xrayOn = true; xrayParts = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not (LP.Character and v:IsDescendantOf(LP.Character)) then
            v.LocalTransparencyModifier = .75; xrayParts[#xrayParts+1] = v
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
        v.LocalTransparencyModifier = .75; xrayParts[#xrayParts+1] = v
    end
end)
LP.CharacterAdded:Connect(function(c)
    task.wait(.5); cacheMyParts(c); clear()
    if CF and CF.farming then stopFarm() end
    if st.nc then for _, v in ipairs(myParts) do if v and v.Parent then v.CanCollide = false end end end
end)
if LP.Character then cacheMyParts(LP.Character) end

-- LOOP PRINCIPAL
task.spawn(function()
    local t2, t3, t4 = 0, 0, 0
    local lastAt, lastAC = 0, 0
    while running do
        local dt = RunService.Heartbeat:Wait()
        local okLoop, errLoop = pcall(function()
            local c = LP.Character
            local hrp = HRP()
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum then local ws = st.sp and 32 or 16; if hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end end
            if st.fl and hrp then
                local bv = hrp:FindFirstChild("SZBV")
                if not bv then
                    bv = Instance.new("BodyVelocity"); bv.Name = "SZBV"
                    bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = hrp
                end
                local f = (keys[Enum.KeyCode.W] and 1 or 0) - (keys[Enum.KeyCode.S] and 1 or 0)
                local r = (keys[Enum.KeyCode.D] and 1 or 0) - (keys[Enum.KeyCode.A] and 1 or 0)
                local u = (keys[Enum.KeyCode.Space] and 1 or 0) - (keys[Enum.KeyCode.LeftShift] and 1 or 0)
                bv.Velocity = (Camera.CFrame.LookVector*f + Camera.CFrame.RightVector*r + Vector3.new(0,u,0)) * 50
            elseif hrp then
                local bv = hrp:FindFirstChild("SZBV"); if bv then bv:Destroy() end
            end
            if st.nc then for i = 1, #myParts do local v = myParts[i]; if v and v.Parent then v.CanCollide = false end end end
            t4 = t4 + dt
            if t4 >= 1 then
                t4 = 0
                if st.espR then refresh() else clear() end
                if st.espG and not (gunTag and gunTag.Parent) then espGun(true) end
            end
            if st.at then
                local g = (c and c:FindFirstChild("Gun")) or (LP.Backpack and LP.Backpack:FindFirstChild("Gun"))
                local t = tgtA()
                if g and t then
                    if g.Parent ~= c then local h = c and c:FindFirstChildOfClass("Humanoid"); if h then h:EquipTool(g) end end
                    if os.clock() - lastAt > .15 then g:Activate(); lastAt = os.clock() end
                end
            end
            if st.kill then
                local k = c and c:FindFirstChild("Knife")
                local hd = tgt()
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
            t2 = t2 + dt
            if st.ag and t2 > .6 then
                t2 = 0
                local g = gunDrop()
                local part = g and (g:IsA("BasePart") and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart"))
                if alive() and part and part.Parent and hrp then
                    hrp.CFrame = part.CFrame * CFrame.new(0,0,2)
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
            t3 = t3 + dt
            if st.afk and t3 > 30 then
                t3 = 0
                pcall(function()
                    local VU = game:GetService("VirtualUser")
                    VU:CaptureController(); VU:ClickButton2(Vector2.new())
                end)
            end
            if st.ac then
                if os.clock() - lastAC > .08 then
                    lastAC = os.clock()
                    pcall(function() mouse1click() end)
                    pcall(function()
                        local VU = game:GetService("VirtualUser")
                        VU:CaptureController(); VU:ClickButton1(Vector2.new())
                    end)
                end
            end
        end)
        if not okLoop then warn("SzDunamis loop:", errLoop) end
    end
end)
RunService.RenderStepped:Connect(function()
    if not getgenv().SZDUN then return end
    if st.sa and alive() then
        local t = tgtA()
        if t and Camera then Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, t.Position), 0.35) end
    end
end)

-- COIN FARM
local coinBoxCache
local function box()
    if coinBoxCache and coinBoxCache.Parent then return coinBoxCache end
    coinBoxCache = Workspace:FindFirstChild("CoinContainer", true); return coinBoxCache
end
local function okCoin(cn)
    return cn and cn:GetAttribute("CoinID") == "Coin" and cn:FindFirstChild("TouchInterest") and cn.Transparency == 1
end
local function nearCoin()
    local hrp = HRP(); local b = box()
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
CF = { farming=false, collected=false, tw=nil, cool=0, parts={}, origCF=nil, coinStart=0 }
startFarm = function()
    local c = LP.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    CF.parts = {}
    for _, v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then CF.parts[v] = v.CanCollide end end
    for p, cc in pairs(CF.parts) do p.CanCollide = false end
    CF.origCF = hrp.CFrame
    hrp.CFrame = (hrp.CFrame - Vector3.new(0,2.5,0)) * CFrame.Angles(math.rad(90),0,0)
    hum.PlatformStand = true
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    CF.farming = true; CF.coinStart = os.clock()
end
stopFarm = function()
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
local CC = getR("CoinCollected")
if CC then CC.OnClientEvent:Connect(function(tp,a,b) if tp == "Coin" then CF.collected = (tonumber(a)==tonumber(b)) end end) end
local RSt = getR("RoundStart")
if RSt then RSt.OnClientEvent:Connect(function() CF.collected = false end) end
local RE = getR("RoundEndFade")
if RE then RE.OnClientEvent:Connect(function() CF.collected = false; if CF.farming then stopFarm() end end) end
RunService.Heartbeat:Connect(function()
    if not getgenv().SZDUN then return end
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
                local tw = TweenService:Create(hrp, TweenInfo.new(math.clamp(d/23, .1, 6), Enum.EasingStyle.Linear), {
                    CFrame = CFrame.new(cn.Position - Vector3.new(0,2.5,0)) * CFrame.Angles(math.rad(90),0,0) })
                CF.tw = tw; tw:Play()
                task.delay(math.clamp(d/23, .1, 6) + 1.2, function()
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

-- CONFIG
local CFG_FILE = "SzDunamisConfig.json"
local function saveCfg() pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(st)) end) end
local function loadCfg()
    pcall(function()
        local txt = readfile(CFG_FILE)
        if txt and #txt > 0 then
            local d = HttpService:JSONDecode(txt)
            if type(d) == "table" then
                for k, v in pairs(d) do if st[k] ~= nil and type(v) == "boolean" then st[k] = v end end
            end
        end
    end)
end
local toggles = {}
unload = function()
    if not getgenv().SZDUN then return end
    getgenv().SZDUN = false; running = false
    stopFarm()
    if xrayOn then disableXray() end
    clear(); espGun(false)
    for k in pairs(st) do local set = toggles[k]; if set then set(false) end end
    saveCfg()
    if G then pcall(function() G:Destroy() end) end
    Notif("SP Hub | MM2", T("Unloaded"))
end

-- UI MM2
local PUR = Color3.fromRGB(150,20,255)
local ROW = Color3.fromRGB(26,26,36)
local IMG = "rbxassetid://112169216"
launchMM2 = function(langCode)
    getgenv().SP_Hub_Language = langCode or "en"
    local PW, PH = 480, 320
    G = Instance.new("ScreenGui")
    G.Name = "SZDUN_GUI"; G.ResetOnSpawn = false; G.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    G.Parent = PlayerGui
    getgenv().SZDUN_GUI = G
    local Pn = mk("Main", G)
    Pn.Position = UDim2.new(.5,0,.5,0); Pn.Size = UDim2.new(0,PW,0,PH)
    Pn.BackgroundColor3 = Color3.fromRGB(13,13,19); Pn.ZIndex = 1
    Instance.new("UICorner", Pn).CornerRadius = UDim.new(0,18)
    local PS = Instance.new("UIStroke", Pn); PS.Thickness = 2; PS.Color = PUR; PS.Transparency = .4
    local Bg = Instance.new("ImageLabel", Pn)
    Bg.Size = UDim2.new(1,0,1,0); Bg.BackgroundTransparency = 1; Bg.Image = IMG
    Bg.ScaleType = Enum.ScaleType.Crop; Bg.ImageTransparency = .88; Bg.ZIndex = 1
    local TB = mk("TitleBar", Pn)
    TB.Size = UDim2.new(1,0,.13,0); TB.BackgroundTransparency = 1; TB.ZIndex = 3
    makeDraggable(Pn, TB)
    local Lg = Instance.new("ImageLabel", TB)
    Lg.Size = UDim2.fromOffset(38,38); Lg.Position = UDim2.new(.04,0,.5,0); Lg.AnchorPoint = Vector2.new(0,.5)
    Lg.Image = IMG; Lg.BackgroundColor3 = Color3.fromRGB(8,8,12); Lg.BackgroundTransparency = .25
    Instance.new("UICorner", Lg).CornerRadius = UDim.new(1,0)
    local Tt = mk("Title", TB, "TextLabel")
    Tt.Position = UDim2.new(.18,0,.12,0); Tt.Size = UDim2.new(.6,0,.4,0); Tt.BackgroundTransparency = 1
    Tt.Text = "SP Hub"; Tt.Font = Enum.Font.Michroma; Tt.TextScaled = true; Tt.TextColor3 = Color3.fromRGB(255,255,255)
    local Sub = mk("Sub", TB, "TextLabel")
    Sub.Position = UDim2.new(.18,0,.55,0); Sub.Size = UDim2.new(.6,0,.35,0); Sub.BackgroundTransparency = 1
    Sub.Text = "Murder Mystery 2"; Sub.Font = Enum.Font.GothamBold; Sub.TextScaled = true
    Sub.TextColor3 = Color3.fromRGB(150,150,170); Sub.TextXAlignment = Enum.TextXAlignment.Left
    local XBtn = mk("X", TB, "TextButton")
    XBtn.Size = UDim2.fromOffset(30,30); XBtn.AnchorPoint = Vector2.new(1,.5); XBtn.Position = UDim2.new(.97,0,.5,0)
    XBtn.BackgroundColor3 = Color3.fromRGB(255,60,60); XBtn.Text = "X"
    XBtn.Font = Enum.Font.SourceSansBold; XBtn.TextScaled = true; XBtn.TextColor3 = Color3.fromRGB(255,255,255); XBtn.ZIndex = 4
    Instance.new("UICorner", XBtn).CornerRadius = UDim.new(1,0)
    XBtn.MouseButton1Click:Connect(function() task.spawn(unload) end)

    local Tabs = T("Tabs"); local TBs, Pgs = {}, {}
    local function Show(i)
        for j, pg in ipairs(Pgs) do pg.Visible = (j == i) end
        for j, b in ipairs(TBs) do
            local v = j == i
            TweenService:Create(b, TweenInfo.new(.2), { BackgroundColor3 = v and PUR or ROW }):Play()
            TweenService:Create(b, TweenInfo.new(.2), { TextColor3 = v and Color3.fromRGB(255,255,255) or Color3.fromRGB(190,190,210) }):Play()
        end
    end
    local TBr = mk("TabBar", Pn)
    TBr.Position = UDim2.new(0,0,.13,0); TBr.Size = UDim2.new(1,0,.08,0); TBr.BackgroundTransparency = 1; TBr.ZIndex = 3
    for i, nm in ipairs(Tabs) do
        local b = mk("Tab", TBr, "TextButton")
        b.Size = UDim2.new(.19,0,.72,0); b.Position = UDim2.new(.015+(i-1)*.198,0,.14,0)
        b.BackgroundColor3 = ROW; b.Text = nm; b.Font = Enum.Font.GothamBold; b.TextScaled = true
        b.TextColor3 = Color3.fromRGB(190,190,210); b.ZIndex = 2
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        TBs[i] = b; b.MouseButton1Click:Connect(function() Show(i) end)
    end
    local Ct = mk("Content", Pn)
    Ct.Position = UDim2.new(.04,0,.23,0); Ct.Size = UDim2.new(.92,0,.74,0); Ct.BackgroundTransparency = 1; Ct.ZIndex = 3
    for i = 1, #Tabs do
        local pg = Instance.new("ScrollingFrame", Ct)
        pg.Size = UDim2.new(1,0,1,0); pg.BackgroundTransparency = 1; pg.ZIndex = 3
        pg.ScrollingDirection = Enum.ScrollingDirection.Y; pg.ScrollBarThickness = 3
        pg.ScrollBarImageColor3 = PUR; pg.CanvasSize = UDim2.new(0,0,0,0)
        Pgs[i] = pg
    end
    local function Mk(pg, label, state, fn)
        local i = #pg:GetChildren() + 1
        local row = mk("Toggle", pg)
        row.Size = UDim2.new(1,0,0,56); row.Position = UDim2.new(0,0,0,6+(i-1)*66)
        row.BackgroundColor3 = ROW; row.ZIndex = 2
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
        local lb = mk("Label", row, "TextLabel")
        lb.Size = UDim2.new(.6,0,1,0); lb.Position = UDim2.new(.06,0,0,0); lb.BackgroundTransparency = 1
        lb.Text = label; lb.Font = Enum.Font.GothamBold; lb.TextScaled = true
        lb.TextXAlignment = Enum.TextXAlignment.Left; lb.TextColor3 = Color3.fromRGB(235,235,245); lb.ZIndex = 3
        local sw = mk("Switch", row, "TextButton")
        sw.Size = UDim2.fromOffset(48,26); sw.AnchorPoint = Vector2.new(1,.5); sw.Position = UDim2.new(.94,0,.5,0)
        sw.BackgroundColor3 = Color3.fromRGB(24,24,32); sw.ZIndex = 3
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)
        local on = mk("ON", sw, "TextLabel")
        on.Size = UDim2.new(1,0,1,0); on.BackgroundTransparency = 1; on.Text = "ON"
        on.Font = Enum.Font.GothamBold; on.TextScaled = true; on.TextColor3 = Color3.fromRGB(255,255,255); on.ZIndex = 4
        local off = mk("OFF", sw, "TextLabel")
        off.Size = UDim2.new(1,0,1,0); off.BackgroundTransparency = 1; off.Text = "OFF"
        off.Font = Enum.Font.GothamBold; off.TextScaled = true; off.TextColor3 = Color3.fromRGB(130,130,150); off.ZIndex = 4
        local gl = mk("Glow", row)
        gl.Size = UDim2.new(1,0,1,0); gl.BackgroundColor3 = PUR; gl.BackgroundTransparency = 1; gl.ZIndex = 1; gl.Visible = false
        Instance.new("UICorner", gl).CornerRadius = UDim.new(0,10)
        local function set(v)
            st[state] = v
            TweenService:Create(sw, TweenInfo.new(.22), { BackgroundColor3 = v and PUR or Color3.fromRGB(24,24,32) }):Play()
            on.Visible = v; off.Visible = not v; gl.Visible = v
            if v then TweenService:Create(gl, TweenInfo.new(.3), { BackgroundTransparency = .5 }):Play() end
            if fn then fn(state, v) end
            saveCfg()
        end
        sw.MouseButton1Click:Connect(function() set(not st[state]) end)
        toggles[state] = set
    end
    local function MkBtn(pg, label, fn)
        local i = #pg:GetChildren() + 1
        local row = mk("Btn", pg, "TextButton")
        row.Size = UDim2.new(1,0,0,76); row.Position = UDim2.new(0,0,0,6+(i-1)*86)
        row.BackgroundColor3 = ROW; row.Text = label; row.Font = Enum.Font.GothamBold; row.TextScaled = true
        row.TextColor3 = Color3.fromRGB(235,235,245); row.ZIndex = 2
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
        row.MouseButton1Click:Connect(function() if fn then fn() end end)
    end
    Mk(Pgs[1], T("Sp"), "sp")
    Mk(Pgs[1], T("Fl"), "fl")
    Mk(Pgs[1], T("Nc"), "nc", function(_, v)
        if v then for _, p in ipairs(myParts) do if p and p.Parent then p.CanCollide = false end end
        else for i, p in ipairs(myParts) do if p and p.Parent and myPartsCC[p] then p.CanCollide = myPartsCC[p] end end end
    end)
    Mk(Pgs[2], T("EspR"), "espR", function(_, v) if v then refresh() else clear() end end)
    Mk(Pgs[2], T("EspG"), "espG", function(_, v) espGun(v) end)
    Mk(Pgs[2], T("Xr"), "xr", function(_, v) if v then enableXray() else disableXray() end end)
    Mk(Pgs[3], T("Sa"), "sa", function(_, v)
        if v and not HAS_CC then Notif("SP Hub | MM2", "Sem checkcaller: silent aim usara lock de camera") end
        if v and not SAok and not NCok then Notif("SP Hub | MM2", "Sem hooks: silent aim usara lock de camera") end
    end)
    Mk(Pgs[3], T("At"), "at")
    Mk(Pgs[3], T("Kill"), "kill")
    Mk(Pgs[4], T("Cf"), "cf")
    Mk(Pgs[4], T("Ag"), "ag")
    Mk(Pgs[4], T("Afk"), "afk")
    Mk(Pgs[5], T("Ac"), "ac")
    MkBtn(Pgs[5], T("Ul"), function() task.spawn(unload) end)
    for _, pg in ipairs(Pgs) do
        local h = 12
        for _, ch in ipairs(pg:GetChildren()) do h = h + (ch.Size.Y.Offset or 0) + 6 end
        pg.CanvasSize = UDim2.new(0,0,0,h)
    end
    Show(1)
    local Orb = mk("Orb", G, "TextButton")
    Orb.Size = UDim2.fromOffset(36,36); Orb.AnchorPoint = Vector2.new(.5,.5); Orb.Position = UDim2.new(0,36,1,-46)
    Orb.BackgroundColor3 = Color3.fromRGB(0,0,0); Orb.Text = "sz"; Orb.Font = Enum.Font.Michroma; Orb.TextScaled = true
    Orb.TextColor3 = Color3.fromRGB(255,255,255); Orb.Visible = true; Orb.ZIndex = 5
    Instance.new("UICorner", Orb).CornerRadius = UDim.new(1,0)
    local OG = mk("OrbGlow", G)
    OG.Size = UDim2.fromOffset(46,46); OG.AnchorPoint = Vector2.new(.5,.5); OG.Position = Orb.Position
    OG.BackgroundColor3 = PUR; OG.BackgroundTransparency = .7; OG.ZIndex = 4; OG.Visible = true
    Instance.new("UICorner", OG).CornerRadius = UDim.new(1,0)
    local odrag, oisDrag, ostPt = false, false
    Orb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then odrag = true; ostPt = i.Position; oisDrag = false end
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
        if i.KeyCode == Enum.KeyCode.RightShift and Pn and getgenv().SZDUN then Pn.Visible = not Pn.Visible end
    end)
    loadCfg()
    for k in pairs(st) do local set = toggles[k]; if set then set(st[k]) end end
    Notif("SP Hub | MM2", T("Loaded"))
end

-- ================= SEQUENCIA DE LOADING =================
local function runLoadingSequence()
    LoadingFrame.Visible = true
    local openTween = TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0.3,0,0.3,0) })
    openTween:Play(); openTween.Completed:Wait()
    LogoImage.Visible = true; LogoImage.ImageTransparency = 1
    local logoFade = TweenService:Create(LogoImage, TweenInfo.new(0.3), { ImageTransparency = 0 })
    logoFade:Play(); logoFade.Completed:Wait()
    task.wait(1)
    local fadeLogo = TweenService:Create(LogoImage, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 1 })
    fadeLogo:Play(); fadeLogo.Completed:Wait()
    local fadeBgInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local elementsFadeOut = {
        TweenService:Create(LoadingFrame, fadeBgInfo, { BackgroundTransparency = 1 }),
        TweenService:Create(UIStroke_Load, fadeBgInfo, { Transparency = 1 })
    }
    for _, tween in ipairs(elementsFadeOut) do tween:Play() end
    elementsFadeOut[1].Completed:Wait()
    LoadingFrame.Visible = false
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5,0,0.5,0) }):Play()
end
task.spawn(runLoadingSequence)
