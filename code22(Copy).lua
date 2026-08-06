local P=game:GetService("Players")local U=game:GetService("UserInputService")local T=game:GetService("TweenService")
local R=game:GetService("RunService")local S=game:GetService("StarterGui")local W=workspace local C=W.CurrentCamera
local RS=game:GetService("ReplicatedStorage")local LP=P.LocalPlayer
local VIM=game:GetService("VirtualInputManager")
if getgenv().SZDUN then return end getgenv().SZDUN=true
if not((game.PlaceId==142823291)or(game.GameId==66654135))then S:SetCore("SendNotification",{Title="SzDunamis",Text="Jogo nao suportado",Duration=3})return end
local IMG="rbxassetid://112169216"
local st={sp=false,fl=false,nc=false,espR=false,espG=false,xr=false,sa=false,at=false,kill=false,cf=false,ag=false,afk=false,
          ij=false,tr=false,ar=false,fb=false,alg=false,tp=false,speed=32,jf=6} -- >>> FIX: jf agora é JumpHeight (studs)
local PUR=Color3.fromRGB(150,20,255)local ROW=Color3.fromRGB(26,26,36)local WHT=Color3.new(1,1,1)
local function N(t,x)S:SetCore("SendNotification",{Title=t,Text=x,Duration=3})end
local function HRP()local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart")end
local function alive()return LP:GetAttribute("Alive")~=false end
local function hasTool(par,n)if not par then return false end for _,v in ipairs(par:GetChildren())do if v:IsA("Tool")and string.lower(v.Name):find(string.lower(n))then return true end end return false end
local function has(p,n)return hasTool(p.Character,n)or hasTool(p:FindFirstChild("Backpack"),n)end
local function findGun()local c=LP.Character local function scan(par)if par then for _,tl in ipairs(par:GetChildren())do if tl:IsA("Tool")and string.lower(tl.Name):find("gun")then return tl end end end end return scan(c)or scan(LP.Backpack)end
local function tgt()local hrp=HRP()if not hrp then return nil end local b,d=nil,math.huge for _,p in ipairs(P:GetPlayers())do if p~=LP then local c=p.Character local t=c and(c:FindFirstChild("Head")or c:FindFirstChild("UpperTorso"))if t and t.Parent then local q=(t.Position-hrp.Position).Magnitude if q<d then d,b=q,t end end end end return b end
local function tgtA()local hrp=HRP()if not hrp then return nil end local b,d=nil,math.huge for _,p in ipairs(P:GetPlayers())do if p~=LP and has(p,"Knife")then local c=p.Character local t=c and(c:FindFirstChild("Head")or c:FindFirstChild("UpperTorso"))if t and t.Parent then local q=(t.Position-hrp.Position).Magnitude if q<d then d,b=q,t end end end end return b end
local function getMurder()for _,p in ipairs(P:GetPlayers())do if p~=LP and has(p,"Knife")then return p end end return nil end
local function getMurderHRP()local m=getMurder()return m and m.Character and m.Character:FindFirstChild("HumanoidRootPart")end

-- ============ SHOOT REMOTE (movido pra cima, o hook do SA precisa dele) ============
local function getShootRemote()
    local g=findGun()
    if not g then return nil end
    local kl=g:FindFirstChild("KnifeLocal")
    if not kl then return nil end
    local cb=kl:FindFirstChild("CreateBeam")
    if not cb then return nil end
    return cb:FindFirstChild("RemoteFunction")
end

-- ============ SILENT AIM VIA REMOTE >>> FIX (dano é validado no servidor) ============
local oldNC
oldNC=hookmetamethod(game,"__namecall",newcclosure(function(...)
    local args={...}
    local self=args[1]
    local method=getnamecallmethod()
    if st.sa and not checkcaller() and method=="InvokeServer" then
        local gun=findGun()
        local remote=gun and getShootRemote()
        if remote and rawequal(self,remote) and typeof(args[2])=="Vector3" then
            local mhrp=getMurderHRP()
            if mhrp and mhrp.Parent then
                local hrp=HRP()
                local vel=mhrp.AssemblyLinearVelocity or mhrp.Velocity or Vector3.zero
                local dist=(mhrp.Position-(hrp and hrp.Position or args[2])).Magnitude
                local t=math.clamp(dist/300,0.05,0.8) -- tempo de voo da bala
                args[2]=mhrp.Position+vel*t
                return oldNC(unpack(args))
            end
        end
    end
    return oldNC(unpack(args))
end))

local keys={}
local FLYKEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,[Enum.KeyCode.Space]=true,[Enum.KeyCode.LeftShift]=true}
U.InputBegan:Connect(function(i)if FLYKEYS[i.KeyCode]then keys[i.KeyCode]=true end end)
U.InputEnded:Connect(function(i)if FLYKEYS[i.KeyCode]then keys[i.KeyCode]=nil end end)
local tags={}
local function clear()for _,g in ipairs(tags)do pcall(function()g:Destroy()end)end tags={}end
local function tag(p,txt,col,nm,dist)local h=p.Character and p.Character:FindFirstChild("Head")if not h then return end local b=Instance.new("BillboardGui",h)b.Name="SZESP"b.Size=UDim2.new(0,130,0,28)b.AlwaysOnTop=true b.MaxDistance=700 b.StudsOffset=Vector3.new(0,3,0)local l=Instance.new("TextLabel",b)l.Size=UDim2.new(1,0,1,0)l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.TextScaled=true l.Text=txt..(nm and" | "..p.Name or"")..(dist and(" | "..dist.."m")or"")l.TextColor3=col l.TextStrokeTransparency=.2 tags[#tags+1]=b end
local function refresh()clear()local hrp=HRP()for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Head")local dist=hrp and h and math.floor((h.Position-hrp.Position).Magnitude+.5)or nil if has(p,"Knife")then tag(p,"ASSASSINO",Color3.fromRGB(255,70,70),true,dist)elseif has(p,"Gun")then tag(p,"XERIFE",Color3.fromRGB(70,160,255),true,dist)else tag(p,p.Name,Color3.fromRGB(0,220,120),false,dist)end end end end
local gunTag
local function espGun(v)if gunTag then pcall(function()gunTag:Destroy()end)gunTag=nil end if not v then return end local g=W:FindFirstChild("GunDrop",true)if not g then return end local part=g:IsA("BasePart")and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")if part then local b=Instance.new("BillboardGui",part)b.Name="SZGUN"b.Size=UDim2.new(0,100,0,24)b.AlwaysOnTop=true b.StudsOffset=Vector3.new(0,1,0)local l=Instance.new("TextLabel",b)l.Size=UDim2.new(1,0,1,0)l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.TextScaled=true l.Text="ARMA"l.TextColor3=Color3.fromRGB(255,200,60)l.TextStrokeTransparency=.2 gunTag=b end end
local tracers={}
local function clearTracers()for _,t in ipairs(tracers)do pcall(function()t:Remove()end)end tracers={}end
local function drawTracers()if not st.tr then clearTracers()return end if #tracers==0 then for i=1,#P:GetPlayers()-1 do local d=Drawing.new("Line")d.Thickness=1.5 d.Color=PUR d.Visible=true tracers[i]=d end end local i=0 for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Head")if h then i=i+1 local scr,onn=C:WorldToViewportPoint(h.Position)local d=tracers[i]if d then d.Visible=onn d.From=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y)d.To=Vector2.new(scr.X,scr.Y)end end end end for j=i+1,#tracers do tracers[j].Visible=false end end

task.spawn(function()
    local t1,t2,t3,t4=0,0,0,0 local lastAt=0 local lastEquip=0
    -- >>> FIX: estado do fly e do farm
    local flyVel=Vector3.zero local flyOn=false
    local farmCollected={} local farming=false

    while true do local dt=task.wait()local c=LP.Character local hrp=HRP()local hum=c and c:FindFirstChildOfClass("Humanoid")
        -- Speed fix >>> FIX: JumpPower -> JumpHeight
        if hum then if not st.fl then hum.WalkSpeed=st.speed or 32 end if st.jf then hum.JumpHeight=st.jf end end
        -- >>> FIX: Fly (CFrame normalizado + lerp, PlatformStand sem conflito com farm)
        if st.fl and hrp then
            local f=(keys[Enum.KeyCode.W] and 1 or 0)-(keys[Enum.KeyCode.S] and 1 or 0)
            local r=(keys[Enum.KeyCode.D] and 1 or 0)-(keys[Enum.KeyCode.A] and 1 or 0)
            local u=(keys[Enum.KeyCode.Space] and 1 or 0)-(keys[Enum.KeyCode.LeftShift] and 1 or 0)
            local dir=C.CFrame.LookVector*f+C.CFrame.RightVector*r+Vector3.new(0,u,0)
            if dir.Magnitude>1 then dir=dir.Unit end
            if hum then hum.PlatformStand=true end
            flyVel=flyVel:Lerp(dir*(st.speed or 32),0.35)
            hrp.CFrame=hrp.CFrame+flyVel*dt
            hrp.Velocity=Vector3.zero hrp.RotVelocity=Vector3.zero
            flyOn=true
        elseif hrp then
            local bv=hrp:FindFirstChild("SZBV")if bv then bv:Destroy()end
            if hum and flyOn then hum.PlatformStand=false flyOn=false end
        end
        local ncOn=(st.nc or st.cf)if ncOn and c then for _,v in ipairs(c:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end
        t1=t1+dt if t1>.5 then t1=0
            if st.nc then for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character then for _,v in ipairs(p.Character:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end end end
            if st.xr then for _,v in ipairs(W:GetDescendants())do if v:IsA("BasePart")and not(LP.Character and v:IsDescendantOf(LP.Character))then v.LocalTransparencyModifier=.75 end end else for _,v in ipairs(W:GetDescendants())do if v:IsA("BasePart")then v.LocalTransparencyModifier=0 end end end
            if st.fb then for _,v in ipairs(W:GetDescendants())do if v:IsA("SurfaceLight")or v:IsA("PointLight")then v.Range=1000 v.Brightness=3 end end game.Lighting.Ambient=Color3.new(1,1,1)game.Lighting.Brightness=2 end
            if st.alg then for _,v in ipairs(W:GetDescendants())do if v:IsA("Decal")or v:IsA("ParticleEmitter")or v:IsA("Fire")or v:IsA("Smoke")then pcall(function()v:Destroy()end)end end end
            if st.tp then local hd=tgt()if hd and hrp then hrp.CFrame=hd.CFrame*CFrame.new(0,2,0)end end
            if st.ar and not alive()then local resp=getR("Respawn")or getR("PlayerDied")or getR("Died")if resp then pcall(function()resp:InvokeServer()end)end end
        end
        t4=t4+dt if t4>=1 then t4=0 if st.espR then refresh()else clear()end if st.espG and not(gunTag and gunTag.Parent)then espGun(true)end end

        -- >>> FIX: AUTO SHOOT (predição com tempo de voo + linha de visão)
        if st.at then
            local murder=getMurder()
            local mhrp=murder and murder.Character and murder.Character:FindFirstChild("HumanoidRootPart")
            local g=findGun()
            local remote=getShootRemote()
            if g and murder and mhrp and remote and alive() and hrp then
                if g.Parent~=c then
                    local h=c and c:FindFirstChildOfClass("Humanoid")
                    if h then h:EquipTool(g) end
                    lastEquip=os.clock()+.15
                end
                if os.clock()>lastEquip and os.clock()-lastAt>.5 then
                    local vel=mhrp.AssemblyLinearVelocity or mhrp.Velocity or Vector3.zero
                    local dist=(mhrp.Position-hrp.Position).Magnitude
                    local flight=math.clamp(dist/300,0.05,0.8)
                    local predPos=mhrp.Position+vel*flight
                    local clear=true
                    local gOrigin=g:FindFirstChild("Handle")
                    local o=gOrigin and gOrigin.Position or hrp.Position
                    local params=RaycastParams.new()
                    params.FilterType=Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances={c,murder.Character}
                    if W:Raycast(o,(predPos-o),params) then clear=false end
                    if clear then
                        pcall(function() remote:InvokeServer(1,predPos,"AH2") end)
                    end
                    lastAt=os.clock()
                end
            end
        end

        -- KILL AURA (inalterado)
        if st.kill then local k=c and c:FindFirstChild("Knife")local hd=tgt()if hrp and k and hd and hd.Parent then local r=hd.Parent:FindFirstChild("HumanoidRootPart")if r then r.CFrame=hrp.CFrame+hrp.CFrame.LookVector*4 end local hp=k:FindFirstChild("Handle")if hp then for _,v in ipairs(hd.Parent:GetDescendants())do if v:IsA("BasePart")and v:FindFirstChild("TouchInterest")then firetouchinterest(hp,v,0)firetouchinterest(hp,v,1)end end end k:Activate()end end

        -- AUTO GUN (inalterado)
        t2=t2+dt if st.ag and t2>.6 then t2=0 local g=W:FindFirstChild("GunDrop",true)local part=g and(g:IsA("BasePart")and g or g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart"))if alive()and part and hrp then hrp.CFrame=part.CFrame*CFrame.new(0,0,2)task.wait(.08)for _,v in ipairs(g:GetDescendants())do if v:IsA("BasePart")and v:FindFirstChild("TouchInterest")then firetouchinterest(hrp,v,0)firetouchinterest(hrp,v,1)end end end end

        -- ANTI AFK (inalterado)
        t3=t3+dt if st.afk and t3>30 then t3=0 pcall(function()mousemoverel(0,2)end)end

        -- >>> FIX: AUTO FARM (filtro CoinVisual.Transparency==0 + tween sem restart)
        if st.cf and hrp and alive() then
            t3=t3+dt
            if not farming and t3>0.3 then
                t3=0
                local box=W:FindFirstChild("CoinContainer",true)
                if box then
                    local nearest,nearDist=nil,math.huge
                    for _,cn in ipairs(box:GetChildren())do
                        if cn:GetAttribute("CoinID")=="Coin" and cn:FindFirstChild("TouchInterest") and not farmCollected[cn] then
                            local vis=cn:FindFirstChild("CoinVisual") or cn:FindFirstChildWhichIsA("BasePart")
                            if vis and vis.Transparency==0 then
                                local d=(cn.Position-hrp.Position).Magnitude
                                if d<nearDist then nearDist=d nearest=cn end
                            end
                        end
                    end
                    if nearest then
                        if nearDist>5 then
                            local dur=math.clamp(nearDist/30,0.1,4)
                            farming=true
                            local tw=T:Create(hrp,TweenInfo.new(dur,Enum.EasingStyle.Linear),{
                                CFrame=CFrame.new(nearest.Position-Vector3.new(0,2.5,0))
                            })
                            tw:Play()
                            tw.Completed:Connect(function()
                                farming=false
                                if nearest and nearest.Parent and alive() then
                                    local hh=HRP()
                                    if hh and (nearest.Position-hh.Position).Magnitude<8 then
                                        firetouchinterest(hh,nearest,0)
                                        firetouchinterest(hh,nearest,1)
                                    end
                                    farmCollected[nearest]=true
                                end
                            end)
                        else
                            firetouchinterest(hrp,nearest,0)
                            firetouchinterest(hrp,nearest,1)
                            farmCollected[nearest]=true
                        end
                    end
                end
            end
        elseif not st.cf then
            farmCollected={}
            farming=false
        end
    end
end)
R.RenderStepped:Connect(function()drawTracers()end)

-- Round reset do farm
local function getR(n)local rm=RS:FindFirstChild("Remotes")local gp=rm and rm:FindFirstChild("Gameplay")return gp and gp:FindFirstChild(n)end
local RE=getR("RoundEndFade")if RE then RE.OnClientEvent:Connect(function()farmCollected={}end)end

LP.CharacterAdded:Connect(function()task.wait(.5)clear()end)

-- ============ INFINITE JUMP VIA JumpRequest >>> FIX ============
local ijConn,ijDeb=nil,false
local function setInfJump(on)
    if ijConn then ijConn:Disconnect() ijConn=nil end
    if not on then return end
    ijConn=U.JumpRequest:Connect(function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and not ijDeb then
            ijDeb=true
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait()
            ijDeb=false
        end
    end)
end

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
MkSlider(Pgs[1],"Speed","speed",0,250,32,1)
MkSlider(Pgs[1],"Jump Height","jf",0,60,6,1) -- >>> FIX: JumpHeight em studs
Mk(Pgs[1],"Fly","fl")
Mk(Pgs[1],"Noclip","nc")
Mk(Pgs[1],"Infinite Jump","ij",function(_,v)setInfJump(v)end) -- >>> FIX: liga/desliga via JumpRequest
Mk(Pgs[2],"ESP Roles","espR",function(_,v)if v then refresh()else clear()end end)Mk(Pgs[2],"ESP Gun","espG",function(_,v)espGun(v)end)Mk(Pgs[2],"Xray","xr")Mk(Pgs[2],"Tracers","tr")
Mk(Pgs[3],"Silent Aim","sa")Mk(Pgs[3],"Auto Shoot","at")Mk(Pgs[3],"Kill Aura","kill")
Mk(Pgs[4],"Coin Farm","cf")Mk(Pgs[4],"Auto Gun","ag")Mk(Pgs[4],"Anti AFK","afk")Mk(Pgs[4],"Auto Respawn","ar")
Mk(Pgs[5],"Teleport","tp")Mk(Pgs[5],"Fullbright","fb")Mk(Pgs[5],"Anti-Lag","alg")
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
