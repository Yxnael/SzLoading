-- SzDunamis MM2 - corrigido
local P=game:GetService("Players")
local U=game:GetService("UserInputService")
local T=game:GetService("TweenService")
local R=game:GetService("RunService")
local S=game:GetService("StarterGui")
local W=workspace
local C=W.CurrentCamera
local RS=game:GetService("ReplicatedStorage")
local LP=P.LocalPlayer
local VIM=game:GetService("VirtualInputManager")
if getgenv().SZDUN then return end
getgenv().SZDUN=true
if not((game.PlaceId==142823291)or(game.GameId==66654135))then
  S:SetCore("SendNotification",{Title="SzDunamis",Text="Jogo nao suportado",Duration=3})
  return
end
local st={sp=false,fl=false,nc=false,espR=false,espG=false,xr=false,sa=false,at=false,kill=false,cf=false,ag=false,afk=false,ij=false,tr=false,ar=false,fb=false,alg=false,tp=false,speed=32,jf=50}
local PUR=Color3.fromRGB(150,20,255)
local ROW=Color3.fromRGB(26,26,36)
local WHT=Color3.new(1,1,1)
local function N(t,x)S:SetCore("SendNotification",{Title=t,Text=x,Duration=3})end
local function HRP()local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart")end
local function HUM()local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid")end
local function alive()return LP:GetAttribute("Alive")~=false end
local function hasTool(par,n)if not par then return false end for _,v in ipairs(par:GetChildren())do if v:IsA("Tool")and string.lower(v.Name):find(string.lower(n))then return true end end return false end
local function has(p,n)return hasTool(p.Character,n)or hasTool(p:FindFirstChild("Backpack"),n)end
local function findGun()
  local function scan(par)if par then for _,tl in ipairs(par:GetChildren())do if tl:IsA("Tool")and string.lower(tl.Name):find("gun")then return tl end end end end
  return scan(LP.Character)or scan(LP.Backpack)
end
local function tgtA()
  local hrp=HRP()if not hrp or not alive()then return nil end
  local b,d=nil,math.huge
  for _,p in ipairs(P:GetPlayers())do
    if p~=LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
      local q=(p.Character.Head.Position-hrp.Position).Magnitude
      if q<d then d,b=q,p.Character.Head end
    end
  end
  return b
end
local function tgtAll()
  local out={}
  for _,p in ipairs(P:GetPlayers())do
    if p~=LP and p.Character and p.Character:FindFirstChild("Head") and p.Character.Head.Parent then table.insert(out,p.Character.Head)end
  end
  return out
end

local espFrames={}
local function clearEsp()for _,v in pairs(espFrames)do if v and v.Parent then v:Destroy()end end espFrames={}end
local function roleColor(p)
  if has(p,"gun")then return Color3.fromRGB(80,200,255)end
  if has(p,"knife")then return Color3.fromRGB(255,70,70)end
  return Color3.fromRGB(110,230,120)
end
local function refresh()
  clearEsp()
  for _,p in ipairs(P:GetPlayers())do
    if p~=LP and p.Character then
      local hrp=p.Character:FindFirstChild("HumanoidRootPart")
      local head=p.Character:FindFirstChild("Head")
      if hrp and head then
        local col=roleColor(p)
        local box=Instance.new("BoxHandleAdornment")box.Adornee=hrp box.Size=Vector3.new(4,5,2)box.Color3=col box.Transparency=.4 box.AlwaysOnTop=true box.ZIndex=3
        box.Parent=hrp table.insert(espFrames,box)
        local b=Instance.new("BillboardGui",head)b.Size=UDim2.new(0,140,0,30)b.Adornee=head b.AlwaysOnTop=true
        local l=Instance.new("TextLabel",b)l.Size=UDim2.new(1,0,1,0)l.BackgroundTransparency=1 l.Text=p.Name l.Font=Enum.Font.GothamBold l.TextScaled=true l.TextColor3=col
        table.insert(espFrames,b)
      end
    end
  end
end
local function espGun(v)
  clearEsp()
  if not v then return end
  for _,p in ipairs(P:GetPlayers())do
    if p~=LP and p.Character then
      for _,tl in ipairs(p.Character:GetChildren())do
        if tl:IsA("Tool")then
          local bh=Instance.new("BoxHandleAdornment")bh.Adornee=tl bh.Size=Vector3.new(2,1,1)bh.Color3=Color3.fromRGB(255,200,0)bh.Transparency=.3 bh.AlwaysOnTop=true
          bh.Parent=tl table.insert(espFrames,bh)
        end
      end
    end
  end
end
local xrayed={}
local function xrSet(v)
  if v then
    xrayed={}
    for _,p in ipairs(W:GetDescendants())do
      if p:IsA("BasePart")and not p:IsA("Terrain") then
        local m=p.Parent
        local isChar=(m and m:IsA("Model")and m:FindFirstChildOfClass("Humanoid")~=nil)
        if not isChar then p.LocalTransparencyModifier=.85 table.insert(xrayed,p)end
      end
    end
  else
    for _,p in ipairs(xrayed)do if p and p.Parent then p.LocalTransparencyModifier=0 end end
    xrayed={}
  end
end
local function fbSet(v)
  if v then
    game.Lighting.Ambient=Color3.new(1,1,1)game.Lighting.Brightness=2
  else
    game.Lighting.Ambient=Color3.new(0,0,0)game.Lighting.Brightness=1
  end
end
local function algOn()
  for _,v in ipairs(W:GetDescendants())do
    if v:IsA("BasePart")and v.Parent and v.Parent:IsA("Accessory")then v:Destroy()end
  end
end
local lines={}
if Drawing then
  for _=1,24 do local d=Drawing.new("Line")d.Thickness=1 d.Color=PUR d.Transparency=1 d.Visible=false table.insert(lines,d)end
end
-- FLY
R.Heartbeat:Connect(function()
  local hrp=HRP()
  if st.fl and hrp and alive() then
    local mv=Vector3.new(0,0,0)
    if U:IsKeyDown(Enum.KeyCode.W)then mv=mv+C.CFrame.LookVector end
    if U:IsKeyDown(Enum.KeyCode.S)then mv=mv-C.CFrame.LookVector end
    if U:IsKeyDown(Enum.KeyCode.A)then mv=mv-C.CFrame.RightVector end
    if U:IsKeyDown(Enum.KeyCode.D)then mv=mv+C.CFrame.RightVector end
    if U:IsKeyDown(Enum.KeyCode.Space)then mv=mv+Vector3.new(0,1,0)end
    if U:IsKeyDown(Enum.KeyCode.LeftShift)then mv=mv+Vector3.new(0,-1,0)end
    if mv.Magnitude>0 then mv=mv.Unit*st.speed end
    hrp.Velocity=mv
  elseif st.fl and not alive() then st.fl=false end
end)
-- NOCLIP
R.Stepped:Connect(function()
  local c=LP.Character
  if st.nc and c then
    for _,v in ipairs(c:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end
  end
end)
-- SPEED / JUMP
R.Heartbeat:Connect(function()
  local h=HUM()
  if h then
    if st.sp then h.WalkSpeed=st.speed elseif h.WalkSpeed~=16 then h.WalkSpeed=16 end
    if st.ij then h.JumpPower=math.max(st.jf,50)end
  end
end)
-- TRACERS
R.RenderStepped:Connect(function()
  if st.tr and C and #lines>0 then
    local i=0
    for _,t in ipairs(tgtAll())do
      i=i+1 local d=lines[i]
      if d then
        local s,sw=C:WorldToScreenPoint(C.CFrame.Position)
        local e,ew=C:WorldToScreenPoint(t.Position)
        d.Visible=(sw and ew)
        d.From=Vector2.new(s.X,s.Y)d.To=Vector2.new(e.X,e.Y)
      end
    end
    for j=i+1,#lines do lines[j].Visible=false end
  elseif #lines>0 then for _,d in ipairs(lines)do d.Visible=false end end
end)

-- Aimbot so no murder, SO com linha de visao livre
local function isMurder(p)
  return has(p,"knife")
end
local ignoreList={}
local function buildIgnore()
  ignoreList={}
  if LP.Character then table.insert(ignoreList,LP.Character)end
  for _,p in ipairs(P:GetPlayers())do
    if p~=LP and p.Character then table.insert(ignoreList,p.Character)end
  end
end
local function canSee(posA,posB)
  local params=RaycastParams.new()
  params.FilterType=Enum.RaycastFilterType.Exclude
  buildIgnore()
  params.FilterDescendantsInstances=ignoreList
  local res=W:Raycast(posA,(posB-posA).Unit*(posB-posA).Magnitude,params)
  if res and res.Instance then return false end
  return true
end
local function tgtMurder()
  local hrp=HRP()
  if not hrp or not alive() then return nil end
  local b,d=nil,math.huge
  for _,p in ipairs(P:GetPlayers()) do
    if p~=LP and isMurder(p) and p.Character then
      local h=p.Character:FindFirstChild("Head")
      if h and h.Parent then
        local q=(h.Position-hrp.Position).Magnitude
        if q<d then
          if canSee(hrp.Position,h.Position) then
            d,b=q,h
          end
        end
      end
    end
  end
  return b
end
-- SILENT AIM
R.Heartbeat:Connect(function()
  if st.sa and alive() then
    local t=tgtMurder()
    local hrp=HRP()
    if t and hrp and C then
      C.CFrame=C.CFrame:Lerp(CFrame.new(hrp.Position,hrp.Position+(t.Position-hrp.Position).Unit),0.6)
    end
  elseif st.sa and not alive() then st.sa=false end
end)
-- AUTO SHOOT
local lastShot=0
R.Heartbeat:Connect(function()
  if st.at and alive() then
    local hrp=HRP()
    local gun=findGun()
    if gun and hrp and gun.Parent==LP.Character then
      local t=tgtMurder()
      if t and (t.Position-hrp.Position).Magnitude<=120 and (os.clock()-lastShot)>=0.12 then
        lastShot=os.clock()
        VIM:SendMouseButtonEvent(0,0,0,true,game,0)
        VIM:SendMouseButtonEvent(0,0,0,false,game,0)
      end
    end
  end
end)
-- KILL AURA
R.Heartbeat:Connect(function()
  if st.kill and alive() then
    local hrp=HRP()
    if hrp and(has(LP,"knife")or has(LP,"gun"))then
      local t=tgtMurder()
      if t and (t.Position-hrp.Position).Magnitude<=12 then
        local cs=C.CFrame
        C.CFrame=CFrame.new(hrp.Position,hrp.Position+(t.Position-hrp.Position).Unit)
        VIM:SendMouseButtonEvent(0,0,0,true,game,0)
        VIM:SendMouseButtonEvent(0,0,0,false,game,0)
        C.CFrame=cs
      end
    end
  end
end)
-- ANTI AFK
local afkT=0
R.Heartbeat:Connect(function()
  if st.afk and os.clock()-afkT>=60 then
    afkT=os.clock()
    local h=HUM()if h then h:ChangeState(Enum.HumanoidStateType.GettingUp)end
  end
end)
-- AUTO RESPAWN
R.Heartbeat:Connect(function()
  if st.ar and not alive() then
    for _,v in ipairs(LP.PlayerGui:GetDescendants())do
      if v:IsA("TextButton")and string.lower(v.Text):find("respawn")then v:Click()end
    end
  end
end)
-- AUTO GUN
R.Heartbeat:Connect(function()
  local h=HUM()local gun=findGun()
  if st.ag and h and gun and gun.Parent==LP.Backpack then h:EquipTool(gun)end
end)
-- TELEPORT
R.Heartbeat:Connect(function()
  if st.tp then
    st.tp=false
    local hrp=HRP()local t=tgtA()
    if hrp and t then
      hrp.CFrame=t.CFrame*CFrame.new(0,0,3)
      N("SzDunamis","Teleportado")
    end
  end
end)
-- COIN FARM
R.Heartbeat:Connect(function()
  if st.cf and alive() then
    local hrp=HRP()
    if hrp then
      local c,pick=nil,math.huge
      for _,o in ipairs(W:GetDescendants())do
        if o:IsA("BasePart")and string.lower(o.Name):find("coin")then
          local q=(o.Position-hrp.Position).Magnitude
          if q<pick then pick,c=q,o end
        end
      end
      if c and pick<60 then hrp.CFrame=CFrame.new(c.Position+Vector3.new(0,3,0),hrp.Position)end
    end
  end
end)

local G=Instance.new("ScreenGui",LP.PlayerGui)G.Name="SzDunamis"G.ResetOnSpawn=false
local PG=Instance.new("Frame",G)PG.Size=UDim2.fromOffset(360,540)PG.AnchorPoint=Vector2.new(.5,.5)PG.Position=UDim2.new(.5,.5,.5,.5)PG.BackgroundColor3=Color3.fromRGB(16,16,24)PG.BackgroundTransparency=.08 PG.Visible=false PG.ZIndex=1
Instance.new("UICorner",PG).CornerRadius=UDim.new(0,14)
local Pn=Instance.new("Frame",PG)Pn.Size=UDim2.new(1,0,1,0)Pn.BackgroundTransparency=1 Pn.ZIndex=2
local TB=Instance.new("TextButton",Pn)TB.Size=UDim2.new(1,0,0,40)TB.BackgroundColor3=Color3.fromRGB(20,20,30)TB.Text="  SzDunamis  MM2"TB.Font=Enum.Font.GothamBold TB.TextScaled=true TB.TextColor3=WHT TB.TextXAlignment=Enum.TextXAlignment.Left TB.ZIndex=3
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,14)
local NAV=Instance.new("Frame",Pn)NAV.Size=UDim2.new(1,0,0,44)NAV.Position=UDim2.new(0,0,0,44)NAV.BackgroundTransparency=1 NAV.ZIndex=3
local tabs={"Mov","Vis","Aim","Farm","Util"}
local Pgs={}
for i=1,5 do
  local pg=Instance.new("ScrollingFrame",Pn)pg.Size=UDim2.new(1,0,1,-96)pg.Position=UDim2.new(0,0,0,90)pg.BackgroundTransparency=1 pg.ScrollBarThickness=4 pg.CanvasSize=UDim2.new(0,0,0,0)pg.Visible=false pg.ZIndex=2
  Pgs[i]=pg
end
local function Show(n)for i,pg in ipairs(Pgs)do pg.Visible=(i==n)end end
for i=1,5 do
  local b=Instance.new("TextButton",NAV)
  b.Size=UDim2.new(.2,0,1,0)b.Position=UDim2.new((i-1)*.2,0,0,0)b.BackgroundTransparency=1 b.Text=tabs[i] b.Font=Enum.Font.GothamBold b.TextScaled=true b.TextColor3=(i==1)and PUR or Color3.fromRGB(150,150,170)b.ZIndex=4
  b.MouseButton1Click:Connect(function()
    Show(i)
    for j,bb in ipairs(NAV:GetChildren())do if bb:IsA("TextButton")then bb.TextColor3=(j==i)and PUR or Color3.fromRGB(150,150,170)end end
  end)
end
local function Mk(pg,label,state,fn)
  local i=#pg:GetChildren()+1
  local row=Instance.new("Frame",pg)row.Size=UDim2.new(1,0,0,96)row.Position=UDim2.new(0,0,0,6+(i-1)*102)row.BackgroundColor3=ROW Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
  local lb=Instance.new("TextLabel",row)lb.Size=UDim2.new(.52,0,1,0)lb.Position=UDim2.new(.06,0,0,0)lb.BackgroundTransparency=1 lb.Text=label lb.Font=Enum.Font.GothamBold lb.TextScaled=true lb.TextXAlignment=Enum.TextXAlignment.Left lb.TextColor3=Color3.fromRGB(235,235,245)lb.ZIndex=2
  local gl=Instance.new("Frame",row)gl.Size=UDim2.fromOffset(86,46)gl.AnchorPoint=Vector2.new(1,.5)gl.Position=UDim2.new(.95,0,.5,0)gl.BackgroundColor3=PUR gl.BackgroundTransparency=.85 gl.ZIndex=1 gl.Visible=false Instance.new("UICorner",gl).CornerRadius=UDim.new(1,0)
  local sw=Instance.new("TextButton",row)sw.Size=UDim2.fromOffset(74,34)sw.AnchorPoint=Vector2.new(1,.5)sw.Position=UDim2.new(.95,0,.5,0)sw.BackgroundColor3=Color3.fromRGB(24,24,32)sw.Text=""sw.ZIndex=2 Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)
  local ss=Instance.new("UIStroke",sw)ss.Thickness=1.5 ss.Color=Color3.fromRGB(60,60,80)
  local kb=Instance.new("TextButton",sw)kb.Size=UDim2.fromOffset(28,28)kb.AnchorPoint=Vector2.new(0,.5)kb.Position=UDim2.new(0,3,.5,0)kb.BackgroundColor3=Color3.fromRGB(230,230,240)kb.Text=""kb.ZIndex=3 Instance.new("UICorner",kb).CornerRadius=UDim.new(1,0)
  local on=Instance.new("TextLabel",sw)on.Size=UDim2.new(.5,0,1,0)on.BackgroundTransparency=1 on.Text="ON"on.Font=Enum.Font.GothamBold on.TextScaled=true on.TextColor3=WHT on.Visible=false on.ZIndex=3
  local off=Instance.new("TextLabel",sw)off.Size=UDim2.new(.5,0,1,0)off.Position=UDim2.new(.5,0,0,0)off.BackgroundTransparency=1 off.Text="OFF"off.Font=Enum.Font.GothamBold off.TextScaled=true off.TextColor3=Color3.fromRGB(120,120,145)off.ZIndex=3
  local function set(v)
    st[state]=v
    T:Create(kb,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=v and UDim2.new(0,43,.5,0)or UDim2.new(0,3,.5,0)}):Play()
    T:Create(sw,TweenInfo.new(.22),{BackgroundColor3=v and PUR or Color3.fromRGB(24,24,32)}):Play()
    T:Create(ss,TweenInfo.new(.22),{Color=v and PUR or Color3.fromRGB(60,60,80)}):Play()
    on.Visible=v off.Visible=not v gl.Visible=v
    if v then T:Create(gl,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=.5}):Play()end
    if fn then fn(state,v)end
  end
  sw.MouseButton1Click:Connect(function()set(not st[state])end)
end
local function MkSlider(pg,label,state,min,max,val,step)
  local i=#pg:GetChildren()+1
  local row=Instance.new("Frame",pg)row.Size=UDim2.new(1,0,0,96)row.Position=UDim2.new(0,0,0,6+(i-1)*102)row.BackgroundColor3=ROW Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
  local lb=Instance.new("TextLabel",row)lb.Size=UDim2.new(.52,0,1,0)lb.Position=UDim2.new(.06,0,0,0)lb.BackgroundTransparency=1 lb.Text=label lb.Font=Enum.Font.GothamBold lb.TextScaled=true lb.TextXAlignment=Enum.TextXAlignment.Left lb.TextColor3=Color3.fromRGB(235,235,245)lb.ZIndex=2
  local bar=Instance.new("Frame",row)bar.Size=UDim2.new(.24,0,0,10)bar.AnchorPoint=Vector2.new(1,.5)bar.Position=UDim2.new(.88,0,.5,0)bar.BackgroundColor3=Color3.fromRGB(40,40,52)bar.ZIndex=2 Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
  local fill=Instance.new("Frame",bar)fill.Size=UDim2.new(.5,0,1,0)fill.BackgroundColor3=PUR fill.ZIndex=3 Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
  local valLb=Instance.new("TextLabel",row)valLb.Size=UDim2.new(.08,0,1,0)valLb.AnchorPoint=Vector2.new(1,.5)valLb.Position=UDim2.new(.84,0,.5,0)valLb.BackgroundTransparency=1 valLb.Text=tostring(val)valLb.Font=Enum.Font.GothamBold valLb.TextScaled=true valLb.TextColor3=PUR valLb.ZIndex=2
  local function set(v)
    v=math.clamp(math.round(v/step)*step,min,max)
    st[state]=v valLb.Text=tostring(v)fill.Size=UDim2.new((v-min)/(max-min),0,1,0)
  end
  set(val)
  local drag=false
  bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true local rel=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X set(min+(max-min)*rel)end end)
  U.InputChanged:Connect(function(i)if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local rel=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X set(min+(max-min)*rel)end end)
  U.InputEnded:Connect(function(i)if drag and(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)then drag=false end end)
end
-- Mov
MkSlider(Pgs[1],"Speed","sp",0,250,32,1)
MkSlider(Pgs[1],"Jump Force","jf",0,250,50,1)
Mk(Pgs[1],"Fly","fl")
Mk(Pgs[1],"Noclip","nc")
Mk(Pgs[1],"Infinite Jump","ij")
-- Vis
Mk(Pgs[2],"ESP Roles","espR",function(_,v)if v then refresh()else clearEsp()end end)
Mk(Pgs[2],"ESP Gun","espG",function(_,v)espGun(v)end)
Mk(Pgs[2],"Xray","xr",function(_,v)xrSet(v)end)
Mk(Pgs[2],"Tracers","tr")
-- Aim
Mk(Pgs[3],"Silent Aim","sa")
Mk(Pgs[3],"Auto Shoot","at")
Mk(Pgs[3],"Kill Aura","kill")
-- Farm
Mk(Pgs[4],"Coin Farm","cf")
Mk(Pgs[4],"Auto Gun","ag")
Mk(Pgs[4],"Anti AFK","afk")
Mk(Pgs[4],"Auto Respawn","ar")
-- Util
Mk(Pgs[5],"Teleport (mais proximo)","tp")
Mk(Pgs[5],"Fullbright","fb",function(_,v)fbSet(v)end)
Mk(Pgs[5],"Anti-Lag","alg",function(_,v)if v then algOn()end end)
for _,pg in ipairs(Pgs)do pg.CanvasSize=UDim2.new(0,0,0,#pg:GetChildren()*102+12)end
Show(1)
-- Botao sz no CANTO DIREITO
local Orb=Instance.new("TextButton",G)
Orb.Size=UDim2.fromOffset(36,36)Orb.AnchorPoint=Vector2.new(.5,.5)Orb.Position=UDim2.new(1,-36,1,-46)
Orb.BackgroundColor3=Color3.new(0,0,0)Orb.Text="sz"Orb.Font=Enum.Font.Michroma Orb.TextScaled=true Orb.TextColor3=WHT Orb.Visible=true Orb.ZIndex=5
Instance.new("UICorner",Orb).CornerRadius=UDim.new(1,0)
local OS=Instance.new("UIStroke",Orb)OS.Thickness=2 OS.Color=PUR
local OG=Instance.new("Frame",G)
OG.Size=UDim2.fromOffset(46,46)OG.AnchorPoint=Vector2.new(.5,.5)OG.Position=Orb.Position
OG.BackgroundColor3=PUR OG.BackgroundTransparency=.7 OG.ZIndex=4 OG.Visible=true
Instance.new("UICorner",OG).CornerRadius=UDim.new(1,0)
-- Drag da GUI pela barra de titulo
local dpg,dpt=false,nil
TB.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dpg=true dpt=i.Position end end)
U.InputChanged:Connect(function(i)if dpg and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-dpt Pn.Position=UDim2.new(Pn.Position.X.Scale,Pn.Position.X.Offset+d.X,Pn.Position.Y.Scale,Pn.Position.Y.Offset+d.Y)PG.Position=Pn.Position dpt=i.Position end end)
U.InputEnded:Connect(function(i)if dpg and(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)then dpg=false end end)
-- Drag do orb
local drg,stPt,isDrag=false,nil,false
Orb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true stPt=i.Position isDrag=false end end)
U.InputChanged:Connect(function(i)if drg and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement)then if(i.Position-stPt).Magnitude>12 then isDrag=true end if isDrag then local p=UDim2.fromOffset(i.Position.X,i.Position.Y)Orb.Position=p OG.Position=p end end end)
U.InputEnded:Connect(function(i)if drg and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1)then drg=false if not isDrag and Pn then Pn.Visible=not Pn.Visible PG.Visible=not PG.Visible end end end)
