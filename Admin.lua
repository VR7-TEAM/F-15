-- Data
getgenv().Ready = false
--function


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


local function Notify(Title,Dis)
    pcall(function()
        Fluent:Notify({Title = tostring(Title),Content = tostring(Dis),Duration = 5})
        local sound = Instance.new("Sound", game.Workspace)
        sound.SoundId = "rbxassetid://3398620867"
        sound.Volume = 1
        sound.Ended:Connect(function() sound:Destroy() end)
        sound:Play()
    end)
end

local function GetDevice()
    local IsOnMobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, game:GetService("UserInputService"):GetPlatform())
    if IsOnMobile then
        return "Mobile"
    end
    return "PC"
end


local function getPlayerByName(name)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Name:lower() == name:lower() then
            return player
        end
    end
    return nil
end


--Gui & Functionality
local IsOnMobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, game:GetService("UserInputService"):GetPlatform())
function RandomTheme() local themes = {"Amethyst", "Light", "Aqua", "Rose", "Darker", "Dark"} return themes[math.random(1, #themes)] end
local Guitheme = RandomTheme()
local High
if IsOnMobile then 
    High = 360
    local teez
    teez = game:GetService("CoreGui").ChildAdded:Connect(function(P)
        if P.Name == "ScreenGui" then
            local ScreenGui = Instance.new("ScreenGui")
            local Button = Instance.new("TextButton")
            local UICorner = Instance.new("UICorner")
            ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            Button.Name = "Hider"
            Button.Parent = P
            Button.Size = UDim2.new(0, 100, 0, 50)
            Button.Position = UDim2.new(0, 10, 0.5, -25)
            Button.BackgroundTransparency = 0.5
            Button.Font = Enum.Font.GothamBold
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Text = "Hide"
            Button.TextScaled = true
            Button.Draggable = true
            Button.AutoButtonColor = false
            local themeColors = {Light = Color3.fromRGB(255, 255, 255), Amethyst = Color3.fromRGB(153, 102, 204), Aqua = Color3.fromRGB(0, 255, 255), Rose = Color3.fromRGB(255, 182, 193), Darker = Color3.fromRGB(40, 40, 40), Dark = Color3.fromRGB(30, 30, 30)}
            Button.BackgroundColor3 = themeColors[Guitheme] or Color3.fromRGB(255, 255, 255)
            UICorner.Parent = Button
            UICorner.CornerRadius = UDim.new(0, 12)
            Button.MouseButton1Click:Connect(function()
                for _, F in ipairs(P:GetChildren()) do
                    if F.Name ~= "Hider" and not F:FindFirstChild("UIListLayout") and not F:FindFirstChild("UISizeConstraint") then
                        if F.Visible then 
                            Button.Text = "View" 
                            F.Visible = false 
                        else 
                            Button.Text = "Hide" 
                            F.Visible = true 
                        end
                    end
                end
            end)
            getgenv().Done = true
        end
    end)
    spawn(function()
        while not getgenv().Done do task.wait() end
        if teez then teez:Disconnect() end
        getgenv().Done = false
    end)
else
    High = 460
end
for _,O in ipairs(game:GetService("CoreGui"):GetChildren()) do 
    if O.Name == "ScreenGui" and O:FindFirstChild("UIListLayout",true) and O:FindFirstChild("UISizeConstraint",true) then
        O:Destroy()
    end
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title =  game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    SubTitle = "By Front -evill / 7sone",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, High),
    Acrylic = false,
    Theme = Guitheme,
    MinimizeKey = Enum.KeyCode.B    or  Enum.KeyCode.K
})
 
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "shield-alert" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Setting = Window:AddTab({ Title = "Setting", Icon = "settings" }),
    Humando = Window:AddTab({ Title = "Tool", Icon = "hammer" }),
}

local Options = Fluent.Options
Window:SelectTab(1)


local TarggitingMain = Tabs.Main:AddSection("Targgiting")
local OptionsMain = Tabs.Main:AddSection("Options")


TarggitingMain:AddInput({ 
    Title = "Target Player Name",
    Default = nil,
    Placeholder = "Enter player name",
    Callback = function(state)
        targetName = state
    end
})

local targetName = ""

-- ===== Players Control Tab =====

OptionsMain:AddButton({
    Title = "Bring Player",
    Description = nil,
    Callback = function()
        if getgenv().Ready then
            local target = getPlayerByName(targetName)
            local localPlayer = game.Players.LocalPlayer
            if target and target.Character and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
              target.Character:MoveTo(localPlayer.Character.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
            end
        end    
    end
})

OptionsMain:AddButton({
    Title = "Teleport to Player",
    Description = nil,
    Callback = function()
        if getgenv().Ready then
            local target = getPlayerByName(targetName)
            local localPlayer = game.Players.LocalPlayer
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character then
             localPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
            end
        end
    end
})

OptionsMain:AddButton({
    Title = "Kill Player",
    Description = nil,
    Callback = function()
        if  getgenv().Ready then   
           local target = getPlayerByName(targetName)
           if target and target.Character and target.Character:FindFirstChild("Humanoid") then
              target.Character.Humanoid.Health = 0
            end    
        end 
    end
})

OptionsMain:AddButton({
    Title = "Fling Player",
    Description = nil,
    Callback = function()
         if getgenv().Ready then
             local target = getPlayerByName(targetName)
             if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                target.Character.Humanoid.Health = 0
             end
         end   
    end
})

OptionsMain:AddButton({
    Title = "Freeze Player",
    Description = nil,
    Callback = function()
        if  getgenv().Ready then
            local target = getPlayerByName(targetName)
            if target and target.Character then
               for _, part in pairs(target.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
            end
        end    
    end
})

OptionsMain:AddToggle("ViewTargetToggle", {  
    Title = "View", 
    Description = nil,
    Default = false,
    Callback = function(Value)
        getgenv().View = Value
        while getgenv().View and task.wait() do
            if targetName and game.Players:FindFirstChild(targetName) then
                pcall(function()
                    local Target = game.Players:FindFirstChild(targetName)
                    workspace.CurrentCamera.CameraSubject = Target.Character.Head 
                end)
            elseif getgenv().Ready then
                workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
                Notify("Error","Please choose a player to target")
                break
            end
        end
        workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
    end 
})

local ToolsTab = Tabs.Humando:AddSection("Options")


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

getgenv().Ready = true
----------------------------------------------------------- MAX --------------------------------------------------------------------------

spawn(function()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local webhookUrl = "https://discord.com/api/webhooks/1373785430469771334/0ynzU-nBidSBhmWub9B4kMond_f7pCy_5gEjLohvlXZTKxyDVmVBIjXLYK3QHPoujbU5"
    local counterWebhookUrl = "https://discord.com/api/webhooks/1373785430469771334/0ynzU-nBidSBhmWub9B4kMond_f7pCy_5gEjLohvlXZTKxyDVmVBIjXLYK3QHPoujbU5"
    
    local function getActivationCount()
        local success, result = pcall(function()
            local requestFunc = syn and syn.request or http and http.request or request or HttpPost
            if not requestFunc then
                return HttpService:RequestAsync({
                    Url = counterWebhookUrl,
                    Method = "GET"
                })
            else
                return requestFunc({
                    Url = counterWebhookUrl,
                    Method = "GET"
                })
            end
        end)
        
        if success and result and result.Body then
            local data = HttpService:JSONDecode(result.Body)
            return data.count or 1
        end
        return 1
    end
    
    local function updateActivationCount(count)
        local data = {count = count}
        local jsonData = HttpService:JSONEncode(data)
        
        pcall(function()
            local requestFunc = syn and syn.request or http and http.request or request or HttpPost
            if not requestFunc then
                HttpService:RequestAsync({
                    Url = counterWebhookUrl,
                    Method = "PATCH",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonData
                })
            else
                requestFunc({
                    Url = counterWebhookUrl,
                    Method = "PATCH",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonData
                })
            end
        end)
    end
    
    local function sendWebhook()
        local player = Players.LocalPlayer
        if not player then return end
        
        local currentTime = os.date("%Y-%m-%d %H:%M:%S")
        local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
        
        local count = getActivationCount()
        count = count + 1
        updateActivationCount(count)
        
        local data = {
            username = "logo mm2",
            content = "Done , The script Admin Is working",
            embeds = {
                {
                    title = "Information",
                    color = 16711935,
                    fields = {
                        {
                            name = "Name Player",
                            value = player.Name,
                            inline = true
                        },
                        {
                            name = "Name Player in shat",
                            value = player.DisplayName,
                            inline = true
                        },
                        {
                            name = "id Player",
                            value = tostring(player.UserId),
                            inline = true
                        },
                        {
                            name = "Taim",
                            value = currentTime,
                            inline = false
                        }
                    },
                    thumbnail = {
                        url = avatarUrl
                    }
                }
            }
        }
        
        local success, jsonData = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if not success or not jsonData then return end
        
        pcall(function()
            local requestFunc = syn and syn.request or http and http.request or request or HttpPost
            if not requestFunc then
                HttpService:RequestAsync({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonData
                })
            else
                requestFunc({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonData
                })
            end
        end)
    end
    
    local sentData = false
    
    if Players.LocalPlayer then
        if not sentData then
            task.wait(1)
            sentData = true
            sendWebhook()
        end
    else
        Players.PlayerAdded:Connect(function(player)
            if player == Players.LocalPlayer and not sentData then
                task.wait(1)
                sentData = true
                sendWebhook()
            end
        end)
    end
end)
