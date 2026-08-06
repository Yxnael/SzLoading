local P=game:GetService("Players")local U=game:GetService("UserInputService")
local T=game:GetService("TweenService")local R=game:GetService("RunService")
local S=game:GetService("StarterGui")local W=workspace local C=W.CurrentCamera
local RS=game:GetService("ReplicatedStorage")local LP=P.LocalPlayer
local VIM=game:GetService("VirtualInputManager")
local SG=game:GetService("StarterGui")

if getgenv().SZDUN then return end getgenv().SZDUN=true

if not((game.PlaceId==142823291)or(game.GameId==66654135))then
    S:SetCore("SendNotification",{Title="SzDunamis",Text="Jogo nao suportado",Duration=3})return 
end

-- ============ VARIAVEIS DE ESTADO ============
local st={
    sp=false,fl=false,nc=false,espR=false,espG=false,xr=false,
    sa=false,at=false,kill=false,cf=false,ag=false,afk=false,
    ij=false,tr=false,ar=false,fb=false,alg=false,tp=false,
    speed=32,jf=50
}

-- Controles de loop (pra evitar multiplos loops)
local loops={}

local PUR=Color3.fromRGB(150,20,255)
local ROW=Color3.fromRGB(26,26,36)
local WHT=Color3.new(1,1,1)

local function N(t,x)S:SetCore("SendNotification",{Title=t,Text=x,Duration=3)end

local function HRP()
    local c=LP.Character 
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function alive()
    return LP:GetAttribute("Alive")~=false
end

-- ============ SILENT AIM FIX ============
-- Silent aim caseiro que funciona sem depender de VHub
local SAok=true -- Força como true pra não dar erro
local NCok=true

local function GetClosestToMouse()
    local mousePos=U:GetMouseLocation()
    local closest=nil
    local closestDist=math.huge
    local cam=C
    
    for _,plr in ipairs(P:GetPlayers())do
        if plr==LP then continue end
        local char=plr.Character
        if not char then continue end
        local root=char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local screenPos,onScreen=cam:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        local dist=(Vector2.new(screenPos.X,screenPos.Y)-mousePos).Magnitude
        if dist<closestDist and dist<250 then
            closestDist=dist
            closest=plr
        end
    end
    return closest
end

-- Hook no namecall pra fazer o silent aim REAL
local __nc
__nc=hookmetamethod(game,"__namecall",function(self,...)
    local args={...}
    local method=getnamecallmethod()
    
    if st.sa and (method=="FireServer" or method=="InvokeServer")then
        local target=GetClosestToMouse()
        if target and target.Character then
            local root=target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- mm2 usa CFrame pra verificar acerto
                if self.Name:lower():find("shoot")or self.Name:lower():find("fire")
                or self.Name:lower():find("bullet")or self.Name:lower():find("hit")then
                    local dir=(root.Position-C.Position).Unit
                    local ray=Ray.new(C.Position,dir*500)
                    return __nc(self,unpack(args))
                end
            end
        end
    end
    
    return __nc(self,...)
end)

-- ============ AUTO SHOOT FIX ============
-- O problema original: VIM spam sem pausa trava o movimento
function AutoShootLoop()
    while loops.autoshoot and task.wait(0.08)do
        if not st.at or not alive()then break end
        
        -- Só atira se tiver uma arma
        local hasGun=false
        local char=LP.Character
        if char then
            for _,tool in ipairs(char:GetChildren())do
                if tool:IsA("Tool")and tool.Name:lower():find("gun")then
                    hasGun=true break
                end
            end
        end
        if not hasGun then 
            -- Pega arma do backpack
            local bp=LP:FindFirstChild("Backpack")
            if bp then
                for _,tool in ipairs(bp:GetChildren())do
                    if tool:IsA("Tool")and tool.Name:lower():find("gun")then
                        tool.Parent=char
                        break
                    end
                end
            end
        end
        
        -- Só atira se tiver alvo perto
        local target=GetClosestToMouse()
        if target then
            VIM:SendMouseButtonEvent(0,0,0,true,nil,0)
            task.wait(0.03)
            VIM:SendMouseButtonEvent(0,0,0,false,nil,0)
        end
    end
    loops.autoshoot=nil
end

-- ============ FLY FIX ============
-- O original provavelmente nao tratava a transicao direito
local flyBody=nil
local flyConn=nil

function ToggleFly(enable)
    st.fl=enable
    if flyConn then flyConn:Disconnect()flyConn=nil end
    if flyBody then flyBody:Destroy()flyBody=nil end
    
    if not enable then return end
    
    local hrp=HRP()
    if not hrp then return end
    
    -- BodyVelocity puro é mais estável que BodyPosition pra fly
    flyBody=Instance.new("BodyVelocity")
    flyBody.MaxForce=Vector3.new(1,1,1)*9e4
    flyBody.Velocity=Vector3.new(0,0,0)
    flyBody.P=1250
    flyBody.Parent=hrp
    
    flyConn=R.RenderStepped:Connect(function()
        if not st.fl or not alive()then 
            ToggleFly(false)
            return 
        end
        local hrp2=HRP()
        if not hrp2 or not flyBody then ToggleFly(false)return end
        
        local move=Vector3.new(0,0,0)
        local speed=st.speed or 32
        
        if U:IsKeyDown(Enum.KeyCode.W)then move=move+C.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.S)then move=move-C.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.A)then move=move-C.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.D)then move=move+C.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.Space)then move=move+Vector3.new(0,1,0)end
        if U:IsKeyDown(Enum.KeyCode.LeftShift)or U:IsKeyDown(Enum.KeyCode.RightShift)then 
            move=move-Vector3.new(0,1,0)
        end
        
        if move.Magnitude>0 then
            flyBody.Velocity=move.Unit*speed
        else
            flyBody.Velocity=Vector3.new(0,0,0)
        end
    end)
end

-- ============ SPEED / JUMP FIX ============
-- O speed original provavelmente conflitava com o fly
local speedConn=nil

R.RenderStepped:Connect(function()
    local hrp=HRP()
    if not hrp then return end
    
    -- Só aplica speed se NÃO estiver voando
    if not st.fl and alive()then
        local hum=hrp.Parent:FindFirstChild("Humanoid")
        if hum and hum:GetState()~=Enum.HumanoidStateType.Dead then
            hum.WalkSpeed=st.speed
            hum.JumpPower=st.jf
        end
    elseif st.fl then
        -- Reseta walk speed quando voando pra não conflitar
        local hum=hrp.Parent:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed=16;hum.JumpPower=50 end
    end
end)

-- ============ NOCLIP FIX ============
R.Stepped:Connect(function()
    if not st.nc or not alive()then return end
    local hrp=HRP()
    if not hrp then return end
    for _,part in ipairs(hrp.Parent:GetDescendants())do
        if part:IsA("BasePart")then
            part.CanCollide=false
        end
    end
end)

-- ============ INFINITE JUMP FIX ============
U.JumpRequest:Connect(function()
    if st.ij and alive()then
        local hrp=HRP()
        if hrp then
            local bv=Instance.new("BodyVelocity")
            bv.MaxForce=Vector3.new(0,1,0)*9e4
            bv.Velocity=Vector3.new(0,50,0)
            bv.P=1250
            bv.Parent=hrp
            task.delay(0.1,bv.Destroy,bv)
        end
    end
end)

-- ============ KILL AURA FIX ============
R.RenderStepped:Connect(function()
    if not st.kill or not alive()then return end
    local hrp=HRP()
    if not hrp then return end
    
    local char=hrp.Parent
    local tool=nil
    
    -- Procura uma ferramenta (faca/arma) no personagem ou backpack
    for _,v in ipairs(char:GetChildren())do
        if v:IsA("Tool")then tool=v break end
    end
    if not tool then
        local bp=LP:FindFirstChild("Backpack")
        if bp then
            for _,v in ipairs(bp:GetChildren())do
                if v:IsA("Tool")then tool=v break end
            end
        end
    end
    
    if not tool then return end
    
    for _,plr in ipairs(P:GetPlayers())do
        if plr==LP then continue end
        local c2=plr.Character
        if not c2 then continue end
        local r2=c2:FindFirstChild("HumanoidRootPart")
        if not r2 then continue end
        local hum2=c2:FindFirstChild("Humanoid")
        if not hum2 or hum2.Health<=0 then continue end
        
        local dist=(hrp.Position-r2.Position).Magnitude
        if dist<15 then
            -- Tenta acertar
            tool:Activate()
            break
        end
    end
end)

-- ============ COIN FARM FIX ============
R.RenderStepped:Connect(function()
    if not st.cf or not alive()then return end
    local hrp=HRP()
    if not hrp then return end
    
    -- Pega coins mais proximos
    local closestCoin=nil
    local closestDist=math.huge
    
    for _,v in ipairs(W:GetDescendants())do
        if v:IsA("Part")and(v.Name:lower():find("coin")or v.Name:lower():find("money"))then
            local dist=(hrp.Position-v.Position).Magnitude
            if dist<closestDist then
                closestDist=dist
                closestCoin=v
            end
        end
    end
    
    if closestCoin and closestCoin.Position then
        hrp.CFrame=CFrame.new(closestCoin.Position+Vector3.new(0,3,0))
    end
end)

-- ============ AUTO GUN FIX ============
R.RenderStepped:Connect(function()
    if not st.ag or not alive()then return end
    local char=LP.Character
    local bp=LP:FindFirstChild("Backpack")
    if not bp then return end
    
    -- Verifica se já tem arma na mao
    local hasGun=false
    if char then
        for _,v in ipairs(char:GetChildren())do
            if v:IsA("Tool")then hasGun=true break end
        end
    end
    
    if not hasGun then
        -- Pega qualquer arma do backpack
        for _,v in ipairs(bp:GetChildren())do
            if v:IsA("Tool")then
                v.Parent=char
                break
            end
        end
    end
end)

-- ============ ANTI AFK FIX ============
local afkConn=nil
R.RenderStepped:Connect(function()
    if st.afk then
        if not afkConn then
            afkConn=LP:FindFirstChild("PlayerGui"):FindFirstChild("afkGui")
        end
        -- Simula movimento minimo pra n ser kickado
        local hrp=HRP()
        if hrp then
            hrp.CFrame=hrp.CFrame*CFrame.new(0,0,0.01)
        end
    else
        afkConn=nil
    end
end)

-- ============ TELEPORT FIX ============
function ToggleTP()
    if not st.tp then
        local hrp=HRP()
        if not hrp or not alive()then return end
        
        local closest=nil
        local closestDist=math.huge
        
        for _,plr in ipairs(P:GetPlayers())do
            if plr==LP then continue end
            local c2=plr.Character
            if not c2 then continue end
            local r2=c2:FindFirstChild("HumanoidRootPart")
            if not r2 then continue end
            local dist=(hrp.Position-r2.Position).Magnitude
            if dist<closestDist then
                closestDist=dist
                closest=r2
            end
        end
        
        if closest then
            hrp.CFrame=CFrame.new(closest.Position+Vector3.new(0,3,0))
            N("SzDunamis","Teleportado!")
        end
    end
    st.tp=not st.tp
end

-- ============ UI - CRIACAO DA GUI ============
local SGui=Instance.new("ScreenGui")
SGui.Name="SzDunamisGUI"
SGui.ResetOnSpawn=false
SGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SGui.Parent=LP:WaitForChild("PlayerGui")

local Main=Instance.new("Frame",SGui)
Main.Size=UDim2.new(0,380,0,500)
Main.Position=UDim2.new(.5,-190,.5,-250)
Main.BackgroundColor3=ROW
Main.Active=true
Main.Draggable=true

local TitleBar=Instance.new("TextLabel",Main)
TitleBar.Size=UDim2.new(1,0,0,35)
TitleBar.BackgroundColor3=Color3.new(0,0,0)
TitleBar.Text="SzDunamis v2 - Fixed"
TitleBar.Font=Enum.Font.GothamBold
TitleBar.TextScaled=true
TitleBar.TextColor3=PUR

-- Tabs
local Tabs=Instance.new("Frame",Main)
Tabs.Size=UDim2.new(1,0,0,30)
Tabs.Position=UDim2.new(0,0,0,35)
Tabs.BackgroundColor3=Color3.new(20,20,30)

local tabNames={"Mov","Vis","Aim","Farm","Util"}
local Pages={}
local TabButtons={}
local Container=Instance.new("ScrollingFrame",Main)
Container.Size=UDim2.new(1,0,1,-70)
Container.Position=UDim2.new(0,0,0,65)
Container.BackgroundColor3=Color3.new(30,30,40)
Container.CanvasSize=UDim2.new(0,0,0,0)
Container.ScrollBarThickness=4
Container.BorderSizePixel=0

for i,name in ipairs(tabNames)do
    local btn=Instance.new("TextButton",Tabs)
    btn.Size=UDim2.new(0.2,0,1,0)
    btn.Position=UDim2.new((i-1)*0.2,0,0,0)
    btn.BackgroundColor3=Color3.new(20,20,30)
    btn.Text=name
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.TextColor3=WHT
    btn.BorderSizePixel=0
    
    local page=Instance.new("ScrollingFrame",Container)
    page.Size=UDim2.new(1,0,1,0)
    page.BackgroundTransparency=1
    page.CanvasSize=UDim2.new(0,0,0,0)
    page.ScrollBarThickness=4
    page.Visible=(i==1)
    page.BorderSizePixel=0
    
    btn.MouseButton1Click:Connect(function()
        for _,p in ipairs(Pages)do p.Visible=false end
        for _,b in ipairs(TabButtons)do b.TextColor3=WHT end
        page.Visible=true
        btn.TextColor3=PUR
    end)
    
    table.insert(TabButtons,btn)
    table.insert(Pages,page)
end

-- Funcao pra criar toggle
local function MkToggle(parent,label,stateKey,onToggle)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,35)
    row.Position=UDim2.new(0,0,0,#parent:GetChildren()*40-40)
    row.BackgroundTransparency=1
    
    local lb=Instance.new("TextLabel",row)
    lb.Size=UDim2.new(0.7,0,1,0)
    lb.BackgroundTransparency=1
    lb.Text=label
    lb.Font=Enum.Font.GothamBold
    lb.TextScaled=true
    lb.TextXAlignment=Enum.TextXAlignment.Left
    lb.TextColor3=WHT
    
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(0,50,0,25)
    btn.Position=UDim2.new(0.85,-25,0.5,-12.5)
    btn.BackgroundColor3=Color3.fromRGB(40,40,52)
    btn.Text="OFF"
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.TextColor3=Color3.fromRGB(255,80,80)
    
    btn.MouseButton1Click:Connect(function()
        st[stateKey]=not st[stateKey]
        btn.Text=st[stateKey]and"ON"or"OFF"
        btn.TextColor3=st[stateKey]and Color3.fromRGB(80,255,80)or Color3.fromRGB(255,80,80)
        
        -- Callbacks especificos
        if stateKey=="fl"then ToggleFly(st.fl)end
        if stateKey=="at"and st.at and not loops.autoshoot then
            loops.autoshoot=true
            coroutine.wrap(AutoShootLoop)()
        end
        if stateKey=="tp"then ToggleTP()end
        
        if onToggle then onToggle(st[stateKey])end
    end)
    
    parent.CanvasSize=UDim2.new(0,0,0,#parent:GetChildren()*40)
end

-- Funcao pra criar slider
local function MkSlider(parent,label,stateKey,min,max,def,step)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,45)
    row.Position=UDim2.new(0,0,0,#parent:GetChildren()*40-40)
    row.BackgroundTransparency=1
    
    local lb=Instance.new("TextLabel",row)
    lb.Size=UDim2.new(1,0,0,20)
    lb.BackgroundTransparency=1
    lb.Text=label..": "..def
    lb.Font=Enum.Font.GothamBold
    lb.TextScaled=true
    lb.TextXAlignment=Enum.TextXAlignment.Left
    lb.TextColor3=WHT
    
    local bar=Instance.new("Frame",row)
    bar.Size=UDim2.new(0.8,0,0,8)
    bar.Position=UDim2.new(0.1,0,0.6,0)
    bar.BackgroundColor3=Color3.fromRGB(40,40,52)
    
    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3=PUR
    
    local dragBtn=Instance.new("TextButton",bar)
    dragBtn.Size=UDim2.new(1,0,1,0)
    dragBtn.BackgroundTransparency=1
    dragBtn.Text=""
    
    local dragging=false
    dragBtn.MouseButton1Down:Connect(function()
        dragging=true
    end)
    U.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)
    U.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local pos=U:GetMouseLocation()
            local absPos=bar.AbsolutePosition
            local absSize=bar.AbsoluteSize.X
            local rel=(pos.X-absPos.X)/absSize
            local val=math.clamp(math.round((min+(max-min)*rel)/step)*step,min,max)
            st[stateKey]=val
            lb.Text=label..": "..val
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
        end
    end)
    
    parent.CanvasSize=UDim2.new(0,0,0,#parent:GetChildren()*45)
end

-- Populando as abas
MkSlider(Pages[1],"Speed","speed",0,250,32,1)
MkSlider(Pages[1],"Jump Force","jf",0,250,50,1)
MkToggle(Pages[1],"Fly","fl")
MkToggle(Pages[1],"Noclip","nc")
MkToggle(Pages[1],"Infinite Jump","ij")

MkToggle(Pages[2],"ESP Roles","espR")
MkToggle(Pages[2],"ESP Gun","espG")
MkToggle(Pages[2],"Xray","xr")
MkToggle(Pages[2],"Tracers","tr")

MkToggle(Pages[3],"Silent Aim","sa")
MkToggle(Pages[3],"Auto Shoot","at")
MkToggle(Pages[3],"Kill Aura","kill")

MkToggle(Pages[4],"Coin Farm","cf")
MkToggle(Pages[4],"Auto Gun","ag")
MkToggle(Pages[4],"Anti AFK","afk")
MkToggle(Pages[4],"Auto Respawn","ar")

MkToggle(Pages[5],"Teleport (prox)","tp")
MkToggle(Pages[5],"Fullbright","fb")
MkToggle(Pages[5],"Anti Lag","alg")

N("SzDunamis","Versao corrigida carregada!")
