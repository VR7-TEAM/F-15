-- تحميل مكتبة Fluent UI (تأكد من أن الرابط صحيح أو عدله حسب مصدر المكتبة)
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

-- دالة لجلب اللاعب بالاسم
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
                    part.Transparency = 0
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
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
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
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
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
                    spawn(function()
                        while noClipVal.Parent do
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
                    end)
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
        game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, chatEnabled)
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
        Window:AddInput({
            Title = "Enter Gravity Value",
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
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/admin " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Remove Admin from Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/deadmin " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "List All Players",
    Callback = function()
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/players", "All")
    end
})

AdminsTab:AddButton({
    Title = "Mute Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/mute " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Unmute Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/unmute " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Ban Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/ban " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Unban Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/unban " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Kick Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/kick " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Freeze Player (Admin)",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/freeze " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Unfreeze Player (Admin)",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/unfreeze " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Give Admin Rank",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/giverank " .. target.Name .. " admin", "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Remove Admin Rank",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/removerank " .. target.Name .. " admin", "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Promote Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/promote " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Demote Player",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/demote " .. target.Name, "All")
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
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/reset " .. target.Name, "All")
        end
    end
})

AdminsTab:AddButton({
    Title = "Shutdown Server",
    Callback = function()
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/shutdown", "All")
    end
})

AdminsTab:AddButton({
    Title = "Restart Server",
    Callback = function()
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/restart", "All")
    end
})

AdminsTab:AddButton({
    Title = "Set Player WalkSpeed",
    Callback = function()
        Window:AddInput({
            Title = "WalkSpeed Value",
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
        Window:AddInput({
            Title = "JumpPower Value",
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
        Window:AddInput({
            Title = "Announcement Text",
            Placeholder = "Type message here",
            Callback = function(value)
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/announce " .. value, "All")
            end
        })
    end
})

AdvancedTab:AddButton({
    Title = "Give Tool",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/give " .. target.Name .. " tool", "All")
        end
    end
})

AdvancedTab:AddButton({
    Title = "Remove Tool",
    Callback = function()
        local target = getPlayerByName(targetName)
        if target then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/removetool " .. target.Name, "All")
        end
    end
})

AdvancedTab:AddButton({
    Title = "Set Gravity",
    Callback = function()
        Window:AddInput({
            Title = "Gravity Value",
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
        Window:AddInput({
            Title = "Time (0-24)",
            Placeholder = "Enter time value",
            Callback = function(value)
                local time = tonumber(value)
                if time and time >= 0 and time <= 24 then
                    game.Lighting.TimeOfDay = tostring(time) .. ":00:00"
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

        local flying = true
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.Parent = character.HumanoidRootPart

        local UIS = game:GetService("UserInputService")

        UIS.InputBegan:Connect(function(input)
            if flying and input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W then
                    bodyVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * 50
                elseif input.KeyCode == Enum.KeyCode.S then
                    bodyVelocity.Velocity = -character.HumanoidRootPart.CFrame.LookVector * 50
                elseif input.KeyCode == Enum.KeyCode.A then
                    bodyVelocity.Velocity = -character.HumanoidRootPart.CFrame.RightVector * 50
                elseif input.KeyCode == Enum.KeyCode.D then
                    bodyVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * 50
                elseif input.KeyCode == Enum.KeyCode.Space then
                    bodyVelocity.Velocity = Vector3.new(0,50,0)
                elseif input.KeyCode == Enum.KeyCode.LeftControl then
                    bodyVelocity.Velocity = Vector3.new(0,-50,0)
                end
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if flying and input.UserInputType == Enum.UserInputType.Keyboard then
                bodyVelocity.Velocity = Vector3.new(0,0,0)
            end
        end)
    end
})

AdvancedTab:AddButton({
    Title = "Disable Fly",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, child in pairs(character.HumanoidRootPart:GetChildren()) do
                if child:IsA("BodyVelocity") then
                    child:Destroy()
                end
            end
        end
    end
})
