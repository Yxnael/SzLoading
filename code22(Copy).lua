-- SzDunamis MM2 - Multi-Executor (Delta, Synapse, Fluxus, Krnl, Codex, etc)
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
  return scan(LP.Character)or scan(LP:FindFirstChild("Backpack"))
end
-- FE
local G=Instance.new("ScreenGui")
G.Name="SzDunamis"
G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
G.ResetOnSpawn=false
G.Parent=LP:WaitForChild("PlayerGui")
-- Loading (com fallback via pcall pra Delta)
local loadSuc=false
local loadScr=Instance.new("Frame",G)
loadScr.Size=UDim2.new(1,0,1,0)
loadScr.BackgroundColor3=Color3.new(0,0,0)
loadScr.ZIndex=100
local loadLab=Instance.new("TextLabel",loadScr)
loadLab.Size=UDim2.new(0,200,0,40)
loadLab.Position=UDim2.new(.5,-100,.5,-20)
loadLab.BackgroundTransparency=1
loadLab.Text="SzDunamis"
loadLab.Font=Enum.Font.GothamBold  -- [FIX] GothamBold ao inves de Michroma
loadLab.TextScaled=true
loadLab.TextColor3=PUR
loadLab.ZIndex=101
local loadSub=Instance.new("TextLabel",loadScr)
loadSub.Size=UDim2.new(0,160,0,20)
loadSub.Position=UDim2.new(.5,-80,.5,20)
loadSub.BackgroundTransparency=1
loadSub.Text="Carregando..."
loadSub.Font=Enum.Font.GothamBold
loadSub.TextScaled=true
loadSub.TextColor3=Color3.fromRGB(180,180,180)
loadSub.ZIndex=101
-- [FIX] Fallback: se tween falhar (Delta), pula direto, sem travar
local loadOk=pcall(function()
  T:Create(loadLab,TweenInfo.new(.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextTransparency=1}):Play()
  T:Create(loadSub,TweenInfo.new(.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TextTransparency=1}):Play()
  T:Create(loadScr,TweenInfo.new(.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=1}):Play()
end)
if not loadOk then
  -- [FIX] Delta: sem Tween, pula direto
  loadScr.Visible=false
  loadScr:Destroy()
else
  task.wait(1.2)
  loadScr.Visible=false
  loadScr:Destroy()
end
-- Pn (main frame)
local Pn=Instance.new("Frame",G)
Pn.Size=UDim2.new(0,280,0,380)
Pn.Position=UDim2.new(.5,-140,.5,-190)
Pn.BackgroundColor3=ROW
Pn.BackgroundTransparency=0.08  -- [FIX] 0.08 pra nao ficar bloco preto solido
Pn.ClipsDescendants=true
Pn.ZIndex=1
Pn.Visible=true
Instance.new("UICorner",Pn).CornerRadius=UDim.new(0,12)
local PB=Instance.new("UIStroke",Pn)
PB.Thickness=2
PB.Color=PUR
Pn.BorderSizePixel=1  -- [FIX] fallback caso UIStroke nao renderize no Delta
Pn.BorderColor3=PUR
-- TB (title bar)
local TB=Instance.new("Frame",Pn)
TB.Size=UDim2.new(1,0,0,38)
TB.BackgroundColor3=PUR
TB.ZIndex=2
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,8)
local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,0,1,0)
TL.BackgroundTransparency=1
TL.Text="SzDunamis v2"
TL.Font=Enum.Font.GothamBold
TL.TextScaled=true
TL.TextColor3=WHT
TL.ZIndex=3
local closeBtn=Instance.new("TextButton",TB)
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.Position=UDim2.new(1,-30,.5,-12)
closeBtn.BackgroundColor3=Color3.fromRGB(200,40,40)
closeBtn.Text="X"
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextScaled=true
closeBtn.TextColor3=WHT
closeBtn.ZIndex=5
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function()Pn.Visible=false PG.Visible=false end)
-- PG (container)
local PG=Instance.new("Frame",Pn)
PG.Size=UDim2.new(1,0,1,-38)
PG.Position=UDim2.new(0,0,0,38)
PG.BackgroundColor3=ROW
PG.BackgroundTransparency=0.08
PG.ZIndex=2
-- Tabs
local TbC=Instance.new("Frame",PG)
TbC.Size=UDim2.new(1,0,0,32)
TbC.BackgroundColor3=Color3.fromRGB(20,20,30)
TbC.ZIndex=3
local tabs={"Mov","Vis","Aim","Farm","Util"}
local Tbs={}
local Pgs={}
local function Show(i)
  for idx=1,#Pgs do
    Pgs[idx].Visible=(idx==i)
    Tbs[idx].BackgroundColor3=(idx==i)and PUR or Color3.fromRGB(40,40,52)
  end
end
for idx,tab in ipairs(tabs)do
  local btn=Instance.new("TextButton",TbC)
  btn.Size=UDim2.new(1/#tabs,0,1,0)
  btn.Position=UDim2.new((idx-1)/#tabs,0,0,0)
  btn.BackgroundColor3=Color3.fromRGB(40,40,52)
  btn.Text=tab
  btn.Font=Enum.Font.GothamBold
  btn.TextScaled=true
  btn.TextColor3=WHT
  btn.ZIndex=4
  btn.BorderSizePixel=0
  Tbs[idx]=btn
  local sc=Instance.new("ScrollingFrame",PG)
  sc.Size=UDim2.new(1,0,1,-32)
  sc.Position=UDim2.new(0,0,0,32)
  sc.BackgroundTransparency=1
  sc.ScrollBarThickness=4
  sc.ScrollBarImageColor3=PUR
  sc.ZIndex=4
  sc.CanvasSize=UDim2.new(0,0,0,0)
  sc.Visible=false
  Pgs[idx]=sc
  btn.MouseButton1Click:Connect(function()Show(idx)end)
end
Show(1)
-- [FIX] Toggle com TextButton ao inves de ImageButton (Delta nao renderiza ImageButton direito)
local function Mk(par,label,state,cb)
  local row=Instance.new("Frame",par)
  row.Size=UDim2.new(1,0,0,30)
  row.Position=UDim2.new(0,0,0,(#par:GetChildren()-1)*36)
  row.BackgroundTransparency=1
  row.ZIndex=6
  local lb=Instance.new("TextLabel",row)
  lb.Size=UDim2.new(.65,0,1,0)
  lb.BackgroundTransparency=1
  lb.Text=label
  lb.Font=Enum.Font.GothamBold
  lb.TextScaled=true
  lb.TextXAlignment=Enum.TextXAlignment.Left
  lb.TextColor3=Color3.fromRGB(235,235,245)
  lb.ZIndex=7
  -- [FIX] TextButton ao inves de ImageButton
  local tog=Instance.new("TextButton",row)
  tog.Size=UDim2.new(0,50,0,24)
  tog.AnchorPoint=Vector2.new(1,.5)
  tog.Position=UDim2.new(.93,0,.5,0)
  tog.BackgroundColor3=Color3.fromRGB(40,40,52)
  tog.Text=st[state] and "ON" or "OFF"
  tog.Font=Enum.Font.GothamBold
  tog.TextScaled=true
  tog.TextColor3=st[state] and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
  tog.ZIndex=7
  Instance.new("UICorner",tog).CornerRadius=UDim.new(0,6)
  tog.MouseButton1Click:Connect(function()
    st[state]=not st[state]
    tog.Text=st[state] and "ON" or "OFF"
    tog.TextColor3=st[state] and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)
    tog.BackgroundColor3=st[state] and Color3.fromRGB(55,20,80) or Color3.fromRGB(40,40,52)
    if cb then cb(state,st[state])end
  end)
end
-- MkSlider (mantido igual, funciona em todos)
local function MkSlider(par,label,state,min,max,val,step)
  local row=Instance.new("Frame",par)
  row.Size=UDim2.new(1,0,0,30)
  row.Position=UDim2.new(0,0,0,(#par:GetChildren()-1)*36)
  row.BackgroundTransparency=1
  row.ZIndex=6
  local lb=Instance.new("TextLabel",row)
  lb.Size=UDim2.new(.55,0,1,0)
  lb.Position=UDim2.new(.06,0,0,0)
  lb.BackgroundTransparency=1
  lb.Text=label
  lb.Font=Enum.Font.GothamBold
  lb.TextScaled=true
  lb.TextXAlignment=Enum.TextXAlignment.Left
  lb.TextColor3=Color3.fromRGB(235,235,245)
  lb.ZIndex=7
  local bar=Instance.new("Frame",row)
  bar.Size=UDim2.new(.24,0,0,10)
  bar.AnchorPoint=Vector2.new(1,.5)
  bar.Position=UDim2.new(.88,0,.5,0)
  bar.BackgroundColor3=Color3.fromRGB(40,40,52)
  bar.ZIndex=7
  Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
  local fill=Instance.new("Frame",bar)
  fill.Size=UDim2.new(.5,0,1,0)
  fill.BackgroundColor3=PUR
  fill.ZIndex=8
  Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
  local valLb=Instance.new("TextLabel",row)
  valLb.Size=UDim2.new(.08,0,1,0)
  valLb.AnchorPoint=Vector2.new(1,.5)
  valLb.Position=UDim2.new(.84,0,.5,0)
  valLb.BackgroundTransparency=1
  valLb.Text=tostring(val)
  valLb.Font=Enum.Font.GothamBold
  valLb.TextScaled=true
  valLb.TextColor3=PUR
  valLb.ZIndex=7
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
for _,pg in ipairs(Pgs)do pg.CanvasSize=UDim2.new(0,0,0,#pg:GetChildren()*36+12)end
-- Orb (botao sz)
local Orb=Instance.new("TextButton",G)
Orb.Size=UDim2.fromOffset(36,36)
Orb.AnchorPoint=Vector2.new(.5,.5)
Orb.Position=UDim2.new(1,-36,1,-46)
Orb.BackgroundColor3=Color3.new(0,0,0)
Orb.Text="sz"
Orb.Font=Enum.Font.GothamBold  -- [FIX] GothamBold, nao Michroma
Orb.TextScaled=true
Orb.TextColor3=WHT
Orb.Visible=true
Orb.ZIndex=10
Instance.new("UICorner",Orb).CornerRadius=UDim.new(1,0)
-- [FIX] Remove UIStroke do Orb (Delta falha), usa Border
Orb.BorderSizePixel=2
Orb.BorderColor3=PUR
local OG=Instance.new("Frame",G)
OG.Size=UDim2.fromOffset(46,46)
OG.AnchorPoint=Vector2.new(.5,.5)
OG.Position=Orb.Position
OG.BackgroundColor3=PUR
OG.BackgroundTransparency=.7
OG.ZIndex=9
OG.Visible=true
Instance.new("UICorner",OG).CornerRadius=UDim.new(1,0)
-- Drag da GUI
local dpg,dpt=false,nil
TB.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dpg=true dpt=i.Position end end)
U.InputChanged:Connect(function(i)if dpg and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-dpt Pn.Position=UDim2.new(Pn.Position.X.Scale,Pn.Position.X.Offset+d.X,Pn.Position.Y.Scale,Pn.Position.Y.Offset+d.Y)PG.Position=Pn.Position dpt=i.Position end end)
U.InputEnded:Connect(function(i)if dpg and(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)then dpg=false end end)
-- Drag do orb
local drg,stPt,isDrag=false,nil,false
Orb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true stPt=i.Position isDrag=false end end)
U.InputChanged:Connect(function(i)if drg and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement)then if(i.Position-stPt).Magnitude>12 then isDrag=true end if isDrag then local p=UDim2.fromOffset(i.Position.X,i.Position.Y)Orb.Position=p OG.Position=p end end end)
U.InputEnded:Connect(function(i)if drg and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1)then drg=false if not isDrag and Pn then Pn.Visible=not Pn.Visible PG.Visible=not PG.Visible end end end)
