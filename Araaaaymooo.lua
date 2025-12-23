-- This script was generated using the MoonVeil Obfuscator v1.4.5 [https://moonveil.cc]

getgenv().Lighting=game:GetService'Lighting';
getgenv().RunService=game:GetService'RunService';
Skybox=Instance.new('Sky',Lighting);
Skybox.SkyboxBk='rbxassetid://153743489';
Skybox.SkyboxDn='rbxassetid://153743503';
Skybox.SkyboxFt='rbxassetid://153743479';
Skybox.SkyboxLf='rbxassetid://153743492';
Skybox.SkyboxRt='rbxassetid://153743485';
Skybox.SkyboxUp='rbxassetid://153743499'
local jf=Instance.new('ColorCorrectionEffect',Lighting);
jf.TintColor=Color3 .fromRGB(255,180,120);
jf.Brightness=0.20000000000000001;
jf.Contrast=0.40000000000000002;
jf.Enabled=true
local Db=Instance.new('SunRaysEffect',Lighting);
Db.Intensity=0.59999999999999998;
Db.Spread=0.90000000000000002;
Db.Enabled=true
local Pg=Instance.new('Atmosphere',Lighting);
Pg.Density=0.40000000000000002;
Pg.Offset=0;
Pg.Color=Color3 .fromRGB(255,150,100);
Pg.Decay=Color3 .fromRGB(255,120,80);
Pg.Glare=0.59999999999999998;
Pg.Haze=0.80000000000000004;
Lighting.Ambient=Color3 .fromRGB(180,120,80);
Lighting.OutdoorAmbient=Color3 .fromRGB(200,140,100);
Lighting.ClockTime=18.5;
Lighting.GeographicLatitude=20;
Lighting.GlobalShadows=true;
Lighting.ShadowSoftness=0.5
local qa,Ye=0,0;
RunService.Stepped:Connect(function()
    qa=qa+0.014999999999999999;
    Ye=Ye+0.0080000000000000002
    local Ea=math.sin(Ye)*0.29999999999999999+0.69999999999999996;
    Pg.Density=0.40000000000000002+math.sin(qa)*0.10000000000000001;
    Pg.Haze=0.80000000000000004+math.cos(qa*0.69999999999999996)*0.14999999999999999;
    Pg.Glare=0.59999999999999998+math.sin(qa*1.2)*0.20000000000000001;
    jf.TintColor=Color3 .fromRGB(255,180+math.sin(qa*0.5)*20,120+math.cos(qa*0.29999999999999999)*15);
    Db.Intensity=0.59999999999999998+math.sin(qa*2)*0.10000000000000001;
    Lighting.ClockTime=18.5+math.sin(qa*0.10000000000000001)*0.20000000000000001
    if Lighting then
        if Lighting:FindFirstChild'ColorCorrection'then
            do
                return nil
            end
        elseif Lighting:FindFirstChild'Correction'then
            do
                return nil
            end
        elseif Lighting:FindFirstChildOfClass'SunRaysEffect'then
            do
                return nil
            end
        end
    end
end)
local aa=Instance.new('BloomEffect',Lighting);
aa.Intensity=0.29999999999999999;
aa.Size=0.5;
aa.Threshold=0.80000000000000004;
getgenv().Lighting=game:GetService'Lighting';
getgenv().RunService=game:GetService'RunService';
Skybox=Instance.new('Sky',Lighting);
Skybox.SkyboxBk='rbxassetid://153743489';
Skybox.SkyboxDn='rbxassetid://153743503';
Skybox.SkyboxFt='rbxassetid://153743479';
Skybox.SkyboxLf='rbxassetid://153743492';
Skybox.SkyboxRt='rbxassetid://153743485';
Skybox.SkyboxUp='rbxassetid://153743499'
local k=Instance.new('ColorCorrectionEffect',Lighting);
k.TintColor=Color3 .fromRGB(255,180,120);
k.Brightness=0.20000000000000001;
k.Contrast=0.40000000000000002;
k.Enabled=true
local Ub=Instance.new('SunRaysEffect',Lighting);
Ub.Intensity=0.59999999999999998;
Ub.Spread=0.90000000000000002;
Ub.Enabled=true
local oe=Instance.new('Atmosphere',Lighting);
oe.Density=0.40000000000000002;
oe.Offset=0;
oe.Color=Color3 .fromRGB(255,150,100);
oe.Decay=Color3 .fromRGB(255,120,80);
oe.Glare=0.59999999999999998;
oe.Haze=0.80000000000000004;
Lighting.Ambient=Color3 .fromRGB(180,120,80);
Lighting.OutdoorAmbient=Color3 .fromRGB(200,140,100);
Lighting.ClockTime=18.5;
Lighting.GeographicLatitude=20;
Lighting.GlobalShadows=true;
Lighting.ShadowSoftness=0.5
local Ec,Th=0,0;
RunService.Stepped:Connect(function()
    Ec=Ec+0.014999999999999999;
    Th=Th+0.0080000000000000002
    local Md=math.sin(Th)*0.29999999999999999+0.69999999999999996;
    oe.Density=0.40000000000000002+math.sin(Ec)*0.10000000000000001;
    oe.Haze=0.80000000000000004+math.cos(Ec*0.69999999999999996)*0.14999999999999999;
    oe.Glare=0.59999999999999998+math.sin(Ec*1.2)*0.20000000000000001;
    k.TintColor=Color3 .fromRGB(255,180+math.sin(Ec*0.5)*20,120+math.cos(Ec*0.29999999999999999)*15);
    Ub.Intensity=0.59999999999999998+math.sin(Ec*2)*0.10000000000000001;
    Lighting.ClockTime=18.5+math.sin(Ec*0.10000000000000001)*0.20000000000000001
    if Lighting then
        if Lighting:FindFirstChild'ColorCorrection'then
            do
                Lighting:WaitForChild'ColorCorrection':Destroy()
            end
        elseif Lighting:FindFirstChild'Correction'then
            do
                Lighting:WaitForChild'Correction':Destroy()
            end
        elseif Lighting:FindFirstChildOfClass'SunRaysEffect'then
            do
                Lighting:WaitForChild'SunRaysEffect':Destroy()
            end
        end
    end
end)
local dc=Instance.new('BloomEffect',Lighting);
dc.Intensity=0.29999999999999999;
dc.Size=0.5;
dc.Threshold=0.80000000000000004
local Vd=loadstring(game:HttpGet'https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KYY.luau')()
local T,ef,oc,ke=Vd.new{MainColor=Color3 .fromRGB(138,43,226),ToggleKey=Enum.KeyCode.Insert,MinSize=Vector2 .new(450,320),CanResize=false},game:GetService'Players'.LocalPlayer,game:GetService'ReplicatedStorage',game:GetService'VirtualInputManager'
local vc,Jh=ef:WaitForChild'muscleEvent',ef:WaitForChild'leaderstats'
local fi,W,ba=Jh:WaitForChild'Rebirths',Jh:WaitForChild'Strength',ef:WaitForChild'Durability'
local function Gb(x)
    x=math.abs(x)
    if x>=1000000000000000 then
        return string.format('%.2fQa',x/1000000000000000)
    end
    if x>=1000000000000 then
        return string.format('%.2fT',x/1000000000000)
    end
    if x>=1000000000 then
        return string.format('%.2fB',x/1000000000)
    end
    if x>=1000000 then
        return string.format('%.2fM',x/1000000)
    end
    if x>=1000 then
        return string.format('%.2fK',x/1000)
    end
    return tostring(math.floor(x))
end
local function j()
    for Hh,Ne in pairs(ef.petsFolder:GetChildren())do
        if Ne:IsA'Folder'then
            for eg,nh in pairs(Ne:GetChildren())do
                oc.rEvents.equipPetEvent:FireServer('unequipPet',nh)
            end
        end
    end
end
local function Cf(Te)
    j();
    task.wait(0.10000000000000001)
    local oa={}
    for re_,ii in pairs(ef.petsFolder.Unique:GetChildren())do
        if ii.Name==Te then
            table.insert(oa,ii)
        end
    end
    for Rd=1,math.min(8,#oa)do
        oc.rEvents.equipPetEvent:FireServer('equipPet',oa[Rd])
    end
end
local function Zb(q,Sc)
    local qb=ef.Character:FindFirstChild(q)or ef.Backpack:FindFirstChild(q)
    if qb then
        vc:FireServer(Sc,qb)
    end
end
local function Cc()
    local Tf=ef.Character or ef.CharacterAdded:Wait()
    local Aa=Tf:WaitForChild'HumanoidRootPart';
    Aa.CFrame=CFrame.new(-8642.3960000000006,6.798,2086.1030000000001);
    task.wait(0.20000000000000001);
    ke:SendKeyEvent(true,Enum.KeyCode.E,false,game);
    task.wait(0.050000000000000003);
    ke:SendKeyEvent(false,Enum.KeyCode.E,false,game)
end
local function Bc()
    local Wg=ef.Character or ef.CharacterAdded:Wait()
    local mb=Wg:WaitForChild'HumanoidRootPart';
    mb.CFrame=CFrame.new(-8371.4339999999993,6.798,2858.8850000000002);
    task.wait(0.20000000000000001);
    ke:SendKeyEvent(true,Enum.KeyCode.E,false,game);
    task.wait(0.050000000000000003);
    ke:SendKeyEvent(false,Enum.KeyCode.E,false,game)
end
local function ai()
    for lc,sh in pairs(workspace:GetDescendants())do
        if sh:IsA'ParticleEmitter'or sh:IsA'PointLight'or sh:IsA'SpotLight'or sh:IsA'SurfaceLight'then
            sh:Destroy()
        end
    end
    local ra=game:GetService'Lighting'
    for o_,yh in pairs(ra:GetChildren())do
        if yh:IsA'Sky'then
            yh:Destroy()
        end
    end
    local Lg=Instance.new'Sky';
    Lg.SkyboxBk='rbxassetid://0';
    Lg.SkyboxDn='rbxassetid://0';
    Lg.SkyboxFt='rbxassetid://0';
    Lg.SkyboxLf='rbxassetid://0';
    Lg.SkyboxRt='rbxassetid://0';
    Lg.SkyboxUp='rbxassetid://0';
    Lg.Parent=ra;
    ra.Brightness=0;
    ra.ClockTime=0;
    ra.TimeOfDay='00:00:00';
    ra.OutdoorAmbient=Color3 .new(0,0,0);
    ra.Ambient=Color3 .new(0,0,0);
    ra.FogColor=Color3 .new(0,0,0);
    ra.FogEnd=100
end
local ed={'strengthFrame','durabilityFrame','agilityFrame'}
local function og()
    for Og,Ya in ipairs(ed)do
        local S=oc:FindFirstChild(Ya)
        if S and S:IsA'GuiObject'then
            S.Visible=false
        end
    end
end
oc.ChildAdded:Connect(function(Cb)
    if table.find(ed,Cb.Name)and Cb:IsA'GuiObject'then
        Cb.Visible=false
    end
end);
_G.whitelistedPlayers=_G.whitelistedPlayers or{};
_G.blacklistedPlayers=_G.blacklistedPlayers or{};
_G.killAll=false;
_G.killBlacklistedOnly=false;
_G.whitelistFriends=false;
_G.deathRingEnabled=false;
_G.showDeathRing=false;
_G.deathRingRange=20
local function tb()
    if not ef.Character then
        repeat
            task.wait()
        until ef.Character
    end
    return ef.Character
end
local function Z()
    for Sa,F in pairs(ef.Backpack:GetChildren())do
        if F.Name=='Punch'and ef.Character:FindFirstChild'Humanoid'then
            ef.Character.Humanoid:EquipTool(F)
        end
    end
    vc:FireServer('punch','leftHand');
    vc:FireServer('punch','rightHand')
end
local function ub(Ic)
    return Ic and Ic.Character and Ic.Character:FindFirstChild'HumanoidRootPart'and Ic.Character:FindFirstChild'Humanoid'and Ic.Character.Humanoid.Health>0
end
local function Ee(Ag)
    if not ub(Ag)then
        return
    end
    local Kg=tb()
    if Kg and Kg:FindFirstChild'LeftHand'then
        pcall(function()
            firetouchinterest(Ag.Character.HumanoidRootPart,Kg.LeftHand,0);
            firetouchinterest(Ag.Character.HumanoidRootPart,Kg.LeftHand,1);
            Z()
        end)
    end
end
local function cg(Id)
    for D,qg in ipairs(_G.whitelistedPlayers)do
        if qg:lower()==Id.Name:lower()then
            return true
        end
    end
    return false
end
local function A(Wd)
    for _h,Yc in ipairs(_G.blacklistedPlayers)do
        if Yc:lower()==Wd.Name:lower()then
            return true
        end
    end
    return false
end
local function hg(td)
    return td.DisplayName..' | '..td.Name
end
local hf=T:CreateWindow('KYY HUB 0.69 | POTANG INA MO \240\159\150\149\240\159\143\187','Markyy')
local Qh,kf,Oc,Df,li,fd,rh,Se,i_,Ob,Qg,g,Fe,di,vf=hf:CreateTab'REB1RTH - Packs',hf:CreateTab'STR3NGTH - Packs',hf:CreateTab'KILL3R',hf:CreateTab'F4RM REB & R0CK',hf:CreateTab'TEL3PORT',hf:CreateTab'SH0PEE',hf:CreateTab'PLAY3R ST4TS',0,0,false,{},0,tick(),fi.Value,fi.Value
local th_,db,Ih,ih=Qh:AddLabel'0d 0h 0m 0s \226\128\147 Inactive',Qh:AddLabel'Pace: 0 /h  |  0 /d  |  0 /w',Qh:AddLabel'Average: 0 /h  |  0 /d  |  0 /w',Qh:AddLabel('Rebirths: '..Gb(vf)..'  |  Gained: 0')
local function kh()
    local Wf=Ob and(tick()-Se+i_)or i_
    local lb,Jf,Kf,Mf=math.floor(Wf/86400),math.floor(Wf%86400/3600),math.floor(Wf%3600/60),math.floor(Wf%60);
    th_.Text=string.format('%dd %dh %dm %ds \226\128\147 %s',lb,Jf,Kf,Mf,Ob and'Rebirthing'or'Paused')
end
local function ag()
    g=g+1
    if g<2 then
        Fe=tick();
        di=fi.Value
        return
    end
    local jh,Oe=tick(),fi.Value-di
    if Oe<=0 then
        return
    end
    local kc=(jh-Fe)/Oe
    local jb,Lh,qd=3600/kc,86400/kc,604800/kc;
    db.Text=string.format('Pace: %s /h  |  %s /d  |  %s /w',Gb(jb),Gb(Lh),Gb(qd));
    table.insert(Qg,{h=jb,d=Lh,w=qd})
    if#Qg>20 then
        table.remove(Qg,1)
    end
    local pf,ja,Xg=0,0,0
    for c,ic in pairs(Qg)do
        pf=pf+ic.h;
        ja=ja+ic.d;
        Xg=Xg+ic.w
    end
    local _e=#Qg;
    Ih.Text=string.format('Average: %s /h  |  %s /d  |  %s /w',Gb(pf/_e),Gb(ja/_e),Gb(Xg/_e));
    Fe=jh;
    di=fi.Value
end
fi.Changed:Connect(function()
    ag();
    ih.Text='Rebirths: '..Gb(fi.Value)..'  |  Gained: '..Gb(fi.Value-vf)
end)
local function Jb()
    local We=5000+fi.Value*2550
    while Ob and W.Value<We do
        local la=ef.MembershipType==Enum.MembershipType.Premium and 8 or 14
        for wc=1,la do
            vc:FireServer'rep'
        end
        task.wait(0.02)
    end
    if Ob and W.Value>=We then
        Cf'Tribal Overlord';
        task.wait(0.25)
        local Fg=fi.Value
        repeat
            oc.rEvents.rebirthRemote:InvokeServer'rebirthRequest';
            task.wait(0.050000000000000003)
        until fi.Value>Fg or not Ob
    end
end
local function R()
    while Ob do
        Cf'Swift Samurai';
        Jb();
        task.wait(0.5)
    end
end
Qh:AddToggle('Fast Rebirth',false,function(Ia)
    Ob=Ia
    if Ia then
        Se=tick();
        g=0;
        task.spawn(R)
    else
        i_=i_+(tick()-Se);
        kh()
    end
end);
Qh:AddToggle('Hide Frames',false,function(qf)
    if qf then
        og()
    end
end)
local Jd=false;
Qh:AddButton('Anti AFK',function()
    Jd=true
end);
Qh:AddButton('Equip 8\195\151 Swift Samurai',function()
    Cf'Swift Samurai'
end);
Qh:AddButton('Anti Lag',ai)
local Ug,Da,Eb,kd=nil,false,nil,game:GetService'RunService'
local function wh_()
    if Ug then
        Ug:Disconnect()
    end
    Ug=nil
    local La=ef.Character and ef.Character:FindFirstChild'HumanoidRootPart'
    if La then
        La.Anchored=false
    end
end
local function xd()
    local ma=ef.Character and ef.Character:FindFirstChild'HumanoidRootPart'
    if not ma then
        return
    end
    Eb=ma.CFrame;
    ma.Anchored=true;
    Ug=kd.Heartbeat:Connect(function()
        local rf=ef.Character and ef.Character:FindFirstChild'HumanoidRootPart'
        if rf then
            rf.Anchored=true;
            rf.CFrame=Eb
        end
    end)
end
local function Cd(Pc)
    Da=Pc
    if Pc then
        xd()
    else
        wh_()
    end
end
ef.CharacterAdded:Connect(function(Wb)
    if Da then
        wh_();
        task.wait(0.20000000000000001);
        xd()
    end
end);
Qh:AddToggle('Lock 69 Position',false,Cd);
Qh:AddButton('TP Jungle Lift',Cc)
local Je=false;
task.spawn(function()
    while true do
        if Je then
            Zb('Protein Egg','proteinEgg');
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end);
Qh:AddToggle('Auto Protein Egg',false,function(pa)
    Je=pa
    if pa then
        Zb('Protein Egg','proteinEgg')
    end
end)
local Xh,Yh,fh,Ah,Gg,cc,cf,Vg,yc,qi,zb,Ph,mg,be,ye=0,0,false,false,W.Value,ba.Value,{},{},kf:AddLabel'0d 0h 0m 0s \226\128\147 Inactive',kf:AddLabel'Str Pace: 0 /h  |  0 /d  |  0 /w',kf:AddLabel'Dur Pace: 0 /h  |  0 /d  |  0 /w',kf:AddLabel'Avg Str: 0 /h  |  0 /d  |  0 /w',kf:AddLabel'Avg Dur: 0 /h  |  0 /d  |  0 /w',kf:AddLabel'Strength: 0  |  Gained: 0',kf:AddLabel'Durability: 0  |  Gained: 0'
local function cb()
    local Wh=fh and(tick()-Xh+Yh)or Yh
    local t_,Ve,m,Qe=math.floor(Wh/86400),math.floor(Wh%86400/3600),math.floor(Wh%3600/60),math.floor(Wh%60);
    yc.Text=string.format('%dd %dh %dm %ds \226\128\147 %s',t_,Ve,m,Qe,fh and'Running'or'Paused')
end
local vd=20
local function gi()
    local _i=game:GetService'Stats'
    local Dg=_i:FindFirstChild'PerformanceStats'and _i.PerformanceStats:FindFirstChild'Ping'
    return Dg and Dg:GetValue()or 0
end
local function Wc()
    while fh do
        local Mh=tick()
        while tick()-Mh<0.75 and fh do
            for fa_=1,vd do
                vc:FireServer'rep'
            end
            task.wait(0.02)
        end
        while fh and gi()>=350 do
            task.wait(1)
        end
    end
end
kf:AddTextBox('Rep Speed','20',function(a_)
    local fe=tonumber(a_)
    if fe and fe>0 then
        vd=math.floor(fe)
    end
end);
kf:AddToggle('Fast Strength',false,function(Hd)
    fh=Hd
    if Hd then
        Xh=tick();
        Ah=true;
        cf={};
        Vg={};
        task.spawn(Wc)
    else
        Yh=Yh+(tick()-Xh);
        Ah=false;
        cb()
    end
end);
kf:AddToggle('Hide Frames',false,function(If)
    if If then
        og()
    end
end)
local Xc=false;
kf:AddButton('Anti AFK',function()
    Xc=true
end);
kf:AddButton('Equip 8\195\151 Swift Samurai',function()
    Cf'Swift Samurai'
end);
kf:AddButton('Anti Lag',ai);
kf:AddButton('TP Jungle Squat',Bc)
local Gc,jd=false,false;
task.spawn(function()
    while true do
        if jd then
            Zb('Protein Egg','proteinEgg');
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end);
task.spawn(function()
    while true do
        if Gc then
            Zb('Tropical Shake','tropicalShake');
            task.wait(900)
        else
            task.wait(1)
        end
    end
end);
kf:AddToggle('Auto Protein Egg',false,function(gg)
    jd=gg
    if gg then
        Zb('Protein Egg','proteinEgg')
    end
end);
kf:AddToggle('Auto Tropical Shake',false,function(lg)
    Gc=lg
    if lg then
        Zb('Tropical Shake','tropicalShake')
    end
end);
Oc:AddToggle('Remove Attack Animations',false,function(Hb)
    if Hb then
        local nf={['rbxassetid://3638729053']=true,['rbxassetid://3638767427']=true}
        local function se_()
            local Yd=ef.Character
            if not Yd or not Yd:FindFirstChild'Humanoid'then
                return
            end
            local de=Yd:FindFirstChild'Humanoid'
            for qh,H in pairs(de:GetPlayingAnimationTracks())do
                if H.Animation then
                    local Ae,dh=H.Animation.AnimationId,H.Name:lower()
                    if nf[Ae]or dh:match'punch'or dh:match'attack'or dh:match'right'then
                        H:Stop()
                    end
                end
            end
            _G.AnimBlockConnection=de.AnimationPlayed:Connect(function(nc)
                if nc.Animation then
                    local ee,qc=nc.Animation.AnimationId,nc.Name:lower()
                    if nf[ee]or qc:match'punch'or qc:match'attack'or qc:match'right'then
                        nc:Stop()
                    end
                end
            end)
        end
        local function Vc(he)
            if he and(he.Name=='Punch'or he.Name:match'Attack'or he.Name:match'Right')then
                if not he:GetAttribute'ActivatedOverride'then
                    he:SetAttribute('ActivatedOverride',true);
                    _G.ToolConnections=_G.ToolConnections or{};
                    _G.ToolConnections[he]=he.Activated:Connect(function()
                        task.wait(0.050000000000000003)
                        local Pd=ef.Character
                        if Pd and Pd:FindFirstChild'Humanoid'then
                            for we,gh in pairs(Pd.Humanoid:GetPlayingAnimationTracks())do
                                if gh.Animation then
                                    local Ca,Ld=gh.Animation.AnimationId,gh.Name:lower()
                                    if nf[Ca]or Ld:match'punch'or Ld:match'attack'or Ld:match'right'then
                                        gh:Stop()
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
        local function mh()
            for Ig,yf in pairs(ef.Backpack:GetChildren())do
                Vc(yf)
            end
            local Fb=ef.Character
            if Fb then
                for Uf,bc in pairs(Fb:GetChildren())do
                    if bc:IsA'Tool'then
                        Vc(bc)
                    end
                end
            end
            _G.BackpackAddedConnection=ef.Backpack.ChildAdded:Connect(function(Vb)
                if Vb:IsA'Tool'then
                    task.wait(0.10000000000000001);
                    Vc(Vb)
                end
            end)
            if Fb then
                _G.CharacterToolAddedConnection=Fb.ChildAdded:Connect(function(ff)
                    if ff:IsA'Tool'then
                        task.wait(0.10000000000000001);
                        Vc(ff)
                    end
                end)
            end
        end
        _G.AnimMonitorConnection=game:GetService'RunService'.Heartbeat:Connect(function()
            if tick()%0.5<0.01 then
                local ei=ef.Character
                if ei and ei:FindFirstChild'Humanoid'then
                    for Vh,Zc in pairs(ei.Humanoid:GetPlayingAnimationTracks())do
                        if Zc.Animation then
                            local h,Of=Zc.Animation.AnimationId,Zc.Name:lower()
                            if nf[h]or Of:match'punch'or Of:match'attack'or Of:match'right'then
                                Zc:Stop()
                            end
                        end
                    end
                end
            end
        end);
        _G.CharacterAddedConnection=ef.CharacterAdded:Connect(function(hi)
            task.wait(1);
            se_();
            mh()
            if _G.CharacterToolAddedConnection then
                _G.CharacterToolAddedConnection:Disconnect()
            end
            _G.CharacterToolAddedConnection=hi.ChildAdded:Connect(function(uc)
                if uc:IsA'Tool'then
                    task.wait(0.10000000000000001);
                    Vc(uc)
                end
            end)
        end);
        se_();
        mh()
    else
        if _G.AnimBlockConnection then
            _G.AnimBlockConnection:Disconnect();
            _G.AnimBlockConnection=nil
        end
        if _G.AnimMonitorConnection then
            _G.AnimMonitorConnection:Disconnect();
            _G.AnimMonitorConnection=nil
        end
        if _G.CharacterAddedConnection then
            _G.CharacterAddedConnection:Disconnect();
            _G.CharacterAddedConnection=nil
        end
        if _G.BackpackAddedConnection then
            _G.BackpackAddedConnection:Disconnect();
            _G.BackpackAddedConnection=nil
        end
        if _G.CharacterToolAddedConnection then
            _G.CharacterToolAddedConnection:Disconnect();
            _G.CharacterToolAddedConnection=nil
        end
        if _G.ToolConnections then
            for Fc,Cg in pairs(_G.ToolConnections)do
                if Cg then
                    Cg:Disconnect()
                end
                if Fc and Fc:GetAttribute'ActivatedOverride'then
                    Fc:SetAttribute('ActivatedOverride',nil)
                end
            end
            _G.ToolConnections=nil
        end
    end
end)
local _a=false
local Vf,yg
local function ph()
    if not _a or not ef.Character then
        return
    end
    local B=0
    for Rf,Bd in ipairs(ef.Character:GetChildren())do
        if Bd.Name=='Protein Egg'then
            B=1
            if B>1 then
                Bd.Parent=ef.Backpack
            end
        end
    end
    if B==0 then
        local d_=ef.Backpack:FindFirstChild'Protein Egg'
        if d_ then
            d_.Parent=ef.Character
        end
    end
end
Oc:AddToggle('NaN (Egg+NaN+Punch Combo)',false,function(lf)
    _a=lf
    if lf then
        if oc:FindFirstChild'rEvents'and oc.rEvents:FindFirstChild'changeSpeedSizeRemote'then
            local Sd=oc.rEvents.changeSpeedSizeRemote;
            Sd:InvokeServer('changeSize',0/0)
        else
            print'changeSpeedSizeRemote not found - NaN size may not work'
        end
        Vf=task.spawn(function()
            while _a do
                ph();
                task.wait(0.20000000000000001)
            end
        end);
        yg=ef.CharacterAdded:Connect(function(Mb)
            task.wait(0.5);
            ph()
        end);
        ph()
    else
        if Vf then
            task.cancel(Vf)
        end
        if yg then
            yg:Disconnect()
        end
    end
end);
Oc:AddButton('Disable Eggs',function()
    loadstring(game:HttpGet'https://raw.githubusercontent.com/244ihssp/IlIIS/refs/heads/main/1')()
end);
Oc:AddLabel'Auto Kill:'
local function ki()
    local nb,ri,Lb=game.Players:GetPlayers(),{},{}
    for ne,Rh in ipairs(nb)do
        if Rh~=ef then
            local fg=hg(Rh);
            table.insert(ri,fg);
            table.insert(Lb,fg)
        end
    end
    local Le,ie=Oc:AddDropdown('Add to Whitelist',ri,function(ng)
        local ta=ng:match'| (.+)$'
        if ta then
            ta=ta:gsub('^%s*(.-)%s*$','%1')
            for Ib,e_ in ipairs(_G.whitelistedPlayers)do
                if e_:lower()==ta:lower()then
                    return
                end
            end
            table.insert(_G.whitelistedPlayers,ta);
            print('Added to whitelist: '..ta)
        end
    end),Oc:AddDropdown('Add to Kill',Lb,function(Qa)
        local sc=Qa:match'| (.+)$'
        if sc then
            sc=sc:gsub('^%s*(.-)%s*$','%1')
            for Ad,Zg in ipairs(_G.blacklistedPlayers)do
                if Zg:lower()==sc:lower()then
                    return
                end
            end
            table.insert(_G.blacklistedPlayers,sc);
            print('Added to blacklist: '..sc)
        end
    end)
    return Le,ie
end
local te,Ng=ki()
local function Ze()
    te:Clear();
    Ng:Clear()
    local Hg,Bb=updatePlayerLists()
    for Be,Ma in ipairs(Hg)do
        te:Add(Ma)
    end
    for kg,Ch in ipairs(Bb)do
        Ng:Add(Ch)
    end
end
local function ga()
    local od,eb,Yb=game.Players:GetPlayers(),{},{}
    for gf,Xd in ipairs(od)do
        if Xd~=ef then
            local xh=hg(Xd);
            table.insert(eb,xh);
            table.insert(Yb,xh)
        end
    end
    te:UpdateDropdown(eb);
    Ng:UpdateDropdown(Yb)
end
game.Players.PlayerAdded:Connect(function()
    task.wait(0.5);
    ga()
end);
game.Players.PlayerRemoving:Connect(function()
    task.wait(0.10000000000000001);
    ga()
end);
Oc:AddToggle('Kill Everyone',false,function(Ff)
    _G.killAll=Ff;
    print('Kill Everyone: '..tostring(Ff))
    if Ff then
        if not _G.killAllConnection then
            _G.killAllConnection=game:GetService'RunService'.Heartbeat:Connect(function()
                if _G.killAll then
                    for ug,Za in ipairs(game:GetService'Players':GetPlayers())do
                        if Za~=ef and not cg(Za)then
                            Ee(Za)
                        end
                    end
                end
            end);
            print'Kill Everyone connection started'
        end
    else
        if _G.killAllConnection then
            _G.killAllConnection:Disconnect();
            _G.killAllConnection=nil;
            print'Kill Everyone connection stopped'
        end
    end
end);
Oc:AddToggle('Whitelist Friends',false,function(md)
    _G.whitelistFriends=md;
    print('Whitelist Friends: '..tostring(md))
    if md then
        for xg,Mc in pairs(game.Players:GetPlayers())do
            if Mc~=ef and Mc:IsFriendsWith(ef.UserId)then
                local fb,Qd=Mc.Name,false
                for ci,Ab in ipairs(_G.whitelistedPlayers)do
                    if Ab:lower()==fb:lower()then
                        Qd=true
                        break
                    end
                end
                if not Qd then
                    table.insert(_G.whitelistedPlayers,fb);
                    print('Auto-whitelisted friend: '..fb)
                end
            end
        end
        game.Players.PlayerAdded:Connect(function(wa)
            if _G.whitelistFriends and wa:IsFriendsWith(ef.UserId)then
                local Jc,Ke=wa.Name,false
                for me,ha in ipairs(_G.whitelistedPlayers)do
                    if ha:lower()==Jc:lower()then
                        Ke=true
                        break
                    end
                end
                if not Ke then
                    table.insert(_G.whitelistedPlayers,Jc);
                    print('Auto-whitelisted new friend: '..Jc)
                end
            end
        end)
    end
end);
Oc:AddToggle('Kill Target',false,function(J)
    _G.killBlacklistedOnly=J;
    print('Kill List: '..tostring(J))
    if J then
        if not _G.blacklistKillConnection then
            _G.blacklistKillConnection=game:GetService'RunService'.Heartbeat:Connect(function()
                if _G.killBlacklistedOnly then
                    for Ua,Bf in ipairs(game:GetService'Players':GetPlayers())do
                        if Bf~=ef and A(Bf)then
                            Ee(Bf)
                        end
                    end
                end
            end);
            print'Kill List connection started'
        end
    else
        if _G.blacklistKillConnection then
            _G.blacklistKillConnection:Disconnect();
            _G.blacklistKillConnection=nil;
            print'Kill List connection stopped'
        end
    end
end)
local ji,hd,Fh,fc,_d,if_,Oa,Zf=game:GetService'RunService',workspace.CurrentCamera,nil,nil,nil,false,nil,nil
local function Sf(Ja)
    if Zf then
        Zf:Disconnect();
        Zf=nil
    end
    if Ja and Ja.Character then
        _d=Ja
        local dg=Ja.Character:FindFirstChildOfClass'Humanoid'
        if dg then
            if not Fh then
                Fh=hd.CameraSubject;
                fc=hd.CameraType
            end
            hd.CameraType=Enum.CameraType.Custom;
            hd.CameraSubject=dg;
            Zf=Ja.CharacterAdded:Connect(function(tf)
                task.wait(0.5)
                local Xb=tf:FindFirstChildOfClass'Humanoid'
                if Xb and if_ then
                    hd.CameraSubject=Xb
                end
            end);
            print('Spectating: '..Ja.Name)
        else
            print('No humanoid found for: '..Ja.Name)
        end
    else
        if if_ then
            stopSpectate()
        end
    end
end
local function df()
    if_=false;
    _d=nil
    if Zf then
        Zf:Disconnect();
        Zf=nil
    end
    if Fh then
        hd.CameraSubject=Fh;
        hd.CameraType=fc or Enum.CameraType.Custom;
        Fh=nil;
        fc=nil
    else
        local Mg=game.Players.LocalPlayer
        if Mg.Character then
            local bh=Mg.Character:FindFirstChildOfClass'Humanoid'
            if bh then
                hd.CameraSubject=bh;
                hd.CameraType=Enum.CameraType.Custom
            end
        end
    end
    print'Spectate stopped'
end
Oc:AddToggle('Spectate',false,function(pe)
    if_=pe;
    print('Spectate: '..tostring(pe))
    if pe then
        if Oa then
            Sf(Oa)
        else
            print'No player selected for spectating';
            if_=false
        end
    else
        df()
    end
end)
local bd=nil
local function xb()
    local lh,Gd=game.Players:GetPlayers(),{}
    for Od,za in ipairs(lh)do
        if za~=ef then
            table.insert(Gd,za.DisplayName..' | '..za.Name)
        end
    end
    bd=Oc:AddDropdown('Spectate Player',Gd,function(Zd)
        for bb,Xa in ipairs(game.Players:GetPlayers())do
            local ah=Xa.DisplayName..' | '..Xa.Name
            if Zd==ah then
                Oa=Xa
                if if_ then
                    Sf(Xa)
                end
                print('Selected player for spectate: '..Xa.Name)
                break
            end
        end
    end)
    return bd
end
local function u_()
    local sb,zc=game.Players:GetPlayers(),{}
    for Ra,ka in ipairs(sb)do
        if ka~=ef then
            table.insert(zc,ka.DisplayName..' | '..ka.Name)
        end
    end
    if bd then
        bd:UpdateDropdown(zc);
        print('Spectate dropdown refreshed with '..#zc..' players')
    end
end
xb();
game.Players.PlayerAdded:Connect(function(ya)
    task.wait(0.5);
    u_()
end);
game.Players.PlayerRemoving:Connect(function(bf)
    if Oa and Oa==bf then
        Oa=nil
        if if_ then
            df()
        end
    end
    u_()
end);
Oc:AddLabel'Kill Aura:'
local gb,r_=nil,Color3 .fromRGB(50,163,255)
local function uh()
    if not gb then
        return
    end
    local vh=(_G.deathRingRange or 20)*2;
    gb.Size=Vector3 .new(0.20000000000000001,vh,vh)
end
local function Na()
    if _G.showDeathRing then
        gb=Instance.new'Part';
        gb.Shape=Enum.PartType.Cylinder;
        gb.Material=Enum.Material.Neon;
        gb.Color=r_;
        gb.Transparency=0.59999999999999998;
        gb.Anchored=true;
        gb.CanCollide=false;
        gb.CastShadow=false;
        uh();
        gb.Parent=workspace;
        print'Death ring visual created'
    elseif gb then
        gb:Destroy();
        gb=nil;
        print'Death ring visual destroyed'
    end
end
local function hh()
    if not gb then
        return
    end
    local wg=tb()
    local K=wg and wg:FindFirstChild'HumanoidRootPart'
    if K then
        gb.CFrame=K.CFrame*CFrame.Angles(0,0,math.rad(90))
    end
end
Oc:AddTextBox('Death Ring Range (1-140)','20',function(Tb)
    local le=tonumber(Tb)
    if le then
        _G.deathRingRange=math.clamp(le,1,140);
        uh();
        print('Death ring range set to: '.._G.deathRingRange)
    end
end);
Oc:AddToggle('Death Ring',false,function(oh)
    _G.deathRingEnabled=oh;
    print('Death Ring: '..tostring(oh))
    if oh then
        if not _G.deathRingConnection then
            _G.deathRingConnection=game:GetService'RunService'.Heartbeat:Connect(function()
                if _G.deathRingEnabled then
                    hh()
                    local Yg=tb()
                    local of=Yg and Yg:FindFirstChild'HumanoidRootPart'and Yg.HumanoidRootPart.Position
                    if not of then
                        return
                    end
                    for I,C in ipairs(game:GetService'Players':GetPlayers())do
                        if C~=ef and not cg(C)and ub(C)then
                            local l_=(of-C.Character.HumanoidRootPart.Position).Magnitude
                            if l_<=(_G.deathRingRange or 20)then
                                Ee(C)
                            end
                        end
                    end
                end
            end);
            print'Death ring connection started'
        end
    else
        if _G.deathRingConnection then
            _G.deathRingConnection:Disconnect();
            _G.deathRingConnection=nil;
            print'Death ring connection stopped'
        end
    end
end);
Oc:AddToggle('Show Death Ring',false,function(ab)
    _G.showDeathRing=ab;
    Na()
end)
local Re,zd=Oc:AddLabel'Whitelist: None',Oc:AddLabel'Killlist: None';
Oc:AddButton('Clear Whitelist',function()
    _G.whitelistedPlayers={};
    print'Whitelist cleared'
end);
Oc:AddButton('Clear Blacklist',function()
    _G.blacklistedPlayers={};
    print'Blacklist cleared'
end)
local function rd()
    if#_G.whitelistedPlayers==0 then
        Re.Text='Whitelist: None'
    else
        Re.Text='Whitelist: '..table.concat(_G.whitelistedPlayers,', ')
    end
end
local function Tc()
    if#_G.blacklistedPlayers==0 then
        zd.Text='Killlist: None'
    else
        zd.Text='Killlist: '..table.concat(_G.blacklistedPlayers,', ')
    end
end
task.spawn(function()
    while true do
        rd();
        Tc();
        task.wait(0.20000000000000001)
    end
end)
local Hc,M=false,nil
local function pi(ig)
    if not ig then
        return
    end
    local P=ig:FindFirstChild'HumanoidRootPart'
    if not P then
        return
    end
    local pg=P:FindFirstChild'KYYAntiFling'
    if pg then
        pg:Destroy()
    end
    local Ha=Instance.new'BodyVelocity';
    Ha.Name='KYYAntiFling';
    Ha.MaxForce=Vector3 .new(100000,0,100000);
    Ha.Velocity=Vector3 .new(0,0,0);
    Ha.P=1250;
    Ha.Parent=P
end
local function Eh(pc)
    if not pc then
        return
    end
    local Me=pc:FindFirstChild'HumanoidRootPart'
    if not Me then
        return
    end
    local Eg=Me:FindFirstChild'KYYAntiFling'
    if Eg then
        Eg:Destroy()
    end
end
local function Nd(Pb)
    Hc=Pb
    if Pb then
        if ef.Character then
            pi(ef.Character)
        end
        if M then
            M:Disconnect()
        end
        M=ef.CharacterAdded:Connect(function(ua)
            task.wait(0.10000000000000001);
            pi(ua)
        end)
    else
        if M then
            M:Disconnect();
            M=nil
        end
        if ef.Character then
            Eh(ef.Character)
        end
    end
end
ef.CharacterRemoving:Connect(function(rc)
    if not Hc then
        return
    end
end);
Oc:AddToggle('Anti Fling',false,function(Xf)
    Nd(Xf)
end);
Oc:AddLabel'Prevents being flung by other players';
task.spawn(function()
    while true do
        kh();
        task.wait(0.10000000000000001)
    end
end);
task.spawn(function()
    local uf=tick()
    while true do
        local Sg=tick();
        cb();
        be.Text='Strength: '..Gb(W.Value)..'  |  Gained: '..Gb(W.Value-Gg);
        ye.Text='Durability: '..Gb(ba.Value)..'  |  Gained: '..Gb(ba.Value-cc)
        if fh then
            table.insert(cf,{t=Sg,v=W.Value});
            table.insert(Vg,{t=Sg,v=ba.Value})
            while#cf>0 and Sg-cf[1].t>10 do
                table.remove(cf,1)
            end
            while#Vg>0 and Sg-Vg[1].t>10 do
                table.remove(Vg,1)
            end
            if Sg-uf>=10 then
                uf=Sg
                if#cf>=2 then
                    local Uc=cf[#cf].v-cf[1].v
                    local Ue=Uc/10;
                    qi.Text=string.format('Str Pace: %s /h  |  %s /d  |  %s /w',Gb(Ue*3600),Gb(Ue*86400),Gb(Ue*604800))
                end
                if#Vg>=2 then
                    local Ka=Vg[#Vg].v-Vg[1].v
                    local Dc=Ka/10;
                    zb.Text=string.format('Dur Pace: %s /h  |  %s /d  |  %s /w',Gb(Dc*3600),Gb(Dc*86400),Gb(Dc*604800))
                end
                local pb=Yh+(Sg-Xh)
                if pb>0 then
                    local Rg=(W.Value-Gg)/pb;
                    Ph.Text=string.format('Avg Str: %s /h  |  %s /d  |  %s /w',Gb(Rg*3600),Gb(Rg*86400),Gb(Rg*604800))
                    local Lf=(ba.Value-cc)/pb;
                    mg.Text=string.format('Avg Dur: %s /h  |  %s /d  |  %s /w',Gb(Lf*3600),Gb(Lf*86400),Gb(Lf*604800))
                end
            end
        end
        task.wait(0.050000000000000003)
    end
end)
local ge,b_,Wa=game:GetService'Players',game:GetService'UserInputService',game:GetService'GuiService'
local Q=ge.LocalPlayer
local Xe=Instance.new('ScreenGui',Q:WaitForChild'PlayerGui');
Xe.Name='AntiAFKOverlay'
local V=Instance.new('TextLabel',Xe);
V.Size=UDim2 .new(0,200,0,50);
V.Position=UDim2 .new(0.5,-100,0,-50);
V.TextColor3=Color3 .fromRGB(50,255,50);
V.Font=Enum.Font.GothamBold;
V.TextSize=20;
V.BackgroundTransparency=1;
V.TextTransparency=1;
V.Text='ANTI AFK'
local Ef=Instance.new('TextLabel',Xe);
Ef.Size=UDim2 .new(0,200,0,30);
Ef.Position=UDim2 .new(0.5,-100,0,-20);
Ef.TextColor3=Color3 .fromRGB(255,255,255);
Ef.Font=Enum.Font.GothamBold;
Ef.TextSize=18;
Ef.BackgroundTransparency=1;
Ef.TextTransparency=1;
Ef.Text='00:00:00'
local mf=tick();
task.spawn(function()
    while true do
        local Va=tick()-mf
        local z,dd,sa=math.floor(Va/3600),math.floor((Va%3600)/60),math.floor(Va%60);
        Ef.Text=string.format('%02d:%02d:%02d',z,dd,sa);
        task.wait(1)
    end
end);
task.spawn(function()
    while true do
        for ac=0,1,0.01 do
            V.TextTransparency=1-ac;
            Ef.TextTransparency=1-ac;
            task.wait(0.014999999999999999)
        end
        task.wait(1.5)
        for Ge=0,1,0.01 do
            V.TextTransparency=Ge;
            Ef.TextTransparency=Ge;
            task.wait(0.014999999999999999)
        end
        task.wait(0.80000000000000004)
    end
end)
local Oh,Gh,kb={totalKills=0,sessionKills=0,killStreak=0,bestStreak=0,startTime=tick(),lastKillTime=0,killsPerMinute=0,killRate=0,leaderboardKills=0,lastLeaderboardCheck=0},{},Instance.new'ScreenGui';
kb.Name='KillCounterGUI';
kb.Parent=ef:WaitForChild'PlayerGui';
kb.Enabled=false
local Rc=Instance.new'Frame';
Rc.Size=UDim2 .new(0,280,0,240);
Rc.Position=UDim2 .new(0.02,0,0.29999999999999999,0);
Rc.BackgroundColor3=Color3 .fromRGB(173,216,230);
Rc.BorderSizePixel=2;
Rc.BorderColor3=Color3 .fromRGB(135,206,250);
Rc.Active=true;
Rc.Draggable=true;
Rc.Parent=kb
local na=Instance.new'Frame';
na.Size=UDim2 .new(1,12,1,12);
na.Position=UDim2 .new(0,-6,0,-6);
na.BackgroundColor3=Color3 .fromRGB(173,216,230);
na.BackgroundTransparency=0.69999999999999996;
na.BorderSizePixel=0;
na.ZIndex=-1;
na.Parent=Rc
local zh=Instance.new'UICorner';
zh.CornerRadius=UDim.new(0,12);
zh.Parent=na
local rg=Instance.new'UICorner';
rg.CornerRadius=UDim.new(0,8);
rg.Parent=Rc
local hc=Instance.new'UIGradient';
hc.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3 .fromRGB(135,206,250)),ColorSequenceKeypoint.new(0.5,Color3 .fromRGB(173,216,230)),ColorSequenceKeypoint.new(1,Color3 .fromRGB(135,206,250))};
hc.Rotation=45;
hc.Parent=Rc
local Nf=Instance.new'TextLabel';
Nf.Size=UDim2 .new(1,0,0,25);
Nf.Position=UDim2 .new(0,0,0,0);
Nf.BackgroundTransparency=1;
Nf.Text='\226\154\148\239\184\143 KILL COUNTER \226\154\148\239\184\143';
Nf.TextColor3=Color3 .fromRGB(255,255,255);
Nf.Font=Enum.Font.Garamond;
Nf.TextSize=18;
Nf.TextStrokeTransparency=0;
Nf.TextStrokeColor3=Color3 .fromRGB(0,100,200);
Nf.Parent=Rc
local tc=Instance.new'Frame';
tc.Size=UDim2 .new(0.90000000000000002,0,0,1);
tc.Position=UDim2 .new(0.050000000000000003,0,0,25);
tc.BackgroundColor3=Color3 .fromRGB(255,255,255);
tc.BackgroundTransparency=0.5;
tc.BorderSizePixel=0;
tc.Parent=Rc
local ad=Instance.new'TextLabel';
ad.Size=UDim2 .new(1,0,0,20);
ad.Position=UDim2 .new(0,0,0,27);
ad.BackgroundTransparency=1;
ad.Text='Session: 00:00:00';
ad.TextColor3=Color3 .fromRGB(255,255,255);
ad.Font=Enum.Font.Garamond;
ad.TextSize=14;
ad.TextStrokeTransparency=0.5;
ad.TextStrokeColor3=Color3 .fromRGB(0,0,0);
ad.Parent=Rc
local jc=Instance.new'Frame';
jc.Size=UDim2 .new(0.90000000000000002,0,0,1);
jc.Position=UDim2 .new(0.050000000000000003,0,0,47);
jc.BackgroundColor3=Color3 .fromRGB(255,255,255);
jc.BackgroundTransparency=0.5;
jc.BorderSizePixel=0;
jc.Parent=Rc
local xc=Instance.new'TextLabel';
xc.Size=UDim2 .new(1,0,0,25);
xc.Position=UDim2 .new(0,0,0,48);
xc.BackgroundTransparency=1;
xc.Text='Total Kills: 0';
xc.TextColor3=Color3 .fromRGB(255,255,255);
xc.Font=Enum.Font.Garamond;
xc.TextSize=18;
xc.TextStrokeTransparency=0.5;
xc.TextStrokeColor3=Color3 .fromRGB(0,0,0);
xc.Parent=Rc
local hb=Instance.new'Frame';
hb.Size=UDim2 .new(0.90000000000000002,0,0,1);
hb.Position=UDim2 .new(0.050000000000000003,0,0,73);
hb.BackgroundColor3=Color3 .fromRGB(255,255,255);
hb.BackgroundTransparency=0.5;
hb.BorderSizePixel=0;
hb.Parent=Rc
local gc=Instance.new'TextLabel';
gc.Size=UDim2 .new(1,0,0,20);
gc.Position=UDim2 .new(0,0,0,74);
gc.BackgroundTransparency=1;
gc.Text='Session Kills: 0';
gc.TextColor3=Color3 .fromRGB(0,255,0);
gc.Font=Enum.Font.Garamond;
gc.TextSize=14;
gc.TextStrokeTransparency=0.5;
gc.TextStrokeColor3=Color3 .fromRGB(0,0,0);
gc.Parent=Rc
local mc=Instance.new'Frame';
mc.Size=UDim2 .new(0.90000000000000002,0,0,1);
mc.Position=UDim2 .new(0.050000000000000003,0,0,94);
mc.BackgroundColor3=Color3 .fromRGB(255,255,255);
mc.BackgroundTransparency=0.5;
mc.BorderSizePixel=0;
mc.Parent=Rc
local zg=Instance.new'TextLabel';
zg.Size=UDim2 .new(1,0,0,20);
zg.Position=UDim2 .new(0,0,0,95);
zg.BackgroundTransparency=1;
zg.Text='Leaderboard: 0';
zg.TextColor3=Color3 .fromRGB(255,215,0);
zg.Font=Enum.Font.Garamond;
zg.TextSize=14;
zg.TextStrokeTransparency=0.5;
zg.TextStrokeColor3=Color3 .fromRGB(0,0,0);
zg.Parent=Rc
local oi=Instance.new'Frame';
oi.Size=UDim2 .new(0.90000000000000002,0,0,1);
oi.Position=UDim2 .new(0.050000000000000003,0,0,115);
oi.BackgroundColor3=Color3 .fromRGB(255,255,255);
oi.BackgroundTransparency=0.5;
oi.BorderSizePixel=0;
oi.Parent=Rc
local E=Instance.new'TextLabel';
E.Size=UDim2 .new(1,0,0,20);
E.Position=UDim2 .new(0,0,0,116);
E.BackgroundTransparency=1;
E.Text='Streak: 0 | Best: 0';
E.TextColor3=Color3 .fromRGB(255,255,0);
E.Font=Enum.Font.Garamond;
E.TextSize=14;
E.TextStrokeTransparency=0.5;
E.TextStrokeColor3=Color3 .fromRGB(0,0,0);
E.Parent=Rc
local _c=Instance.new'Frame';
_c.Size=UDim2 .new(0.90000000000000002,0,0,1);
_c.Position=UDim2 .new(0.050000000000000003,0,0,136);
_c.BackgroundColor3=Color3 .fromRGB(255,255,255);
_c.BackgroundTransparency=0.5;
_c.BorderSizePixel=0;
_c.Parent=Rc
local Yf=Instance.new'TextLabel';
Yf.Size=UDim2 .new(1,0,0,20);
Yf.Position=UDim2 .new(0,0,0,137);
Yf.BackgroundTransparency=1;
Yf.Text='KPM: 0.0 | Rate: 0.0/h';
Yf.TextColor3=Color3 .fromRGB(0,255,255);
Yf.Font=Enum.Font.Garamond;
Yf.TextSize=14;
Yf.TextStrokeTransparency=0.5;
Yf.TextStrokeColor3=Color3 .fromRGB(0,0,0);
Yf.Parent=Rc
local nd=Instance.new'Frame';
nd.Size=UDim2 .new(0.90000000000000002,0,0,1);
nd.Position=UDim2 .new(0.050000000000000003,0,0,157);
nd.BackgroundColor3=Color3 .fromRGB(255,255,255);
nd.BackgroundTransparency=0.5;
nd.BorderSizePixel=0;
nd.Parent=Rc
local ch=Instance.new'TextLabel';
ch.Size=UDim2 .new(1,0,0,20);
ch.Position=UDim2 .new(0,0,0,158);
ch.BackgroundTransparency=1;
ch.Text='Last Kill: Never';
ch.TextColor3=Color3 .fromRGB(255,165,0);
ch.Font=Enum.Font.Garamond;
ch.TextSize=14;
ch.TextStrokeTransparency=0.5;
ch.TextStrokeColor3=Color3 .fromRGB(0,0,0);
ch.Parent=Rc
local Nh=Instance.new'Frame';
Nh.Size=UDim2 .new(0.90000000000000002,0,0,1);
Nh.Position=UDim2 .new(0.050000000000000003,0,0,178);
Nh.BackgroundColor3=Color3 .fromRGB(255,255,255);
Nh.BackgroundTransparency=0.5;
Nh.BorderSizePixel=0;
Nh.Parent=Rc
local ni_=Instance.new'TextLabel';
ni_.Size=UDim2 .new(1,0,0,20);
ni_.Position=UDim2 .new(0,0,0,179);
ni_.BackgroundTransparency=1;
ni_.Text='Sync: Waiting...';
ni_.TextColor3=Color3 .fromRGB(255,255,255);
ni_.Font=Enum.Font.Garamond;
ni_.TextSize=14;
ni_.TextStrokeTransparency=0.5;
ni_.TextStrokeColor3=Color3 .fromRGB(0,0,0);
ni_.Parent=Rc
local pd=Instance.new'Frame';
pd.Size=UDim2 .new(0.90000000000000002,0,0,1);
pd.Position=UDim2 .new(0.050000000000000003,0,0,199);
pd.BackgroundColor3=Color3 .fromRGB(255,255,255);
pd.BackgroundTransparency=0.5;
pd.BorderSizePixel=0;
pd.Parent=Rc
local sd=Instance.new'TextLabel';
sd.Size=UDim2 .new(1,0,0,20);
sd.Position=UDim2 .new(0,0,0,200);
sd.BackgroundTransparency=1;
sd.Text='Status: Idle';
sd.TextColor3=Color3 .fromRGB(255,255,255);
sd.Font=Enum.Font.Garamond;
sd.TextSize=14;
sd.TextStrokeTransparency=0.5;
sd.TextStrokeColor3=Color3 .fromRGB(0,0,0);
sd.Parent=Rc;
task.spawn(function()
    while true do
        for wf=0,1,0.02 do
            local Td=0.5+(math.sin(wf*math.pi*2)*0.29999999999999999);
            na.BackgroundTransparency=Td;
            task.wait(0.050000000000000003)
        end
    end
end)
local function af()
    local Tg,Y=pcall(function()
        local Zh=ef:FindFirstChild'leaderstats'
        if Zh then
            local Bh=Zh:FindFirstChild'Kills'or Zh:FindFirstChild'kills'or Zh:FindFirstChild'KO'or Zh:FindFirstChild'Knockouts'
            if Bh then
                return Bh.Value
            end
        end
        local Pf=ef:FindFirstChild'Stats'
        if Pf then
            local Kd=Pf:FindFirstChild'Kills'or Pf:FindFirstChild'kills'
            if Kd then
                return Kd.Value
            end
        end
        local Qb=ef:FindFirstChild'DataFolder'or ef:FindFirstChild'data'
        if Qb then
            local ea=Qb:FindFirstChild'Kills'or Qb:FindFirstChild'kills'
            if ea then
                return ea.Value
            end
        end
        return 0
    end)
    return Tg and Y or 0
end
local function Rb()
    local function bi(ob)
        if ob==ef then
            return
        end
        local function Ga(vb)
            local p=vb:WaitForChild'Humanoid';
            p.Died:Connect(function()
                local ec=tick();
                Gh[ob.Name]=ec
                local s_,jg=ef.Character,ob.Character
                if s_ and jg then
                    local vg,ue=s_:FindFirstChild'HumanoidRootPart',jg:FindFirstChild'HumanoidRootPart'
                    if vg and ue then
                        local ca=(vg.Position-ue.Position).Magnitude
                        if ca<=50 then
                            recordKill(ob.Name)
                        end
                    end
                end
                if _G.killAll or _G.killBlacklistedOnly or _G.deathRingEnabled then
                    task.wait(0.10000000000000001);
                    recordKill(ob.Name)
                end
            end)
        end
        if ob.Character then
            Ga(ob.Character)
        end
        ob.CharacterAdded:Connect(Ga)
    end
    for _g,_b in ipairs(game.Players:GetPlayers())do
        if _b~=ef then
            bi(_b)
        end
    end
    game.Players.PlayerAdded:Connect(function(ia)
        bi(ia)
    end)
end
task.spawn(function()
    while true do
        local Ba=tick()-Oh.startTime
        local yb,ud,Gf=math.floor(Ba/3600),math.floor((Ba%3600)/60),math.floor(Ba%60);
        ad.Text=string.format('Session: %02d:%02d:%02d',yb,ud,Gf)
        if Oh.sessionKills>0 then
            local wd=Ba/60;
            Oh.killsPerMinute=Oh.sessionKills/wd;
            Oh.killRate=Oh.sessionKills/(Ba/3600);
            Yf.Text=string.format('KPM: %.1f | Rate: %.1f/h',Oh.killsPerMinute,Oh.killRate)
        end
        if tick()-Oh.lastLeaderboardCheck>5 then
            local Dd=af()
            if Dd>Oh.leaderboardKills then
                Oh.leaderboardKills=Dd;
                zg.Text='Leaderboard: '..Oh.leaderboardKills;
                ni_.Text='Sync: Updated'
            else
                ni_.Text='Sync: Standby'
            end
            Oh.lastLeaderboardCheck=tick()
        end
        task.wait(1)
    end
end)
function recordKill(He)
    Oh.totalKills=Oh.totalKills+1;
    Oh.sessionKills=Oh.sessionKills+1;
    Oh.killStreak=Oh.killStreak+1;
    Oh.lastKillTime=tick()
    if Oh.killStreak>Oh.bestStreak then
        Oh.bestStreak=Oh.killStreak
    end
    xc.Text='Total Kills: '..Oh.totalKills;
    gc.Text='Session Kills: '..Oh.sessionKills;
    E.Text=string.format('Streak: %d | Best: %d',Oh.killStreak,Oh.bestStreak);
    ch.Text='Last Kill: '..He;
    sd.Text='Status: Kill!';
    ni_.Text='Sync: Kill Detected';
    task.wait(3);
    sd.Text='Status: Idle';
    ni_.Text='Sync: Standby'
end
ef.CharacterAdded:Connect(function()
    Oh.killStreak=0;
    E.Text=string.format('Streak: %d | Best: %d',Oh.killStreak,Oh.bestStreak)
end);
Rb();
Oc:AddToggle('Show Kill Counter',false,function(Ud)
    kb.Enabled=Ud
end);
Oc:AddLabel'Kill Counter starts OFF - toggle above to show';
Oc:AddButton('Reset Session Stats',function()
    Oh.sessionKills=0;
    Oh.killStreak=0;
    Oh.startTime=tick();
    gc.Text='Session Kills: 0';
    E.Text='Streak: 0 | Best: '..Oh.bestStreak;
    Yf.Text='KPM: 0.0 | Rate: 0.0/h';
    sd.Text='Session Reset';
    ni_.Text='Sync: Reset';
    task.wait(1);
    sd.Text='Status: Idle';
    ni_.Text='Sync: Standby'
end);
Oc:AddButton('Force Sync Leaderboard',function()
    local ze=af();
    Oh.leaderboardKills=ze;
    zg.Text='Leaderboard: '..Oh.leaderboardKills;
    ni_.Text='Sync: Manual Update';
    task.wait(2);
    ni_.Text='Sync: Standby'
end);
Df:AddLabel'Auto Farm Tools'
local N,Fd,Nb=nil,false,{'Weight','Pushups','Situps','Handstands','Punch','Stomp','Ground Slam'}
local ae,n_=Df:AddDropdown('Select Tool',Nb,function(Sh)
    N=Sh
end),Df:AddToggle('Auto Farm',false,function(tg)
    Fd=tg
    local Nc=game:GetService'Players'.LocalPlayer
    local ce=Nc:WaitForChild'muscleEvent'
    if tg then
        task.spawn(function()
            while Fd do
                if N and Nc.Character then
                    if N=='Weight'or N=='Pushups'or N=='Situps'or N=='Handstands'then
                        if not Nc.Character:FindFirstChild(N)then
                            local yd=Nc.Backpack:FindFirstChild(N)
                            if yd then
                                Nc.Character.Humanoid:EquipTool(yd)
                            end
                        end
                        ce:FireServer'rep'
                    elseif N=='Punch'then
                        local wb=Nc.Backpack:FindFirstChild'Punch'
                        if wb then
                            wb.Parent=Nc.Character
                            if wb:FindFirstChild'attackTime'then
                                wb.attackTime.Value=0
                            end
                        end
                        ce:FireServer('punch','rightHand');
                        ce:FireServer('punch','leftHand')
                        if Nc.Character:FindFirstChild'Punch'then
                            Nc.Character.Punch:Activate()
                        end
                    elseif N=='Stomp'then
                        local Ed=Nc.Backpack:FindFirstChild'Stomp'
                        if Ed then
                            Ed.Parent=Nc.Character
                            if Ed:FindFirstChild'attackTime'then
                                Ed.attackTime.Value=0
                            end
                        end
                        ce:FireServer'stomp'
                        if Nc.Character:FindFirstChild'Stomp'then
                            Nc.Character.Stomp:Activate()
                        end
                    elseif N=='Ground Slam'then
                        local ve=Nc.Backpack:FindFirstChild'Ground Slam'
                        if ve then
                            ve.Parent=Nc.Character
                            if ve:FindFirstChild'attackTime'then
                                ve.attackTime.Value=0
                            end
                        end
                        ce:FireServer'slam'
                        if Nc.Character:FindFirstChild'Ground Slam'then
                            Nc.Character['Ground Slam']:Activate()
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end);
Df:AddLabel'Auto Farm Rock'
local X,ib,Ie,da=nil,false,{['Tiny Rock']=0,['Starter Island']=100,['Punching Rock']=1000,['Golden Rock']=5000,['Frost Rock']=150000,['Mythical Rock']=400000,['Eternal Rock']=750000,['Legend Rock']=1000000,['Muscle King Rock']=5000000,['Jungle Rock']=10000000},{}
for v in pairs(Ie)do
    table.insert(da,v)
end
local Ac=Df:AddDropdown('Select Rock',da,function(Pe)
    X=Pe
end)
local function Af()
    local Bg=game:GetService'Players'.LocalPlayer
    for f_,mi in pairs(Bg.Backpack:GetChildren())do
        if mi.Name=='Punch'and Bg.Character:FindFirstChild'Humanoid'then
            Bg.Character.Humanoid:EquipTool(mi)
        end
    end
    local Kc=Bg:WaitForChild'muscleEvent';
    Kc:FireServer('punch','leftHand');
    Kc:FireServer('punch','rightHand')
end
local Sb=Df:AddToggle('Auto Rock',false,function(bg)
    ib=bg
    local gd=game:GetService'Players'.LocalPlayer
    if bg and X then
        task.spawn(function()
            local G=Ie[X]
            while ib do
                task.wait()
                if gd.Durability.Value>=G then
                    for Kb,Jg in pairs(workspace.machinesFolder:GetDescendants())do
                        if Jg.Name=='neededDurability'and Jg.Value==G and gd.Character:FindFirstChild'LeftHand'and gd.Character:FindFirstChild'RightHand'then
                            local O=Jg.Parent:FindFirstChild'Rock'
                            if O then
                                firetouchinterest(O,gd.Character.RightHand,0);
                                firetouchinterest(O,gd.Character.RightHand,1);
                                firetouchinterest(O,gd.Character.LeftHand,0);
                                firetouchinterest(O,gd.Character.LeftHand,1);
                                Af()
                            end
                        end
                    end
                end
            end
        end)
    end
end);
Df:AddLabel'Auto Rebirth'
local Qf,Qc,Lc,ld,xf=0,false,game:GetService'Players'.LocalPlayer,Df:AddLabel'Current Rebirths: 0',Df:AddLabel'Target: None';
task.spawn(function()
    while true do
        local rb=Lc.leaderstats:FindFirstChild'Rebirths'
        if rb then
            ld.Text='Current Rebirths: '..tostring(rb.Value);
            xf.Text='Target: '..(Qf>0 and tostring(Qf)or'None')
        end
        task.wait(0.5)
    end
end);
Df:AddTextBox('Rebirth Target','Enter number',function(L)
    Qf=tonumber(L)or 0;
    print('Rebirth target set to: '..Qf)
end)
local w_=game:GetService'ReplicatedStorage':FindFirstChild'rEvents'
if w_ then
    local _f=w_:FindFirstChild'rebirthRemote'
    if _f then
        Df:AddLabel'\226\156\147 Rebirth remote found'
    else
        Df:AddLabel'\226\156\151 Rebirth remote not found'
    end
end
Df:AddToggle('Auto Rebirth',false,function(xa)
    Qc=xa;
    print('Auto rebirth toggle: '..tostring(xa))
    if xa and Qf>0 then
        task.spawn(function()
            local De,si=Lc.leaderstats:WaitForChild'Rebirths',game:GetService'ReplicatedStorage'.rEvents.rebirthRemote
            while Qc do
                local va=De.Value;
                print('Current rebirths: '..va..' / Target: '..Qf)
                if va>=Qf then
                    print'Target reached, stopping auto rebirth';
                    autoRebirthToggle:Set(false)
                    break
                end
                local sf=false;
                pcall(function()
                    si:InvokeServer'rebirthRequest';
                    sf=true
                end)
                if not sf then
                    pcall(function()
                        si:InvokeServer'rebirth'
                    end)
                end
                if not sf then
                    pcall(function()
                        si:FireServer'rebirthRequest'
                    end)
                end
                task.wait(0.20000000000000001)
            end
        end)
    elseif xa and Qf<=0 then
        print'No target set, turning off auto rebirth';
        autoRebirthToggle:Set(false)
    end
end);
li:AddLabel'Main Locations';
li:AddButton('Tiny Island',function()
    local Fa=game:GetService'Players'.LocalPlayer.Character
    if Fa and Fa:FindFirstChild'HumanoidRootPart'then
        Fa.HumanoidRootPart.CFrame=CFrame.new(-37.100000000000001,9.1999999999999993,1919)
    end
end);
li:AddButton('Main Island',function()
    local eh=game:GetService'Players'.LocalPlayer.Character
    if eh and eh:FindFirstChild'HumanoidRootPart'then
        eh.HumanoidRootPart.CFrame=CFrame.new(16.07,9.0800000000000001,133.80000000000001)
    end
end);
li:AddButton('Beach',function()
    local Kh=game:GetService'Players'.LocalPlayer.Character
    if Kh and Kh:FindFirstChild'HumanoidRootPart'then
        Kh.HumanoidRootPart.CFrame=CFrame.new(-8,9,-169.19999999999999)
    end
end);
li:AddLabel'Gyms';
li:AddButton('Muscle King Gym',function()
    local y=game:GetService'Players'.LocalPlayer.Character
    if y and y:FindFirstChild'HumanoidRootPart'then
        y.HumanoidRootPart.CFrame=CFrame.new(-8665.3999999999996,17.210000000000001,-5792.8999999999996)
    end
end);
li:AddButton('Jungle Gym',function()
    local zf=game:GetService'Players'.LocalPlayer.Character
    if zf and zf:FindFirstChild'HumanoidRootPart'then
        zf.HumanoidRootPart.CFrame=CFrame.new(-8543,6.7999999999999998,2400)
    end
end);
li:AddButton('Legends Gym',function()
    local Hf=game:GetService'Players'.LocalPlayer.Character
    if Hf and Hf:FindFirstChild'HumanoidRootPart'then
        Hf.HumanoidRootPart.CFrame=CFrame.new(4516,991.5,-3856)
    end
end);
fd:AddLabel'Pet Shop'
local id,xe='Darkstar Hunter',{'Darkstar Hunter','Neon Guardian','Blue Pheonix','Crimson Falcon','Cybernetic Showdown Dragon','Dark Golem','Dark Legends Manticore','Eternal Strike Leviathan','Frostwave Legends Penguin','Gold Warrior','Golden Viking','Infernal Dragon','Muscle Sensei'}
local je=fd:AddDropdown('Select Pet',xe,function(qe)
    id=qe
end);
fd:AddToggle('Auto Buy Pet',false,function(Uh)
    while Uh and id do
        local U=game:GetService'ReplicatedStorage'.cPetShopFolder:FindFirstChild(id)
        if U then
            game:GetService'ReplicatedStorage'.cPetShopRemote:InvokeServer(U)
        end
        task.wait(0.10000000000000001)
    end
end);
fd:AddLabel'Aura Shop'
local Pa,Dh='Entropic Blast',{'Entropic Blast','Muscle King','Astral Electro','Azure Tundra','Dark Electro','Dark Lightning','Dark Storm','Electro','Enchanted Mirage','Eternal Megastrike','Grand Supernova','Inferno','Lightning','Power Lightning','Purple Nova','Supernova'}
local cd=fd:AddDropdown('Select Aura',Dh,function(sg)
    Pa=sg
end);
fd:AddToggle('Auto Buy Aura',false,function(Ta)
    while Ta and Pa do
        local Ce=game:GetService'ReplicatedStorage'.cPetShopFolder:FindFirstChild(Pa)
        if Ce then
            game:GetService'ReplicatedStorage'.cPetShopRemote:InvokeServer(Ce)
        end
        task.wait(0.10000000000000001)
    end
end)
