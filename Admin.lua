-- Function
local function giveToolToPlayer(tool)
    local player = game.Players.LocalPlayer
    if player and player.Backpack then
        local toolClone = tool:Clone()
        toolClone.Parent = player.Backpack
    end
end

local function createTeleportTool()
    local TeleportTool = Instance.new("Tool")
    TeleportTool.Name = "TeleportTool"
    TeleportTool.RequiresHandle = false

    local Mouse = nil
    TeleportTool.Equipped:Connect(function()
        local player = game.Players.LocalPlayer
        Mouse = player:GetMouse()
    end)

    TeleportTool.Activated:Connect(function()
        if Mouse and Mouse.Hit then
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
            end
        end
    end)
    return TeleportTool
end

local function createDeleteTool()
    local DeleteTool = Instance.new("Tool")
    DeleteTool.Name = "DeleteTool"
    DeleteTool.RequiresHandle = false

    local Mouse = nil
    DeleteTool.Equipped:Connect(function()
        local player = game.Players.LocalPlayer
        Mouse = player:GetMouse()
    end)

    DeleteTool.Activated:Connect(function()
        if Mouse and Mouse.Target then
            local target = Mouse.Target
            if target and target.Parent and not target:IsDescendantOf(game.Players.LocalPlayer.Character) then
                target:Destroy()
            end
        end
    end)
    return DeleteTool
end

local function createShield()
    local Shield = Instance.new("Part")
    Shield.Name = "Shield"
    Shield.Size = Vector3.new(4, 5, 1)
    Shield.Transparency = 0.5
    Shield.BrickColor = BrickColor.new("Bright blue")
    Shield.Anchored = false
    Shield.CanCollide = false

    local Weld = Instance.new("WeldConstraint")

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    Shield.Parent = character
    Shield.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
    Weld.Part0 = Shield
    Weld.Part1 = hrp
    Weld.Parent = Shield

    character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if Shield and Shield.Parent then
            if character.Humanoid.Health < character.Humanoid.MaxHealth then
                character.Humanoid.Health = character.Humanoid.MaxHealth
            end
        end
    end)
    return Shield
end

local function createPunchTool()
    local PunchTool = Instance.new("Tool")
    PunchTool.Name = "PunchTool"
    PunchTool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Parent = PunchTool

    PunchTool.Activated:Connect(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local mouse = player:GetMouse()
        if mouse.Target and mouse.Target.Parent and mouse.Target.Parent:FindFirstChild("Humanoid") then
            local targetHumanoid = mouse.Target.Parent.Humanoid
            local targetHRP = mouse.Target.Parent:FindFirstChild("HumanoidRootPart")
            if targetHumanoid and targetHRP then
                targetHumanoid:TakeDamage(20)
                targetHRP.Velocity = (targetHRP.Position - character.HumanoidRootPart.Position).Unit * 100 + Vector3.new(0, 50, 0)
            end
        end
    end)
    return PunchTool
end

local function createPaintDeleteGun()
    local PaintDeleteGun = Instance.new("Tool")
    PaintDeleteGun.Name = "PaintDeleteGun"
    PaintDeleteGun.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 2)
    handle.Parent = PaintDeleteGun

    local mouse = nil
    PaintDeleteGun.Equipped:Connect(function()
        mouse = game.Players.LocalPlayer:GetMouse()
    end)

    PaintDeleteGun.Activated:Connect(function()
        if mouse and mouse.Target then
            local target = mouse.Target
            if target and target:IsA("BasePart") then
                target.BrickColor = BrickColor.new("Bright red")
                wait(1)
                target:Destroy()
            end
        end
    end)
    return PaintDeleteGun
end
 
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fast Admin",
    SubTitle = "Admin Commands Panel",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local PlayersTab = Window:AddTab({ Title = "Players Control", Icon = "👤" })
local ServerTab = Window:AddTab({ Title = "Server Control", Icon = "🛠" })
local AdminsTab = Window:AddTab({ Title = "Admins & Permissions", Icon = "🔒" })
local AdvancedTab = Window:AddTab({ Title = "Advanced Commands", Icon = "⚙️" })
local ToolsTab = Window:AddTab({ Title = "Tools", Icon = "🛠️" })

local function getPlayerByName(name)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Name:lower() == name:lower() then
            return player
        end
    end
    return nil
end

local targetName = ""

-- ===== Players Control Tab =====
PlayersTab:AddInput({
    Title = "Target Player Name",
    Default = "",
    Placeholder = "Enter player name",
    Callback = function(value)
        targetName = value
    end
})

PlayersTab:AddButton({
    Title = "Bring Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        local localPlayer = game.Players.LocalPlayer
        if target and target.Character and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            target.Character:MoveTo(localPlayer.Character.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
        end
    end
})

PlayersTab:AddButton({
    Title = "Teleport to Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        local localPlayer = game.Players.LocalPlayer
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character then
            localPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
        end
    end
})

PlayersTab:AddButton({
    Title = "Kill Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    end
})

PlayersTab:AddButton({
    Title = "Fling Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-1000, 1000), math.random(500, 1000), math.random(-1000, 1000))
        end
    end
})

PlayersTab:AddButton({
    Title = "Freeze Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target and target.Character then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "Unfreeze Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target and target.Character then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "Make Player Invisible",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "Make Player Visible",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "Reset Player Character",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            target:LoadCharacter()
        end
    end
})

PlayersTab:AddButton({
    Title = "Bring All Players",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = localPlayer.Character.HumanoidRootPart.Position
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player ~= localPlayer then
                    player.Character:MoveTo(pos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                end
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "Teleport All Players To Local",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = localPlayer.Character.HumanoidRootPart.Position
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character:MoveTo(pos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                end
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "God Mode Toggle",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.MaxHealth ~= math.huge then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            else
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "NoClip Toggle",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if humanoid:FindFirstChild("NoClip") then
                    humanoid.NoClip:Destroy()
                    humanoid.PlatformStand = false
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                else
                    local noClipVal = Instance.new("BoolValue")
                    noClipVal.Name = "NoClip"
                    noClipVal.Parent = humanoid
                    humanoid.PlatformStand = true
                    
                    coroutine.wrap(function()
                        while noClipVal and noClipVal.Parent do
                            for _, part in pairs(player.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                            wait()
                        end
                        for _, part in pairs(player.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = true
                            end
                        end
                    end)()
                end
            end
        end
    end
})

PlayersTab:AddButton({
    Title = "Set WalkSpeed Boost",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid.WalkSpeed = 50
        end
    end
})

PlayersTab:AddButton({
    Title = "Reset WalkSpeed",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid.WalkSpeed = 16
        end
    end
})

PlayersTab:AddButton({
    Title = "Set JumpPower Boost",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid.JumpPower = 100
        end
    end
})

PlayersTab:AddButton({
    Title = "Reset JumpPower",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid.JumpPower = 50
        end
    end
})

-- ===== Server Control Tab =====
local chatEnabled = true
local buildingAllowed = true

ServerTab:AddButton({
    Title = "Toggle Chat",
    Callback = function()
        chatEnabled = not chatEnabled
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, chatEnabled)
    end
})

ServerTab:AddButton({
    Title = "Kick All Players",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer then
                player:Kick("Kicked by Admin")
            end
        end
    end
})

ServerTab:AddButton({
    Title = "Server Shutdown (Kick All)",
    Callback = function()
        for _, player in pairs(game.Players:GetPlayers()) do
            player:Kick("Server shutting down")
        end
    end
})

ServerTab:AddButton({
    Title = "Enable Building",
    Callback = function()
        buildingAllowed = true
        if workspace:FindFirstChild("BuildingAllowed") then
            workspace.BuildingAllowed.Value = true
        end
    end
})

ServerTab:AddButton({
    Title = "Disable Building",
    Callback = function()
        buildingAllowed = false
        if workspace:FindFirstChild("BuildingAllowed") then
            workspace.BuildingAllowed.Value = false
        end
    end
})

ServerTab:AddButton({
    Title = "Set Gravity",
    Callback = function()
        local gravityInput = Window:CreateInput({
            Title = "Enter Gravity Value",
            Default = "196.2",
            Placeholder = "e.g. 196.2",
            Callback = function(value)
                local gravity = tonumber(value)
                if gravity then
                    workspace.Gravity = gravity
                end
            end
        })
    end
})

-- ===== Admins & Permissions Tab =====
AdminsTab:AddInput({
    Title = "Target Player Name",
    Default = "",
    Placeholder = "Enter player name",
    Callback = function(value)
        targetName = value
    end
})

AdminsTab:AddButton({
    Title = "Grant Admin to Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/admin " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Remove Admin from Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/deadmin " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "List All Players",
    Callback = function()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/players", "All")
    end
})

AdminsTab:AddButton({
    Title = "Mute Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/mute " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Unmute Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/unmute " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Ban Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/ban " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Unban Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/unban " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Kick Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/kick " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Freeze Player (Admin)",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/freeze " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Unfreeze Player (Admin)",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/unfreeze " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Give Admin Rank",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/giverank " .. target.Name .. " admin", "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Remove Admin Rank",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/removerank " .. target.Name .. " admin", "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Promote Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/promote " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Demote Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/demote " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Teleport Player to Me",
    Callback = function()
        local target = getPlayerByName(targetName)
        local localPlayer = game.Players.LocalPlayer
        if target and target.Character and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            target.Character:MoveTo(localPlayer.Character.HumanoidRootPart.Position)
        end
    end
})

AdminsTab:AddButton({
    Title = "Teleport Me to Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        local localPlayer = game.Players.LocalPlayer
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character then
            localPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position)
        end
    end
})

AdminsTab:AddButton({
    Title = "Reset Player Character (Admin)",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/reset " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Shutdown Server",
    Callback = function()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/shutdown", "All")
    end
})

AdminsTab:AddButton({
    Title = "Restart Server",
    Callback = function()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/restart", "All")
    end
})

AdminsTab:AddButton({
    Title = "Set Player WalkSpeed",
    Callback = function()
        local speedInput = Window:CreateInput({
            Title = "WalkSpeed Value",
            Default = "50",
            Placeholder = "Enter number e.g. 50",
            Callback = function(value)
                local speed = tonumber(value)
                local target = getPlayerByName(targetName)
                if speed and target and target.Character and target.Character:FindFirstChild("Humanoid") then
                    target.Character.Humanoid.WalkSpeed = speed
                end
            end
        })
    end
})

AdminsTab:AddButton({
    Title = "Set Player JumpPower",
    Callback = function()
        local powerInput = Window:CreateInput({
            Title = "JumpPower Value",
            Default = "100",
            Placeholder = "Enter number e.g. 100",
            Callback = function(value)
                local power = tonumber(value)
                local target = getPlayerByName(targetName)
                if power and target and target.Character and target.Character:FindFirstChild("Humanoid") then
                    target.Character.Humanoid.JumpPower = power
                end
            end
        })
    end
})

AdminsTab:AddButton({
    Title = "Chat Announcement",
    Callback = function()
        local announcementInput = Window:CreateInput({
            Title = "Announcement Text",
            Default = "",
            Placeholder = "Type message here",
            Callback = function(value)
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/announce " .. value, "All")
            end
        })
    end
})

AdvancedTab:AddButton({
    Title = "Give Tool",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/give " .. target.Name .. " tool", "All")
        end
    end
})

AdvancedTab:AddButton({
    Title = "Remove Tool",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/removetool " .. target.Name, "All")
        end
    end
})

AdvancedTab:AddButton({
    Title = "Set Gravity",
    Callback = function()
        local gravityInput = Window:CreateInput({
            Title = "Gravity Value",
            Default = "196.2",
            Placeholder = "Enter gravity (default 196.2)",
            Callback = function(value)
                local gravity = tonumber(value)
                if gravity then
                    workspace.Gravity = gravity
                end
            end
        })
    end
})

AdvancedTab:AddButton({
    Title = "Enable Noclip",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
})

AdvancedTab:AddButton({
    Title = "Disable Noclip",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

AdvancedTab:AddButton({
    Title = "Set Time of Day",
    Callback = function()
        local timeInput = Window:CreateInput({
            Title = "Time (0-24)",
            Default = "12",
            Placeholder = "Enter time value",
            Callback = function(value)
                local time = tonumber(value)
                if time and time >= 0 and time <= 24 then
                    game:GetService("Lighting").TimeOfDay = string.format("%02d:00:00", math.floor(time))
                end
            end
        })
    end
})

AdvancedTab:AddButton({
    Title = "Enable Fly",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        for _, child in pairs(character.HumanoidRootPart:GetChildren()) do
            if child:IsA("BodyVelocity") then
                child:Destroy()
            end
        end

        local flying = true
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = character.HumanoidRootPart

        local UIS = game:GetService("UserInputService")
        
        if character:FindFirstChild("FlyInputBeganConnection") then
            character.FlyInputBeganConnection:Disconnect()
            character.FlyInputBeganConnection:Destroy()
        end
        
        if character:FindFirstChild("FlyInputEndedConnection") then
            character.FlyInputEndedConnection:Disconnect()
            character.FlyInputEndedConnection:Destroy()
        end

        -- إنشاء اتصالات جديدة وتخزينها
        local inputBeganConn = UIS.InputBegan:Connect(function(input)
            if flying and input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W then
                    bodyVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * 50
                elseif input.KeyCode == Enum.KeyCode.S then
                    bodyVelocity.Velocity = -character.HumanoidRootPart.CFrame.RightVector * 50
                elseif input.KeyCode == Enum.KeyCode.D then
                    bodyVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * 50
                elseif input.KeyCode == Enum.KeyCode.Space then
                    bodyVelocity.Velocity = Vector3.new(0, 50, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftControl then
                    bodyVelocity.Velocity = Vector3.new(0, -50, 0)
                end
            end
        end)
        
        local inputEndedConn = UIS.InputEnded:Connect(function(input)
            if flying and input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W or
                   input.KeyCode == Enum.KeyCode.S or
                   input.KeyCode == Enum.KeyCode.A or
                   input.KeyCode == Enum.KeyCode.D or
                   input.KeyCode == Enum.KeyCode.Space or
                   input.KeyCode == Enum.KeyCode.LeftControl then
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
        
        local inputBeganInstance = Instance.new("ObjectValue")
        inputBeganInstance.Name = "FlyInputBeganConnection"
        inputBeganInstance.Parent = character
        
        local inputEndedInstance = Instance.new("ObjectValue")
        inputEndedInstance.Name = "FlyInputEndedConnection"
        inputEndedInstance.Parent = character
    end
})

AdvancedTab:AddButton({
    Title = "Disable Fly",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, child in pairs(character.HumanoidRootPart:GetChildren()) do
                if child:IsA("BodyVelocity") and child.Name == "FlyVelocity" then
                    child:Destroy()
                end
            end
            
            if character:FindFirstChild("FlyInputBeganConnection") then
                character.FlyInputBeganConnection:Destroy()
            end
            
            if character:FindFirstChild("FlyInputEndedConnection") then
                character.FlyInputEndedConnection:Destroy()
            end
        end
    end
})

ToolsTab:AddButton({
    Title = "Give Teleport Tool",
    Callback = function()
        local tool = createTeleportTool()
        giveToolToPlayer(tool)
    end
})

ToolsTab:AddButton({
    Title = "Give Delete Tool",
    Callback = function()
        local tool = createDeleteTool()
        giveToolToPlayer(tool)
    end
})

ToolsTab:AddButton({
    Title = "Give Shield",
    Callback = function()
        createShield()
    end
})

ToolsTab:AddButton({
    Title = "Give Punch Tool",  
    Callback = function()
        local tool = createPunchTool()
        giveToolToPlayer(tool)
    end
})

ToolsTab:AddButton({
    Title = "Give Paint & Delete Gun",
    Callback = function()
        local tool = createPaintDeleteGun()
        giveToolToPlayer(tool)
    end
})

local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "⚙️" })

SettingsTab:AddButton({
    Title = "Toggle UI",
    Callback = function()
        if Window.Enabled then
            Window:Hide()
        else
            Window:Show()
        end
    end
})

SettingsTab:AddToggle("DarkModeToggle", {
    Title = "Dark Mode",
    Default = true,
    Callback = function(value)
        if value then
            Window:SetTheme("Dark")
        else
            Window:SetTheme("Light")
        end
    end
})

SettingsTab:AddSlider("UITransparency", {
    Title = "UI Transparency",
    Default = 0,
    Min = 0,
    Max = 100,
    Callback = function(value)
        Window.Frame.BackgroundTransparency = value/100
    end
})

SettingsTab:AddButton({
    Title = "Exit Admin Panel",
    Callback = function()
        Window:Destroy()
    end
})

Fluent:Notify({
    Title = "Admin Panel Loaded",
    Content = "Fast Admin panel has been loaded successfully!",
    Duration = 5
})
