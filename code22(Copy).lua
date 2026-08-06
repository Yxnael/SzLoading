local P=game:GetService("Players")local U=game:GetService("UserInputService")local T=game:GetService("TweenService")
local R=game:GetService("RunService")local S=game:GetService("StarterGui")local W=workspace local C=W.CurrentCamera
local RS=game:GetService("ReplicatedStorage")local LP=P.LocalPlayer
local VIM=game:GetService("VirtualInputManager")
if getgenv().SZDUN then return end getgenv().SZDUN=true
if not((game.PlaceId==142823291)or(game.GameId==66654135))then S:SetCore("SendNotification",{Title="SzDunamis",Text="Jogo nao suportado",Duration=3})return end
local IMG="rbxassetid://112169216"
local st={sp=false,fl=false,nc=false,espR=false,espG=false,xr=false,sa=false,at=false,kill=false,cf=false,ag=false,afk=false,
          ij=false,tr=false,ar=false,fb=false,alg=false,tp=false,speed=32,jf=50}
local PUR=Color3.fromRGB(150,20,255)local ROW=Color3.fromRGB(26,26,36)local WHT=Color3.new(1,1,1)
local function N(t,x)S:SetCore("SendNotification",{Title=t,Text=x,Duration=3})end
local function HRP()local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart")end
local function alive()return LP:GetAttribute("Alive")~=false end
local function hasTool(par,n)if not par then return false end for _,v in ipairs(par:GetChildren())do if v:IsA("Tool")and string.lower(v.Name):find(string.lower(n))then return true end end return false end
local function has(p,n)return hasTool(p.Character,n)or hasTool(p:FindFirstChild("Backpack"),n)end
local function findGun()local c=LP.Character local function scan(par)if par then for _,tl in ipairs(par:GetChildren())do if tl:IsA("Tool")and string.lower(tl.Name):find("gun")then return tl end end end end return scan(c)or scan(LP.Backpack)end
local function tgt()local hrp=HRP()if not hrp then return nil end local b,d=nil,math.huge for _,p in ipairs(P:GetPlayers())do if p~=LP then local c=p.Character local t=c and(c:FindFirstChild("Head")or c:FindFirstChild("UpperTorso"))if t and t.Parent then local q=(t.Position-hrp.Position).Magnitude if q<d then d,b=q,t end end end end return b end
local function tgtPart()local hrp=HRP()if not hrp then return nil end local b,d=nil,math.huge for _,p in ipairs(P:GetPlayers())do if p~=LP then local c=p.Character local t=c and c:FindFirstChild("HumanoidRootPart")or(c and c:FindFirstChild("Head"))if t and t.Parent then local q=(t.Position-hrp.Position).Magnitude if q<d then d,b=q,t end end end end return b end
local function tgtA()local hrp=HRP()if not hrp then return nil end local b,d=nil,math.huge for _,p in ipairs(P:GetPlayers())do if p~=LP and has(p,"Knife")then local c=p.Character local t=c and(c:FindFirstChild("Head")or c:FindFirstChild("UpperTorso"))if t and t.Parent then local q=(t.Position-hrp.Position).Magnitude if q<d then d,b=q,t end end end end return b end
local function pred(t)return t.CFrame+(t.Velocity*.165)end

-- ============ SILENT AIM REFEITO (estilo Averiias) ============
local function getClosestSA()
    if not st.sa then return nil end
    local hrp=HRP() if not hrp then return nil end
    local b,d=nil,math.huge
    for _,p in ipairs(P:GetPlayers())do
        if p~=LP then
            local c=p.Character
            local t=c and c:FindFirstChild("HumanoidRootPart")
            if t and t.Parent then
                local q=(t.Position-hrp.Position).Magnitude
                if q<d then d,b=q,t end
            end
        end
    end
    return b
end

-- Hook __namecall: intercepta raycasts do Workspace
local oldNC
oldNC=hookmetamethod(game,"__namecall",newcclosure(function(...)
    local args={...}
    local self=args[1]
    local method=getnamecallmethod()
    
    if st.sa and not checkcaller() and self==workspace then
        local target=getClosestSA()
        if target then
            if method=="FindPartOnRayWithIgnoreList" or method=="FindPartOnRay" or method=="findPartOnRay" then
                local ray=args[2]
                if ray and typeof(ray)=="Ray" then
                    args[2]=Ray.new(ray.Origin,(target.Position-ray.Origin).Unit*1000)
                    return oldNC(unpack(args))
                end
            elseif method=="Raycast" then
                local origin=args[2]
                if origin and typeof(origin)=="Vector3" then
                    args[3]=(target.Position-origin).Unit*1000
                    return oldNC(unpack(args))
                end
            end
        end
    end
    return oldNC(unpack(args))
end))

-- Hook __index: Mouse.Hit/Target
local M=LP:GetMouse()
local oldIdx
oldIdx=hookmetamethod(game,"__index",newcclosure(function(s,k)
    if st.sa and not checkcaller() and rawequal(s,M) then
        local target=getClosestSA()
        if target then
            if k=="Target"or k=="target"then return target end
            if k=="Hit"or k=="hit"then return target.CFrame+target.Velocity*.165 end
            if k=="UnitRay"or k=="Origin"then
                local o=C.CFrame.Position
                return Ray.new(o,(target.Position-o).Unit)
            end
        end
    end
    return oldIdx(s,k)
end))

local SAok=true
local NCok=true

local keys={}
local FLYKEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,[Enum.KeyCode.Space]=true,[Enum.KeyCode.LeftShift]=true}
U.InputBegan:Connect(function(i)if FLYKEYS[i.KeyCode]then keys[i.KeyCode]=true end end)
U.InputEnded:Connect(function(i)if FLYKEYS[i.KeyCode]then keys[i.KeyCode]=nil end end)
local jumpKey=false
U.InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.Space then jumpKey=true end end)
U.InputEnded:Connect(function(i)if i.KeyCode==Enum.KeyCode.Space then jumpKey=false end end)
local tags={}
local function clear()for _,g in ipairs(tags)do pcall(function()g:Destroy()end)end tags={}end
local function tag(p,txt,col,nm,dist)local h=p.Character and p.Character:FindFirstChild("Head")if not h then return end local b=Instance.new("BillboardGui",h)b.Name="SZESP"b.Size=UDim2.new(0,130,0,28)b.AlwaysOnTop=true b.MaxDistance=700 b.StudsOffset=Vector3.new(0,3,0)local l=Instance.new("TextLabel",b)l.Size=UDim2.new(1,0,1,0)l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.TextScaled=true l.Text=txt..(nm and" | "..p.Name or"")..(dist and(" | "..dist.."m")or"")l.TextColor3=col l.TextStrokeTransparency=.2 tags[#tags+1]=b end
local function refresh()clear()local hrp=HRP()for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Head")local dist=hrp and h and math.floor((h.Position-hrp.Position).Magnitude+.5)or nil if has(p,"Knife")then tag(p,"ASSASSINO",Color3.fromRGB(255,70,70),true,dist)elseif has(p,"Gun")then tag(p,"XERIFE",Color3.fromRGB(70,160,255),true,dist)else tag(p,p.Name,Color3.fromRGB(0,220,120),false,dist)end end end end
local gunTag
local function espGun(v)if gunTag then pcall(function()gunTag:Destroy()end)gunTag=nil end if not v then return end local g=W:FindFirstChild("GunDrop",true)if not g then return end local part=g:IsA("BasePart")and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")if part then local b=Instance.new("BillboardGui",part)b.Name="SZGUN"b.Size=UDim2.new(0,100,0,24)b.AlwaysOnTop=true b.StudsOffset=Vector3.new(0,1,0)local l=Instance.new("TextLabel",b)l.Size=UDim2.new(1,0,1,0)l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.TextScaled=true l.Text="ARMA"l.TextColor3=Color3.fromRGB(255,200,60)l.TextStrokeTransparency=.2 gunTag=b end end
local tracers={}
local function clearTracers()for _,t in ipairs(tracers)do pcall(function()t:Remove()end)end tracers={}end
local function drawTracers()if not st.tr then clearTracers()return end if #tracers==0 then for i=1,#P:GetPlayers()-1 do local d=Drawing.new("Line")d.Thickness=1.5 d.Color=PUR d.Visible=true tracers[i]=d end end local i=0 for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Head")if h then i=i+1 local scr,onn=C:WorldToViewportPoint(h.Position)local d=tracers[i]if d then d.Visible=onn d.From=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y)d.To=Vector2.new(scr.X,scr.Y)end end end end for j=i+1,#tracers do tracers[j].Visible=false end end
task.spawn(function()local t1,t2,t3,t4=0,0,0,0 local lastAt=0 local lastEquip=0 while true do local dt=task.wait()local c=LP.Character local hrp=HRP()local hum=c and c:FindFirstChildOfClass("Humanoid")
    -- FIX 4: Speed agora pega direto de st.speed sem st.sp
    if hum then if not st.fl then hum.WalkSpeed=st.speed or 32 end if st.jf then hum.JumpPower=st.jf end end
if st.ij and hum then if jumpKey and not hum.Jumping then pcall(function()hum:ChangeState(Enum.HumanoidStateType.Jumping)end)end end
    -- FIX 3: Fly com CFrame movement (nao trava)
    if st.fl and hrp then
        local f=(keys[Enum.KeyCode.W] and 1 or 0)-(keys[Enum.KeyCode.S] and 1 or 0)
        local r=(keys[Enum.KeyCode.D] and 1 or 0)-(keys[Enum.KeyCode.A] and 1 or 0)
        local u=(keys[Enum.KeyCode.Space] and 1 or 0)-(keys[Enum.KeyCode.LeftShift] and 1 or 0)
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hum.PlatformStand=true
        end
        hrp.CFrame = hrp.CFrame + (C.CFrame.LookVector*f + C.CFrame.RightVector*r + Vector3.new(0,u,0)) * st.speed * dt
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    elseif hrp then
        local bv=hrp:FindFirstChild("SZBV")
        if bv then bv:Destroy() end
        -- FIX 5: Coin Farm nao deixa PlatformStand ser desligado
        if hum and not st.cf then hum.PlatformStand=false end
    end
local ncOn=(st.nc or st.cf)if ncOn and c then for _,v in ipairs(c:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end t1=t1+dt if t1>.5 then t1=0 if st.nc then for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character then for _,v in ipairs(p.Character:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end end end if st.xr then for _,v in ipairs(W:GetDescendants())do if v:IsA("BasePart")and not(LP.Character and v:IsDescendantOf(LP.Character))then v.LocalTransparencyModifier=.75 end end else for _,v in ipairs(W:GetDescendants())do if v:IsA("BasePart")then v.LocalTransparencyModifier=0 end end end if st.fb then for _,v in ipairs(W:GetDescendants())do if v:IsA("SurfaceLight")or v:IsA("PointLight")then v.Range=1000 v.Brightness=3 end end game.Lighting.Ambient=Color3.new(1,1,1)game.Lighting.Brightness=2 end if st.alg then for _,v in ipairs(W:GetDescendants())do if v:IsA("Decal")or v:IsA("ParticleEmitter")or v:IsA("Fire")or v:IsA("Smoke")then pcall(function()v:Destroy()end)end end end if st.tp then local hd=tgt()if hd and hrp then hrp.CFrame=hd.CFrame*CFrame.new(0,2,0)end end if st.ar and not alive()then local resp=getR("Respawn")or getR("PlayerDied")or getR("Died")if resp then pcall(function()resp:InvokeServer()end)end end end t4=t4+dt if t4>=1 then t4=0 if st.espR then refresh()else clear()end if st.espG and not(gunTag and gunTag.Parent)then espGun(true)end end
    -- FIX 1: Auto Shot usa tgt() e checa t.Parent
    if st.at then
        local g=findGun()
        local t=tgt()
        if g and t and t.Parent and alive() then
            if g.Parent~=c then
                local h=c and c:FindFirstChildOfClass("Humanoid")
                if h then h:EquipTool(g) end
                lastEquip=os.clock()+.15
            end
            if os.clock()>lastEquip and os.clock()-lastAt>.2 then
                local vp=C.ViewportSize
                VIM:SendMouseButtonEvent(vp.X/2,vp.Y/2,0,true,game,1)
                VIM:SendMouseButtonEvent(vp.X/2,vp.Y/2,0,false,game,1)
                lastAt=os.clock()
            end
        end
    end
if st.kill then local k=c and c:FindFirstChild("Knife")local hd=tgt()if hrp and k and hd and hd.Parent then local r=hd.Parent:FindFirstChild("HumanoidRootPart")if r then r.CFrame=hrp.CFrame+hrp.CFrame.LookVector*4 end local hp=k:FindFirstChild("Handle")if hp then for _,v in ipairs(hd.Parent:GetDescendants())do if v:IsA("BasePart")and v:FindFirstChild("TouchInterest")then firetouchinterest(hp,v,0)firetouchinterest(hp,v,1)end end end k:Activate()end end t2=t2+dt if st.ag and t2>.6 then t2=0 local g=W:FindFirstChild("GunDrop",true)local part=g and(g:IsA("BasePart")and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart"))if alive()and part and hrp then hrp.CFrame=part.CFrame*CFrame.new(0,0,2)task.wait(.08)for _,v in ipairs(g:GetDescendants())do if v:IsA("BasePart")and v:FindFirstChild("TouchInterest")then firetouchinterest(hrp,v,0)firetouchinterest(hrp,v,1)end end end end t3=t3+dt if st.afk and t3>30 then t3=0 pcall(function()mousemoverel(0,2)end)end end end)
R.RenderStepped:Connect(function()drawTracers()end)
local CF={farming=false,collected=false,tw=nil,cool=0,parts={}}
local function box()return W:FindFirstChild("CoinContainer",true)end
local function okCoin(cn)return cn and cn:GetAttribute("CoinID")=="Coin"and cn:FindFirstChild("TouchInterest")and cn.Transparency==1 end
local function nearCoin()local hrp=HRP()local b=box()if not(hrp and b)then return nil end local n,d=nil,math.huge for _,cn in ipairs(b:GetChildren())do if okCoin(cn)then local q=(cn.Position-hrp.Position).Magnitude if q<d then d,n=q,cn end end end return n end
local function startFarm()local c=LP.Character if not c then return end local hrp=c:FindFirstChild("HumanoidRootPart")local hum=c:FindFirstChildOfClass("Humanoid")if not(hrp and hum)then return end CF.parts={}for _,v in ipairs(c:GetDescendants())do if v:IsA("BasePart")then CF.parts[v]=v.CanCollide end end for p,cc in pairs(CF.parts)do p.CanCollide=false end hrp.CFrame=(hrp.CFrame-Vector3.new(0,2.5,0))*CFrame.Angles(math.rad(90),0,0)hum.PlatformStand=true hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)CF.farming=true end
local function stopFarm()CF.farming=false if CF.tw then CF.tw:Cancel()CF.tw=nil end local c=LP.Character if c then for p,cc in pairs(CF.parts)do if p and p.Parent then p.CanCollide=cc end end local hrp=c:FindFirstChild("HumanoidRootPart")if hrp then hrp.Velocity=Vector3.zero hrp.RotVelocity=Vector3.zero hrp.CFrame=hrp.CFrame*CFrame.Angles(math.rad(-90),0,0)+Vector3.new(0,2.5,0)end local hum=c:FindFirstChildOfClass("Humanoid")if hum then hum.PlatformStand=false hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)end end CF.parts={}end
local function getR(n)local rm=RS:FindFirstChild("Remotes")local gp=rm and rm:FindFirstChild("Gameplay")return gp and gp:FindFirstChild(n)end
local CC=getR("CoinCollected")if CC then CC.OnClientEvent:Connect(function(tp,a,b)if tp=="Coin"then CF.collected=(tonumber(a)==tonumber(b))end end)end
local RSt=getR("RoundStart")if RSt then RSt.OnClientEvent:Connect(function()CF.collected=false end)end
local RE=getR("RoundEndFade")if RE then RE.OnClientEvent:Connect(function()CF.collected=false if CF.farming then stopFarm()end end)end
R.Heartbeat:Connect(function()local hrp=HRP()if CF.farming and hrp then hrp.Velocity=Vector3.zero hrp.RotVelocity=Vector3.zero local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")if hum then hum.PlatformStand=true end end if not st.cf then if CF.farming then stopFarm()end return end if not(hrp and alive())then if CF.farming then stopFarm()end return end local cn=nearCoin()if cn and not CF.collected and not(CF.cool and os.clock()<CF.cool)then local d=(cn.Position-hrp.Position).Magnitude if d>5 then if not CF.farming then startFarm()end if CF.farming then if CF.tw then CF.tw:Cancel()CF.tw=nil end local tw=T:Create(hrp,TweenInfo.new(math.clamp(d/23,.1,6),Enum.EasingStyle.Linear),{CFrame=CFrame.new(cn.Position-Vector3.new(0,2.5,0))*CFrame.Angles(math.rad(90),0,0)})CF.tw=tw tw:Play()task.delay(math.clamp(d/23,.1,6)+1.2,function()if CF.tw==tw then CF.tw:Cancel()CF.tw=nil CF.cool=os.clock()+1 end end)end else firetouchinterest(hrp,cn,0)firetouchinterest(hrp,cn,1)end elseif CF.farming and(not cn or CF.collected)then stopFarm()end end)
LP.CharacterAdded:Connect(function()task.wait(.5)if CF.farming then stopFarm()end clear()end)

-- ============ GUI ============
local G=Instance.new("ScreenGui")G.Name="SzDunamisUI"G.ResetOnSpawn=false G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
if not pcall(function()G.Parent=game:GetService("CoreGui")end)then G.Parent=LP:WaitForChild("PlayerGui")end
local PW,PH=600,340
local PG=Instance.new("Frame",G)PG.AnchorPoint=Vector2.new(.5,.5)PG.Position=UDim2.new(.5,0,.5,0)PG.Size=UDim2.new(0,PW+8,0,PH+8)PG.BackgroundColor3=PUR PG.BackgroundTransparency=.86 PG.ZIndex=0
Instance.new("UICorner",PG).CornerRadius=UDim.new(0,20)
local Pn=Instance.new("Frame",G)Pn.AnchorPoint=Vector2.new(.5,.5)Pn.Position=UDim2.new(.5,0,.5,0)Pn.Size=UDim2.new(0,PW,0,PH)Pn.BackgroundColor3=Color3.fromRGB(13,13,19)Pn.ZIndex=1
Instance.new("UICorner",Pn).CornerRadius=UDim.new(0,16)
local PS=Instance.new("UIStroke",Pn)PS.Thickness=2 PS.Color=PUR PS.Transparency=.4
local Bg=Instance.new("ImageLabel",Pn)Bg.Size=UDim2.new(1,0,1,0)Bg.BackgroundTransparency=1 Bg.Image=IMG Bg.ScaleType=Enum.ScaleType.Crop Bg.ImageTransparency=.88 Bg.ZIndex=1
local TB=Instance.new("Frame",Pn)TB.Size=UDim2.new(1,0,0,46)TB.BackgroundTransparency=1 TB.ZIndex=3
local Lg=Instance.new("ImageLabel",TB)Lg.Size=UDim2.fromOffset(34,34)Lg.Position=UDim2.new(.02,0,.5,0)Lg.AnchorPoint=Vector2.new(0,.5)Lg.Image=IMG Lg.BackgroundColor3=Color3.fromRGB(8,8,12)Lg.BackgroundTransparency=.25
Instance.new("UICorner",Lg).CornerRadius=UDim.new(1,0)
local Ls=Instance.new("UIStroke",Lg)Ls.Thickness=2 Ls.Color=PUR
local Tt=Instance.new("TextLabel",TB)Tt.Position=UDim2.new(.07,0,.2,0)Tt.Size=UDim2.new(.3,0,.6,0)Tt.BackgroundTransparency=1 Tt.Text="SzDunamis"Tt.Font=Enum.Font.Michroma Tt.TextScaled=true Tt.TextColor3=WHT
local tg=Instance.new("UIGradient",Tt)tg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,PUR),ColorSequenceKeypoint.new(.5,WHT),ColorSequenceKeypoint.new(1,PUR)})tg.Rotation=90
local hint=Instance.new("TextLabel",TB)hint.Size=UDim2.new(.3,0,.6,0)hint.Position=UDim2.new(.68,0,.2,0)hint.BackgroundTransparency=1 hint.Text="Arraste para mover"hint.Font=Enum.Font.GothamBold hint.TextScaled=true hint.TextColor3=Color3.fromRGB(120,120,145)hint.TextXAlignment=Enum.TextXAlignment.Right hint.ZIndex=3
local Tabs={"Mov","Vis","Aim","Farm","Util"}local TBs,Pgs={},{}
local function Show(i)for j,pg in ipairs(Pgs)do pg.Visible=(j==i)end for j,b in ipairs(TBs)do local v=j==i T:Create(b,TweenInfo.new(.2),{BackgroundColor3=v and PUR or ROW}):Play()T:Create(b,TweenInfo.new(.2),{TextColor3=v and WHT or Color3.fromRGB(190,190,210)}):Play()end end
local TBr=Instance.new("Frame",Pn)TBr.Position=UDim2.new(0,12,.14,0)TBr.Size=UDim2.new(0,104,0,.84)TBr.BackgroundTransparency=1 TBr.ZIndex=3
for i,nm in ipairs(Tabs)do local b=Instance.new("TextButton",TBr)b.Size=UDim2.new(1,0,0,52)b.Position=UDim2.new(0,0,0,(i-1)*58)b.BackgroundColor3=ROW b.Text=nm b.Font=Enum.Font.GothamBold b.TextScaled=true b.TextColor3=Color3.fromRGB(190,190,210)b.ZIndex=2 Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)TBs[i]=b b.MouseButton1Click:Connect(function()Show(i)end)end
local Ct=Instance.new("Frame",Pn)Ct.Position=UDim2.new(0,126,0,52)Ct.Size=UDim2.new(0,PW-140,0,PH-60)Ct.BackgroundTransparency=1 Ct.ZIndex=3
for i=1,#Tabs do local pg=Instance.new("ScrollingFrame",Ct)pg.Size=UDim2.new(1,0,1,0)pg.BackgroundTransparency=1 pg.ZIndex=3 pg.ScrollingDirection=Enum.ScrollingDirection.Y pg.ScrollBarThickness=3 pg.ScrollBarImageColor3=PUR pg.CanvasSize=UDim2.new(0,0,0,0)Pgs[i]=pg end
local function Mk(pg,label,state,fn)local i=#pg:GetChildren()+1 local row=Instance.new("Frame",pg)row.Size=UDim2.new(1,0,0,96)row.Position=UDim2.new(0,0,0,6+(i-1)*102)row.BackgroundColor3=ROW Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)local lb=Instance.new("TextLabel",row)lb.Size=UDim2.new(.52,0,1,0)lb.Position=UDim2.new(.06,0,0,0)lb.BackgroundTransparency=1 lb.Text=label lb.Font=Enum.Font.GothamBold lb.TextScaled=true lb.TextXAlignment=Enum.TextXAlignment.Left lb.TextColor3=Color3.fromRGB(235,235,245)lb.ZIndex=2 local gl=Instance.new("Frame",row)gl.Size=UDim2.fromOffset(86,46)gl.AnchorPoint=Vector2.new(1,.5)gl.Position=UDim2.new(.95,0,.5,0)gl.BackgroundColor3=PUR gl.BackgroundTransparency=.85 gl.ZIndex=1 gl.Visible=false Instance.new("UICorner",gl).CornerRadius=UDim.new(1,0)local sw=Instance.new("TextButton",row)sw.Size=UDim2.fromOffset(74,34)sw.AnchorPoint=Vector2.new(1,.5)sw.Position=UDim2.new(.95,0,.5,0)sw.BackgroundColor3=Color3.fromRGB(24,24,32)sw.Text=""sw.ZIndex=2 Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)local ss=Instance.new("UIStroke",sw)ss.Thickness=1.5 ss.Color=Color3.fromRGB(60,60,80)local kb=Instance.new("TextButton",sw)kb.Size=UDim2.fromOffset(28,28)kb.AnchorPoint=Vector2.new(0,.5)kb.Position=UDim2.new(0,3,.5,0)kb.BackgroundColor3=Color3.fromRGB(230,230,240)kb.Text=""kb.ZIndex=3 Instance.new("UICorner",kb).CornerRadius=UDim.new(1,0)local on=Instance.new("TextLabel",sw)on.Size=UDim2.new(.5,0,1,0)on.BackgroundTransparency=1 on.Text="ON"on.Font=Enum.Font.GothamBold on.TextScaled=true on.TextColor3=WHT on.Visible=false on.ZIndex=3 local off=Instance.new("TextLabel",sw)off.Size=UDim2.new(.5,0,1,0)off.Position=UDim2.new(.5,0,0,0)off.BackgroundTransparency=1 off.Text="OFF"off.Font=Enum.Font.GothamBold off.TextScaled=true off.TextColor3=Color3.fromRGB(120,120,145)off.ZIndex=3 local function set(v)st[state]=v T:Create(kb,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=v and UDim2.new(0,43,.5,0)or UDim2.new(0,3,.5,0)}):Play()T:Create(sw,TweenInfo.new(.22),{BackgroundColor3=v and PUR or Color3.fromRGB(24,24,32)}):Play()T:Create(ss,TweenInfo.new(.22),{Color=v and PUR or Color3.fromRGB(60,60,80)}):Play()on.Visible=v off.Visible=not v gl.Visible=v if v then T:Create(gl,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=.5}):Play()end if fn then fn(state,v)end end sw.MouseButton1Click:Connect(function()set(not st[state])end)end
local function MkSlider(pg,label,state,min,max,val,step)local i=#pg:GetChildren()+1 local row=Instance.new("Frame",pg)row.Size=UDim2.new(1,0,0,96)row.Position=UDim2.new(0,0,0,6+(i-1)*102)row.BackgroundColor3=ROW Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)local lb=Instance.new("TextLabel",row)lb.Size=UDim2.new(.6,0,1,0)lb.Position=UDim2.new(.06,0,0,0)lb.BackgroundTransparency=1 lb.Text=label lb.Font=Enum.Font.GothamBold lb.TextScaled=true lb.TextXAlignment=Enum.TextXAlignment.Left lb.TextColor3=Color3.fromRGB(235,235,245)lb.ZIndex=2 local bar=Instance.new("Frame",row)bar.Size=UDim2.new(.24,0,0,10)bar.AnchorPoint=Vector2.new(1,.5)bar.Position=UDim2.new(.88,0,.5,0)bar.BackgroundColor3=Color3.fromRGB(40,40,52)bar.ZIndex=2 Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)local fill=Instance.new("Frame",bar)fill.Size=UDim2.new(.5,0,1,0)fill.BackgroundColor3=PUR fill.ZIndex=3 Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)local valLb=Instance.new("TextLabel",row)valLb.Size=UDim2.new(.08,0,1,0)valLb.AnchorPoint=Vector2.new(1,.5)valLb.Position=UDim2.new(.84,0,.5,0)valLb.BackgroundTransparency=1 valLb.Text=tostring(val)valLb.Font=Enum.Font.GothamBold valLb.TextScaled=true valLb.TextColor3=PUR valLb.ZIndex=2 local set set=function(v)v=math.clamp(math.round(v/step)*step,min,max)st[state]=v valLb.Text=tostring(v)fill.Size=UDim2.new((v-min)/(max-min),0,1,0)end set(val)local drag=false bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true local rel=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X set(min+(max-min)*rel)end end)U.InputChanged:Connect(function(i)if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local rel=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X set(min+(max-min)*rel)end end)U.InputEnded:Connect(function(i)if drag and(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)then drag=false end end)end
-- Mov
MkSlider(Pgs[1],"Speed","speed",0,250,32,1)
MkSlider(Pgs[1],"Jump Force","jf",0,250,50,1)
Mk(Pgs[1],"Fly","fl")Mk(Pgs[1],"Noclip","nc")Mk(Pgs[1],"Infinite Jump","ij")
-- Vis
Mk(Pgs[2],"ESP Roles","espR",function(_,v)if v then refresh()else clear()end end)Mk(Pgs[2],"ESP Gun","espG",function(_,v)espGun(v)end)Mk(Pgs[2],"Xray","xr")Mk(Pgs[2],"Tracers","tr")
-- Aim
Mk(Pgs[3],"Silent Aim","sa")Mk(Pgs[3],"Auto Shoot","at")Mk(Pgs[3],"Kill Aura","kill")
-- Farm
Mk(Pgs[4],"Coin Farm","cf")Mk(Pgs[4],"Auto Gun","ag")Mk(Pgs[4],"Anti AFK","afk")Mk(Pgs[4],"Auto Respawn","ar")
-- Util
Mk(Pgs[5],"Teleport (mais proximo)","tp")Mk(Pgs[5],"Fullbright","fb")Mk(Pgs[5],"Anti-Lag","alg")
for _,pg in ipairs(Pgs)do pg.CanvasSize=UDim2.new(0,0,0,#pg:GetChildren()*102+12)end
Show(1)
local Orb=Instance.new("TextButton",G)Orb.Size=UDim2.fromOffset(36,36)Orb.AnchorPoint=Vector2.new(.5,.5)Orb.Position=UDim2.new(1,-36,1,-46)Orb.BackgroundColor3=Color3.new(0,0,0)Orb.Text="sz"Orb.Font=Enum.Font.Michroma Orb.TextScaled=true Orb.TextColor3=WHT Orb.Visible=true Orb.ZIndex=5
Instance.new("UICorner",Orb).CornerRadius=UDim.new(1,0)
local OS=Instance.new("UIStroke",Orb)OS.Thickness=2 OS.Color=PUR
local OG=Instance.new("Frame",G)OG.Size=UDim2.fromOffset(46,46)OG.AnchorPoint=Vector2.new(.5,.5)OG.Position=Orb.Position OG.BackgroundColor3=PUR OG.BackgroundTransparency=.7 OG.ZIndex=4 OG.Visible=true
Instance.new("UICorner",OG).CornerRadius=UDim.new(1,0)
local dpg,dpt=false,nil
TB.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dpg=true dpt=i.Position end end)
U.InputChanged:Connect(function(i)if dpg and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-dpt Pn.Position=UDim2.new(Pn.Position.X.Scale,Pn.Position.X.Offset+d.X,Pn.Position.Y.Scale,Pn.Position.Y.Offset+d.Y)PG.Position=Pn.Position dpt=i.Position end end)
U.InputEnded:Connect(function(i)if dpg and(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)then dpg=false end end)
local drg,stPt,isDrag=false,nil,false
Orb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true stPt=i.Position isDrag=false end end)
U.InputChanged:Connect(function(i)if drg and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement)then if(i.Position-stPt).Magnitude>12 then isDrag=true end if isDrag then local p=UDim2.fromOffset(i.Position.X,i.Position.Y)Orb.Position=p OG.Position=p end end end)
U.InputEnded:Connect(function(i)if drg and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1)then drg=false if not isDrag and Pn then Pn.Visible=not Pn.Visible PG.Visible=not PG.Visible end end end)
