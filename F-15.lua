----------------------------------------------------------------------------------------------MAIN SCRIPT-----------------------------------------------------------------------------------
--Data
getgenv().AutoFarms = {Coins = false, Wins = false}
getgenv().Esp = {AllPlayers = false, Murder = false, Sheriff = false,Gun = false,Gems = false}
getgenv().TargetUserName = nil
getgenv().FlingMurder = false
getgenv().Ready = false

local version = 1.1
local Running = false
local TweenList = {}
local TeamsColor = {
	Murder = Vector3.new(255, 54, 54),
	Sheriff = Vector3.new(97, 207, 196),
	Innocent = Vector3.new(104, 255, 124),
	Died = Vector3.new(207, 209, 229)
}
local RaritesColor = {
    Godly = Vector3.new(255,0,179),
    Red = Vector3.new(220, 0, 5),
    Default = Vector3.new(106, 106, 106)
}
--Functions

local function Notify(Title,Dis)
    pcall(function()
        Fluent:Notify({Title = tostring(Title),Content = tostring(Dis),Duration = 5})
        local sound = Instance.new("Sound", game.Workspace) sound.SoundId = "rbxassetid://3398620867" sound.Volume = 1 sound.Ended:Connect(function() sound:Destroy() end) sound:Play()
    end)
end


local selectedPart = nil
local selectionBox = Instance.new("SelectionBox")
selectionBox.LineThickness = 0.05
selectionBox.Color3 = Color3.fromRGB(0, 170, 255)
selectionBox.Parent = game.Workspace

function enableSelection()
    selectionConnection = game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local target = mouse.Target
            
            if target and target:IsA("BasePart") then
                selectedPart = target
                selectionBox.Adornee = selectedPart
                print("YOU NOW SELCTER THE : " .. target.Name)
            end
        end
    end)
end

function disableSelection()
    if selectionConnection then
        selectionConnection:Disconnect()
        selectionConnection = nil
    end
    selectionBox.Adornee = nil
    selectedPart = nil
end

function CopyPartCode(part)
    local code = generatePartCode(part)
    setclipboard(code) 
end

function generatePartCode(part)
    local code = string.format([[
local part = Instance.new("Part")
part.Name = "%s"
part.Position = Vector3.new(%s, %s, %s)
part.Size = Vector3.new(%s, %s, %s)
part.Anchored = %s
part.CanCollide = %s
part.BrickColor = BrickColor.new("%s")
part.Parent = workspace
]], 
    part.Name,
    tostring(part.Position.X), tostring(part.Position.Y), tostring(part.Position.Z),
    tostring(part.Size.X), tostring(part.Size.Y), tostring(part.Size.Z),
    tostring(part.Anchored), tostring(part.CanCollide),
    tostring(part.BrickColor.Name))
    
    return code
end

function DeletePart(part)
    if part and part.Parent then
        part:Destroy()
    end
end


local function GetTeamOf(Target)
	local Player
	if typeof(Target) == "string" then
		Player = game.Players:FindFirstChild(Target)
	elseif typeof(Target) == "Instance" then
		Player = Target
	end
    if Player then
        local Backpack = Player:FindFirstChild("Backpack")
        if Player.Character and Player.Character:FindFirstChild("Stab",true) then
            return "Murder"
        elseif Player.Character and Player.Character:FindFirstChild("IsGun",true) then
            return "Sheriff"
        end
        if Backpack and Backpack:FindFirstChild("Stab",true) then
            return "Murder"
        elseif Backpack and Backpack:FindFirstChild("IsGun",true) then
            return "Sheriff"
        elseif Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("Humanoid").NameDisplayDistance ~= 0 then
            return "Died"
        else
            return "Innocent"
        end
    end
    return false
end

local function GetUserPic(UserId)
    local Data = game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar?userIds="..UserId.."&size=420x420&format=Png&isCircular=false")
    return Data:match('"imageUrl"%s*:%s*"([^"]+)"')
end

local function CheckHWID()
    local jasbddajsdwjs = {"57D3220E-B408-47A3-95B4-4B8063EC7EAD","d5856005-51ea-496b-8e03-74ee7f287942"," "}
    for _,P in ipairs(jasbddajsdwjs) do 
        if game:GetService("RbxAnalyticsService"):GetClientId() == P then
            return {Value = true,ID = P}
        end
    end
    return {Value = false,ID = nil}
end

local function GetDevice()
    local IsOnMobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, game:GetService("UserInputService"):GetPlatform())
    if IsOnMobile then
        return "Mobile"
    end
    return "PC"
end

local function GetPlayer(UserDisplay)
	if UserDisplay ~= "" then
        local Value = UserDisplay:match("^%s*(.-)%s*$")
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                local PlayerName = player.Name:lower():match("^%s*(.-)%s*$")
                local DisplayName = player.DisplayName:lower():match("^%s*(.-)%s*$") 
                if PlayerName:sub(1, #Value) == Value:lower() or DisplayName:sub(1, #Value) == Value:lower() then
                    return player
                end
            end
        end
    end
    return nil
end

local function CheckCharacter(Tagert)
    getgenv().ass = Tagert
    local success,error = pcall(function()
        getgenv().ass.Character.Humanoid.Health = tonumber(getgenv().ass.Character.Humanoid.Health)
    end)
    if success then return true else return false end
end

local function GetNearestCoin()
	local CoinContainer = workspace:FindFirstChild("CoinContainer", true)
    if not CoinContainer then return nil end
    local NearestCoin, NearestDistance = nil, math.huge

    for _, Coin in ipairs(CoinContainer:GetChildren()) do
        if Coin:IsA("BasePart") and Coin:FindFirstChild("TouchInterest",true) then
            local Distance = (Coin.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if Distance < NearestDistance then
                NearestCoin, NearestDistance = Coin, Distance
            end
        end
    end

    return NearestCoin
end

local function TweenTo(Part)
    if Running then return end
    Running = true
    local Tween = game:GetService("TweenService"):Create(
        game.Players.LocalPlayer.Character.HumanoidRootPart,
        TweenInfo.new((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Part.Position).Magnitude / 27, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(Part.Position) * CFrame.Angles(0, game.Players.LocalPlayer.Character.HumanoidRootPart.Orientation.Y, 0)}
    )
    table.insert(TweenList, Tween)
    Tween.Completed:Connect(function()
        Running = false
    end)
    Tween:Play()
    return Tween
end

local function StopAllTweens()
    for _, Tween in ipairs(TweenList) do
        Tween:Cancel()
    end
    TweenList = {}
    Running = false
end 

local function Chat(text)
isLegacyChat = game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.LegacyChatService
    if not isLegacyChat then
        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(tostring(text))
    else
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tostring(text), "All")
    end
end

local function CreateEsp(Target)
    local Character = Target.Character
    local NameTag = Character:FindFirstChild("NameTag")
    local TeamColor = TeamsColor[GetTeamOf(Target)]

    local Esp = Character:FindFirstChild("ESP")
    if Esp then
        Esp.FillColor = Color3.fromRGB(TeamColor.X, TeamColor.Y, TeamColor.Z)
    else
        Esp = Instance.new("Highlight")
        Esp.Name = "ESP"
        Esp.OutlineColor = Color3.fromRGB(0, 0, 0)
        Esp.FillColor = Color3.fromRGB(TeamColor.X, TeamColor.Y, TeamColor.Z)
        Esp.Parent = Target.Character
    end
    
    if GetTeamOf(Target) ~= "Died" then
        if NameTag then
            local Label = NameTag:FindFirstChild("TextLabel")
            if Label then
                Label.TextColor3 = Color3.fromRGB(TeamColor.X, TeamColor.Y, TeamColor.Z)
            end
        else
            NameTag = Instance.new("BillboardGui")
            NameTag.Name = "NameTag"
            NameTag.Size = UDim2.new(0, 90, 0, 25)
            NameTag.Adornee = Character:FindFirstChild("Head")
            NameTag.AlwaysOnTop = true
            NameTag.Parent = Character
            NameTag.StudsOffset = Vector3.new(0, 2.5, 0) 

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0) 
            Label.Text = Target.Name
            Label.TextColor3 = Color3.fromRGB(TeamColor.X, TeamColor.Y, TeamColor.Z)
            Label.BackgroundTransparency = 1
            Label.TextSize = 12 
            Label.TextStrokeTransparency = 0  
            Label.Parent = NameTag
        end
    end
end

local function StopEsp(Target)
    local Esp = Target.Character:FindFirstChild("ESP")
    local NameTag = Target.Character:FindFirstChild("NameTag")
    if Esp then
        Esp:Destroy()
    end
    if NameTag then
        NameTag:Destroy()
    end
end

local function MurderKill(Target) 
	if GetTeamOf(game.Players.LocalPlayer) == "Murder" then
		if not game.Players.LocalPlayer.Character:FindFirstChild("Knife") then 
			game.Players.LocalPlayer.Character.Humanoid:EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild("Knife"))
		end
		for _,P in ipairs(game.Players:GetPlayers()) do
			if P == Target then
                pcall(function()
                    Target.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)
                    game.Players.LocalPlayer.Character:FindFirstChild("Stab",true):FireServer(Target.Name)
                end)
			end
		end
	end
end 

local function GetMurder()
	for _,P in ipairs(game.Players:GetPlayers()) do 
		if GetTeamOf(P) == "Murder" then
			return P
		end 
	end	
	return nil
end

local function GetSheriff()
	for _,P in ipairs(game.Players:GetPlayers()) do 
		if GetTeamOf(P) == "Sheriff" then
			return P
		end 
	end	
	return nil
end

local function SendTrade(Plr)
	return game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("SendRequest"):InvokeServer(game.Players:FindFirstChild(Plr))
end

local function CancelTrade()
	game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("CancelRequest"):FireServer()
end

local function RemoveSpaces(Str)
    return Str:gsub("%s+", "")
end

local function OfferItem(Type,Name)
    game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("OfferItem"):FireServer(Name,Type)
end

local function AcceptTrade()
    game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("AcceptTrade"):FireServer(285646582)
end

--Gui & Functionality
local IsOnMobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, game:GetService("UserInputService"):GetPlatform())
function RandomTheme() local themes = {"Amethyst", "Light", "Aqua", "Rose", "Darker", "Dark"} return themes[math.random(1, #themes)] end
local Guitheme = RandomTheme()
if IsOnMobile then High = 360
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
					Button.Text = "View" F.Visible = false 
					else 
					Button.Text = "Hide" F.Visible = true 
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
    MinimizeKey = Enum.KeyCode.B
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "shield-alert" }),
    Targetting = Window:AddTab({ Title = "Targetting", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "http://www.roblox.com/asset/?id=6034767608"}),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Setting = Window:AddTab({ Title = "Setting", Icon = "settings" }),
    Scin = Window:AddTab({ Title = "Scin Player", Icon = "user" }),
    Humando = Window:AddTab({ Title = "Admin", Icon = "hammer" }),
}

local Options = Fluent.Options
Window:SelectTab(1)

local FlyScript = Tabs.Main:AddSection("Fly Script (Gui 3)")
local AutofarmMain = Tabs.Main:AddSection("Auto Farms")
local AutoMurderMain = Tabs.Main:AddSection("Auto Murder")
local TrollingMain = Tabs.Main:AddSection("Trolling")

FlyScript:AddButton({
    Title = "Fly Script",
    Description = "Clic here for give script fly (Gui3) !!!",
    Callback = function(state)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Front-Evill/Script-Hub/refs/heads/main/Fly.lua.txt"))()
    end
})

AutofarmMain:AddToggle("AutoCoinsToggle",{
    Title = "AutoCoins", 
    Description = nil,
    Default = false,
    Callback = function(state)
        getgenv().AutoFarms.Coins = state
        while getgenv().AutoFarms.Coins do task.wait()
            pcall(function()
            local Coin = GetNearestCoin()
                if GetTeamOf(game.Players.LocalPlayer) ~= "Died" and Coin and Coin:FindFirstChild("CoinVisual",true) and Coin:FindFirstChild("TouchInterest",true) and Coin:FindFirstChild("CoinVisual",true).Transparency == 1 then 
                    TweenTo(Coin)
                    firetouchinterest(Coin,game.Players.LocalPlayer.Character.HumanoidRootPart,0) 
                    firetouchinterest(Coin,game.Players.LocalPlayer.Character.HumanoidRootPart,1) 
                else
                    StopAllTweens()
                end
            end)
        end
        if not getgenv().AutoFarms.Coins then
            StopAllTweens()
        end
    end 
})

AutofarmMain:AddToggle("AutoCoinsToggle",{
    Title = "AutoFling", 
    Description = nil,
    Default = false,
    Callback = function(state)
        getgenv().AutoFarms.Wins = state
		getgenv().FlingMurder = state
        if state then Notify("Note","This option looks like an auto win option just leave it alone and the murder gonna be flinged in each match.\nMurder knife must be unequipped") end
        while getgenv().AutoFarms.Wins do task.wait()
            pcall(function()
                if GetTeamOf(game.Players.LocalPlayer) ~= "Murder" and GetMurder() and CheckCharacter(GetMurder()) and GetMurder().Character.Humanoid.RootPart.Velocity.Magnitude < 500 and GetMurder().Backpack:FindFirstChild("Knife") then
                    getgenv().MurderUserName = GetMurder().Name
                    getgenv().FlingMurder = true
                    if getgenv().FlingMurder then
                        if not getgenv().MurderUserName then return end
                        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Humanoid and game.Players.LocalPlayer.Character.Humanoid.RootPart then
                            if game.Players.LocalPlayer.Character.Humanoid.RootPart.Velocity.Magnitude < 50 then
                                getgenv().OldPos = game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame
                            end
                            if game.Players[getgenv().MurderUserName].Character.Head then
                                workspace.CurrentCamera.CameraSubject = game.Players[getgenv().MurderUserName].Character.Head
                            elseif game.Players[getgenv().MurderUserName].Character:FindFirstChildOfClass("Accessory"):FindFirstChild("Handle") then
                                workspace.CurrentCamera.CameraSubject = game.Players[getgenv().MurderUserName].Character:FindFirstChildOfClass("Accessory"):FindFirstChild("Handle")
                            else
                                workspace.CurrentCamera.CameraSubject = game.Players[getgenv().MurderUserName].Character.Humanoid
                            end
                            if not game.Players[getgenv().MurderUserName].Character:FindFirstChildWhichIsA("BasePart") then
                                return
                            end
                            
                            local function FPos(BasePart, Pos, Ang)
                                game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                                game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                                game.Players.LocalPlayer.Character.Humanoid.RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                                game.Players.LocalPlayer.Character.Humanoid.RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                            end
                            
                            local function SFBasePart()
                                local Angle = 0
                                getgenv().FPDH = workspace.FallenPartsDestroyHeight
                                workspace.FallenPartsDestroyHeight = 0/0
                                repeat
                                    task.wait()
                                    pcall(function()
                                        if game.Players.LocalPlayer.Character.Humanoid.RootPart and game.Players[getgenv().MurderUserName].Character.Humanoid then
                                            if game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart.Velocity.Magnitude < 50 then
                                                Angle = Angle + 100
                                                for _, Offset in ipairs({
                                                    Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0),
                                                    Vector3.new(2.25, 1.5, -2.25), Vector3.new(-2.25, -1.5, 2.25),
                                                    Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0)
                                                }) do
                                                    FPos(game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart, CFrame.new(Offset) + game.Players[getgenv().MurderUserName].Character.Humanoid.MoveDirection * (game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(Angle), 0, 0))
                                                    task.wait()
                                                end
                                            else
                                                for _, Data in ipairs({
                                                    {Vector3.new(0, 1.5, game.Players[getgenv().MurderUserName].Character.Humanoid.WalkSpeed), math.rad(90)},
                                                    {Vector3.new(0, -1.5, -game.Players[getgenv().MurderUserName].Character.Humanoid.WalkSpeed), 0},
                                                    {Vector3.new(0, 1.5, game.Players[getgenv().MurderUserName].Character.Humanoid.WalkSpeed), math.rad(90)},
                                                    {Vector3.new(0, 1.5, game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), math.rad(90)},
                                                    {Vector3.new(0, -1.5, -game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), 0},
                                                    {Vector3.new(0, 1.5, game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), math.rad(90)},
                                                    {Vector3.new(0, -1.5, 0), math.rad(90)},
                                                    {Vector3.new(0, -1.5, 0), 0},
                                                    {Vector3.new(0, -1.5, 0), math.rad(-90)},
                                                    {Vector3.new(0, -1.5, 0), 0}
                                                }) do
                                                    FPos(game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart, CFrame.new(Data[1]), CFrame.Angles(Data[2], 0, 0))
                                                    task.wait()
                                                end                        
                                            end
                                            game.Players.LocalPlayer.Character.Humanoid.Sit = false
                                            if game.Players[getgenv().MurderUserName].Character:FindFirstChild("Head") then
                                                workspace.CurrentCamera.CameraSubject = game.Players[getgenv().MurderUserName].Character.Head
                                            end
                                        end
                                    end)
                                    if not GetMurder() then
                                        getgenv().FlingMurder = false
                                        break
                                    end
                                until not getgenv().FlingMurder or not GetMurder().Backpack:FindFirstChild("Knife") or CheckCharacter(GetMurder()) and GetMurder().Character.Humanoid.RootPart.Velocity.Magnitude > 500 or game.Players[getgenv().MurderUserName].Character.Humanoid.RootPart.Parent ~= GetMurder().Character or GetMurder().Parent ~= game.Players or GetMurder().Character.Humanoid.Sit or GetMurder().Character.Humanoid.Health <= 0 
                                getgenv().FlingMurder = false
                            end
                            
                            local BV = Instance.new("BodyVelocity")
                            BV.Name = "Flinger"
                            BV.Parent = game.Players.LocalPlayer.Character.Humanoid.RootPart
                            BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
                            BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

                            game.Players.LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                        
                            SFBasePart()

                            BV:Destroy()
                            game.Players.LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                            workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
                            
                            repeat
                                game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                                game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                                game.Players.LocalPlayer.Character.Humanoid:ChangeState("GettingUp")
                                table.foreach(game.Players.LocalPlayer.Character:GetChildren(), function(_, x)
                                    if x:IsA("BasePart") then
                                        x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                                    end
                                end)
                                task.wait()
                            until (game.Players.LocalPlayer.Character.Humanoid.RootPart.Position - getgenv().OldPos.p).Magnitude < 25
                            workspace.FallenPartsDestroyHeight = getgenv().FPDH
                            if game.Players.LocalPlayer.Character.Humanoid.Sit then
                                wait(1)
                                game.Players.LocalPlayer.Character.Humanoid.sit = false
                            end
                        end
                    end
                else
                    getgenv().FlingMurder = false
                    workspace.FallenPartsDestroyHeight = getgenv().FPDH
                end 
            end)
        end
    end 
})

AutofarmMain:AddToggle("AutoCoinsToggle",{
    Title = "AutoGun", 
    Description = "Immediately take gun when dropped.",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarms.Gun = state
        while getgenv().AutoFarms.Gun do task.wait()
            if GetTeamOf(game.Players.LocalPlayer) ~= "Died" then
                local Dropgun = workspace:FindFirstChild("GunDrop",true)
                if Dropgun then
                    local Oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    wait()
                    repeat task.wait()
                        pcall(function()
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Dropgun.Position + Vector3.new(0, -4, 0)) * CFrame.Angles(math.rad(90), 0, 0)
                        firetouchinterest(Dropgun,game.Players.LocalPlayer.Character.HumanoidRootPart,0)
                        firetouchinterest(Dropgun,game.Players.LocalPlayer.Character.HumanoidRootPart,1)
                        end)
                    until not Dropgun or not getgenv().AutoFarms.Gun or game.Players.LocalPlayer.Character:FindFirstChild("Gun") or game.Players.LocalPlayer.Backpack:FindFirstChild("Gun")
                    wait()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Oldpos
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("GettingUp")
                end
            end
        end
    end 
})

AutoMurderMain:AddButton({
    Title = "Kill All",
    Description = nil,
    Callback = function()
        if GetTeamOf(game.Players.LocalPlayer) == "Murder" then
            local t = 0 
            repeat wait()
            for _,P in ipairs(game.Players:GetPlayers()) do 
                if GetTeamOf(P) ~= "Died" then
                    MurderKill(P)
                end
            end
            t += 1
            until t >= 20
        else
        Notify("Error","You must be a murder")
        end
    end
})

AutoMurderMain:AddButton({
    Title = "Kill Sheriff",
    Description = nil,
    Callback = function()
        if GetTeamOf(game.Players.LocalPlayer) == "Murder" then
            local t = 0 
            repeat wait()
            for _,P in ipairs(game.Players:GetPlayers()) do 
                if GetTeamOf(P) == "Sheriff" then
                    MurderKill(P)
                end
            end
            t += 1
            until t >= 20
        else
        Notify("Error","You must be a murder")
        end
    end
})

TrollingMain:AddButton({
    Title = "Say Sheriff & Killer",
    Description = nil,
    Callback = function()
        if GetMurder() then
            Chat("|Murder: "..GetMurder().Name)
        end
        wait()
        if GetSheriff() then
            Chat("|Sheriff: "..GetSheriff().Name)
        end
    end
})

TrollingMain:AddButton({
    Title = "Fling all",
    Description = nil,
    Callback = function()
        Window:Dialog({
            Title = "Warning",
            Content = "Using this option may break the game teleport for you.\nDo you want to continue?",
            Buttons = {
                { 
                    Title = "Confirm",
                    Callback = function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hm5011/hussain/refs/heads/main/UnForbidden%20Fling"))()
                    end 
                }, {
                    Title = "Cancel",
                    Callback = function()
                        return nil
                    end 
                }
            }
        })
    end
})


TrollingMain:AddToggle({
    Title = "Safe Place", 
    Description = "Creates a safe platform far away and teleports you there",
    Default = false,
    Callback = function(state) 
            local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        local oldPosition = HumanoidRootPart.Position
        local safePlatform = nil
        
        if state then
             safePlatform = Instance.new("Part")
             safePlatform.Name = "SafePlatform"
             safePlatform.Size = Vector3.new(100, 5, 100)
             safePlatform.Position = Vector3.new(9999, 9999, 9999)
             safePlatform.Anchored = true
             safePlatform.CanCollide = true
             safePlatform.BrickColor = BrickColor.new("Black")
             safePlatform.Material = Enum.Material.SmoothPlastic
            
             local surfaceGui = Instance.new("SurfaceGui")
             surfaceGui.Face = Enum.NormalId.Top
             surfaceGui.Parent = safePlatform
            
             local textLabel = Instance.new("TextLabel")
             textLabel.Size = UDim2.new(1, 0, 1, 0)
             textLabel.BackgroundTransparency = 1
             textLabel.TextColor3 = Color3.new(1, 0, 0)
             textLabel.Text = "FRONT Evill"
             textLabel.TextSize = 48
             textLabel.Font = Enum.Font.SourceSansBold
             textLabel.Parent = surfaceGui
            
             safePlatform.Parent = workspace
             _G.SafePlatform = safePlatform
             wait(0.1)
             HumanoidRootPart.CFrame = CFrame.new(safePlatform.Position + Vector3.new(0, 10, 0))
            else
               safePlatform = _G.SafePlatform
              if oldPosition then
                  HumanoidRootPart.CFrame = CFrame.new(oldPosition)
              end
             if safePlatform then
                 safePlatform:Destroy()
                 _G.SafePlatform = nil
             end
         end
     end 
})

local PlayerNameTargetting = Tabs.Targetting:AddSection("Target")
local OptionsTargetting = Tabs.Targetting:AddSection("Options")

local TargetInput = PlayerNameTargetting:AddInput("Input", {
    Title = "Player Name",
    Description = nil,
    Default = nil,
    Placeholder = "Name Here",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
		if getgenv().Ready then 
			local TargetName = GetPlayer(Value)
			if TargetName then
				Notify("Successed","The Player @"..TargetName.Name.." has been chosen!")
				getgenv().TargetUserName = TargetName.Name
			else
				Notify("Error","Unknown Player")
				getgenv().TargetUserName = nil
			end
		end
    end
})

game.Players.PlayerRemoving:Connect(function(Player)
	pcall(function()
		if Player.Name == getgenv().TargetUserName then
			getgenv().TargetUserName = nil
            Options.FlingTargetToggle:SetValue(false)
			Notify("Error","Target left or rejoined")
		end
	end)
end)

PlayerNameTargetting:AddButton({
    Title = "Choose Player Tool",
    Description = "Click on a player to select him",
    Callback = function()
		for _,P in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if P.Name == "ClickTarget" then P:Destroy() end end
		for _,P in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do if P.Name == "ClickTarget" then P:Destroy() end end
		local GetTargetTool = Instance.new("Tool")
		GetTargetTool.Name = "ClickTarget"
		GetTargetTool.RequiresHandle = false
		GetTargetTool.TextureId = "rbxassetid://13769558274"
		GetTargetTool.ToolTip = "Choose Player"

		local function ActivateTool()
			local Hit = game.Players.LocalPlayer:GetMouse().Target
			local Person = nil
			if Hit and Hit.Parent then
				if Hit.Parent:IsA("Model") then
					Person = game.Players:GetPlayerFromCharacter(Hit.Parent)
				elseif Hit.Parent:IsA("Accessory") then
					Person = game.Players:GetPlayerFromCharacter(Hit.Parent.Parent)
				end
				if Person then
					TargetInput:SetValue(Person.Name)
				end
			end
		end

		GetTargetTool.Activated:Connect(function()
			ActivateTool()
		end)
		GetTargetTool.Parent = game.Players.LocalPlayer.Backpack
    end
})

OptionsTargetting:AddButton({
    Title = "Get Information",
    Description = nil,
    Callback = function()
		if getgenv().Ready and getgenv().TargetUserName and game.Players:FindFirstChild(getgenv().TargetUserName) then
			local Target = game.Players:FindFirstChild(getgenv().TargetUserName)
			Notify("@".. Target.Name .. " Info↓","Account Age: ".. tostring(Target.AccountAge) .."\nLevel: ".. tostring(game.Players.LocalPlayer:GetAttribute("Level")) .."\nTeam: ".. tostring(GetTeamOf(Target)))
		elseif getgenv().Ready then
			Notify("Error","Please choose a player to target")
		end
    end
})

OptionsTargetting:AddButton({
    Title = "Say Team",
    Description = nil,
    Callback = function()
		if getgenv().Ready and getgenv().TargetUserName and game.Players:FindFirstChild(getgenv().TargetUserName) then
			local Target = game.Players:FindFirstChild(getgenv().TargetUserName)
            Chat(getgenv().TargetUserName.." is a "..GetTeamOf(getgenv().TargetUserName))
            elseif getgenv().Ready then
			Notify("Error","Please choose a player to target")
		end
    end
})

OptionsTargetting:AddButton({
    Title = "Teleport To",
    Description = nil,
    Callback = function()
		if getgenv().Ready and getgenv().TargetUserName and game.Players:FindFirstChild(getgenv().TargetUserName) then
			local Target = game.Players:FindFirstChild(getgenv().TargetUserName)
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2) * CFrame.Angles(0,math.rad(180),0)
		elseif getgenv().Ready then
			Notify("Error","Please choose a player to target")
		end
    end
})

OptionsTargetting:AddButton({
    Title = "Kill",
    Description = nil,
    Callback = function()
		if getgenv().Ready and getgenv().TargetUserName and game.Players:FindFirstChild(getgenv().TargetUserName) then
			local Target = game.Players:FindFirstChild(getgenv().TargetUserName)
			if GetTeamOf(game.Players.LocalPlayer) == "Murder" then
                local t = 0 
                repeat wait()
                for _,P in ipairs(game.Players:GetPlayers()) do 
                    if P == Target then
                        MurderKill(P)
                    end
                end
                t += 1
                until t >= 20
            else
            Notify("Error","You must be a murder")
            end
		elseif getgenv().Ready then
			Notify("Error","Please choose a player to target")
		end
    end
})

OptionsTargetting:AddToggle("ViewTargetToggle", {
    Title = "View", 
    Description = nil,
    Default = false,
    Callback = function(Value)
		getgenv().View = Value
        while getgenv().View and task.wait() do
            if getgenv().TargetUserName and game.Players:FindFirstChild(getgenv().TargetUserName) then
				pcall(function()
					local Target = game.Players:FindFirstChild(getgenv().TargetUserName)
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

OptionsTargetting:AddToggle("FlingTargetToggle", {
    Title = "Fling", 
    Description = nil,
    Default = false,
    Callback = function(Value)
		getgenv().FlingTarget = Value
        if getgenv().FlingTarget then
            if not getgenv().TargetUserName then  Notify("Error","Please choose a player to target") return end
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Humanoid and game.Players.LocalPlayer.Character.Humanoid.RootPart then
				if game.Players.LocalPlayer.Character.Humanoid.RootPart.Velocity.Magnitude < 50 then
					getgenv().OldPos = game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame
				end
				if game.Players[getgenv().TargetUserName].Character.Head then
					workspace.CurrentCamera.CameraSubject = game.Players[getgenv().TargetUserName].Character.Head
				elseif game.Players[getgenv().TargetUserName].Character:FindFirstChildOfClass("Accessory"):FindFirstChild("Handle") then
					workspace.CurrentCamera.CameraSubject = game.Players[getgenv().TargetUserName].Character:FindFirstChildOfClass("Accessory"):FindFirstChild("Handle")
				else
					workspace.CurrentCamera.CameraSubject = game.Players[getgenv().TargetUserName].Character.Humanoid
				end
				if not game.Players[getgenv().TargetUserName].Character:FindFirstChildWhichIsA("BasePart") then
					return
				end
				
				local function FPos(BasePart, Pos, Ang)
					game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
					game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
					game.Players.LocalPlayer.Character.Humanoid.RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
					game.Players.LocalPlayer.Character.Humanoid.RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
				end
				
				local function SFBasePart()
					local Angle = 0
					getgenv().FPDH = workspace.FallenPartsDestroyHeight
					workspace.FallenPartsDestroyHeight = 0/0
					repeat
						task.wait()
						pcall(function()
							if game.Players.LocalPlayer.Character.Humanoid.RootPart and game.Players[getgenv().TargetUserName].Character.Humanoid then
								if game.Players[getgenv().TargetUserName].Character.Humanoid.RootPart.Velocity.Magnitude < 50 then
									Angle = Angle + 100
									for _, Offset in ipairs({
										Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0),
										Vector3.new(2.25, 1.5, -2.25), Vector3.new(-2.25, -1.5, 2.25),
										Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0)
									}) do
										FPos(game.Players[getgenv().TargetUserName].Character.Humanoid.RootPart, CFrame.new(Offset) + game.Players[getgenv().TargetUserName].Character.Humanoid.MoveDirection * (game.Players[getgenv().TargetUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(Angle), 0, 0))
										task.wait()
									end
								else
									for _, Data in ipairs({
										{Vector3.new(0, 1.5, game.Players[getgenv().TargetUserName].Character.Humanoid.WalkSpeed), math.rad(90)},
										{Vector3.new(0, -1.5, -game.Players[getgenv().TargetUserName].Character.Humanoid.WalkSpeed), 0},
										{Vector3.new(0, 1.5, game.Players[getgenv().TargetUserName].Character.Humanoid.WalkSpeed), math.rad(90)},
										{Vector3.new(0, 1.5, game.Players[getgenv().TargetUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), math.rad(90)},
										{Vector3.new(0, -1.5, -game.Players[getgenv().TargetUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), 0},
										{Vector3.new(0, 1.5, game.Players[getgenv().TargetUserName].Character.Humanoid.RootPart.Velocity.Magnitude / 1.25), math.rad(90)},
										{Vector3.new(0, -1.5, 0), math.rad(90)},
										{Vector3.new(0, -1.5, 0), 0},
										{Vector3.new(0, -1.5, 0), math.rad(-90)},
										{Vector3.new(0, -1.5, 0), 0}
									}) do
										FPos(game.Players[getgenv().TargetUserName].Character.Humanoid.RootPart, CFrame.new(Data[1]), CFrame.Angles(Data[2], 0, 0))
										task.wait()
									end                        
								end
								game.Players.LocalPlayer.Character.Humanoid.Sit = false
								if game.Players[getgenv().TargetUserName].Character:FindFirstChild("Head") then
									workspace.CurrentCamera.CameraSubject = game.Players[getgenv().TargetUserName].Character.Head
								end
							end
						end)
					until not getgenv().FlingTarget 
				end
				
				local BV = Instance.new("BodyVelocity")
				BV.Name = "Flinger"
				BV.Parent = game.Players.LocalPlayer.Character.Humanoid.RootPart
				BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
				BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

				game.Players.LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			
				SFBasePart()

				BV:Destroy()
				game.Players.LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
				workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
				
				repeat
					game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
					game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
					game.Players.LocalPlayer.Character.Humanoid:ChangeState("GettingUp")
					table.foreach(game.Players.LocalPlayer.Character:GetChildren(), function(_, x)
						if x:IsA("BasePart") then
							x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
						end
					end)
					task.wait()
				until (game.Players.LocalPlayer.Character.Humanoid.RootPart.Position - getgenv().OldPos.p).Magnitude < 25
				workspace.FallenPartsDestroyHeight = getgenv().FPDH
				if game.Players.LocalPlayer.Character.Humanoid.Sit then
					wait(1)
					game.Players.LocalPlayer.Character.Humanoid.sit = false
				end
			end
		end
    end 
})

local PlayersEspVisuals = Tabs.Visuals:AddSection("Players Esp")
local EntitiesEspVisuals = Tabs.Visuals:AddSection("Entities Esp")

PlayersEspVisuals:AddToggle("AllPlayersEspToggle", {
    Title = "All Players Esp", 
    Description = nil,
    Default = false,
    Callback = function(state)
        getgenv().Esp.AllPlayers = state
        if getgenv().Esp.AllPlayers then
            Options.MurderEspToggle:SetValue(false)
            Options.SheriffEspToggle:SetValue(false)
            while getgenv().Esp.AllPlayers do 
                for _,P in ipairs(game.Players:GetPlayers()) do 
                    if P ~= game.Players.LocalPlayer then
                        pcall(function()
                            CreateEsp(P)
                        end)
                    end
                end
                wait(0.6)
            end
            wait(0.1)
            for _,P in ipairs(game.Players:GetPlayers()) do
                pcall(function() 
                    StopEsp(P)
                end)
            end
        end
    end 
})

PlayersEspVisuals:AddToggle("MurderEspToggle", {
    Title = "Murder Esp", 
    Description = nil,
    Default = false,
    Callback = function(state)
        getgenv().Esp.Murder = state
        if getgenv().Esp.Murder then
            Options.AllPlayersEspToggle:SetValue(false)
            while getgenv().Esp.Murder do 
                for _,P in ipairs(game.Players:GetPlayers()) do 
                    if P ~= game.Players.LocalPlayer and GetTeamOf(P) == "Murder" then
                        pcall(function()
                            CreateEsp(P)
                        end)
                    end
                end
                wait(0.6)
            end
            wait(0.1)
            for _,P in ipairs(game.Players:GetPlayers()) do
                if GetTeamOf(P) == "Murder" then 
                    pcall(function() 
                        StopEsp(P)
                    end)
                end
            end
        end
    end 
})

PlayersEspVisuals:AddToggle("SheriffEspToggle", {
    Title = "Sheriff Esp", 
    Description = nil, 
    Default = false,
    Callback = function(state)
        getgenv().Esp.Sheriff = state
        if getgenv().Esp.Sheriff then
            Options.AllPlayersEspToggle:SetValue(false)
            while getgenv().Esp.Sheriff do 
                for _,P in ipairs(game.Players:GetPlayers()) do 
                    if P ~= game.Players.LocalPlayer and GetTeamOf(P) == "Sheriff" then
                        pcall(function()
                            CreateEsp(P)
                        end)
                    end
                end
                wait(0.6)
            end
            wait(0.1)
            for _,P in ipairs(game.Players:GetPlayers()) do
                if GetTeamOf(P) == "Sheriff" then 
                    pcall(function() 
                        StopEsp(P)
                    end)
                end
            end
        end
    end 
})

EntitiesEspVisuals:AddToggle("GunEspToggle", {
    Title = "Gun Esp", 
    Description = nil,
    Default = false,
    Callback = function(state)
        getgenv().Esp.Gun = state
        if getgenv().Esp.Gun then
            while getgenv().Esp.Gun do task.wait()
                local Dropgun = workspace:FindFirstChild("GunDrop",true)
                local Billboard
                if Dropgun then
                    if not Dropgun:FindFirstChild("ESP") then
                        while getgenv().Esp.Gun do 
                            task.wait()
                            local Dropgun = workspace:FindFirstChild("GunDrop", true)
                            if Dropgun then
                                if not Dropgun:FindFirstChild("ESP") then
									local Billboard = Instance.new("BillboardGui", Dropgun)
									Billboard.Name = "ESP"
									Billboard.Size = UDim2.new(0, 200, 0, 100) 
									Billboard.Adornee = Dropgun
									Billboard.StudsOffset = Vector3.new(0, 3, 0) 
									Billboard.AlwaysOnTop = true
								
									local TextLabel = Instance.new("TextLabel", Billboard)
									TextLabel.Size = UDim2.new(1, 0, 1, 0)
									TextLabel.BackgroundTransparency = 1
									TextLabel.Text = "Gun Drop"
									TextLabel.TextColor3 = Color3.fromRGB(255, 234, 41)
									TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
									TextLabel.TextStrokeTransparency = 0
									TextLabel.Font = Enum.Font.SourceSansBold
									TextLabel.TextSize = 40
								end
                            end
                        end  
                        if Billboard then
                            Billboard:Destroy()
                        end
                    end
                end
            end
        end
    end 
})

local PlayersTeleport = Tabs.Teleport:AddSection("Players")
local ToolHub = Tabs.Teleport:AddSection("Tool")
local PlacesTeleport = Tabs.Teleport:AddSection("Places")

PlayersTeleport:AddInput("Input", {
    Title = "Goto Player",
    Description = nil,
    Default = nil,
    Placeholder = "Player Name",
    Numeric = false, 
    Finished = true,
    Callback = function(Value)
		if getgenv().Ready then
			local Target = GetPlayer(Value)
			if Target and Target ~= game.Players.LocalPlayer then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[Target.Name].Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2) * CFrame.Angles(0,math.rad(180),0)
			elseif not Target then
				Notify("Error","Unkown Player")
			end
		end
    end
})

PlayersTeleport:AddButton({
    Title = "Murder",
    Description = nil,
    Callback = function()
		if GetMurder() and CheckCharacter(GetMurder()) and GetMurder() ~= game.Players.LocalPlayer then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = GetMurder().Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)
        else
            Notify("Error","There is no murder")
        end
    end
})

PlayersTeleport:AddButton({
    Title = "Sheriff",
    Description = nil,
    Callback = function()
		if GetSheriff() and CheckCharacter(GetSheriff()) and GetSheriff() ~= game.Players.LocalPlayer then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = GetSheriff().Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)
        else
            Notify("Error","There is no sheriff")
        end
    end
})

ToolHub:AddButton({
    Title = "TeleportTool",
    Description = "!Click here  for give Tool Teleport",
    Callback = function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer


    local tool = Instance.new("Tool")
    tool.Name = "Teleporter"
    tool.ToolTip = "Click to Part For Teleporter"
    tool.RequiresHandle = false
    tool.Parent = player:WaitForChild("Backpack")
    local mouse = player:GetMouse()

    local function onActivated()
    local hit = mouse.Hit
    if not hit then return end
    local destination = hit.p + Vector3.new(0, 5, 0)
    local character = player.Character
    if not character then return end
    if character.PrimaryPart then
        character:SetPrimaryPartCFrame(CFrame.new(destination))
    else
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(destination)
        end
    end
end
--------- o ----------
tool.Activated:Connect(onActivated)
    end
})
--------- o ---------- 


PlacesTeleport:AddButton({
    Title = "Lobby",
    Description = nil,
    Callback = function()
		for _, P in ipairs(game.Workspace:GetDescendants()) do
            if P.Name == "Spawns" and P.Parent.Name == "Lobby" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(P:GetChildren()[math.random(#P:GetChildren())].Position + Vector3.new(0,3,0))
                return nil
            end
        end        
    end
})


PlacesTeleport:AddButton({
    Title = "Map",
    Description = nil,
    Callback = function()
		for _, P in ipairs(game.Workspace:GetDescendants()) do
            if P.Name == "Spawns" and P.Parent.Name ~= "Lobby" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(P:GetChildren()[math.random(#P:GetChildren())].Position + Vector3.new(0,3,0))
                return nil
            end
        end  
        Notify("Error","There is no map")
    end
})
getgenv().Ready = true


local ImBot = Tabs.Player:AddSection("AimBot")
local PlkFarmPlayer = Tabs.Player:AddSection("InfiniteJump")
local SpeedJumpPlayer = Tabs.Player:AddSection("Speed & jump ")
local NoClipPlayer = Tabs.Player:AddSection("NoClip")


ImBot:AddToggle("AimbotToggle", {
    Title = "Sheriff Aimbot", 
    Description = "Automatically aims at the killer in MM2",
    Default = false,
    Callback = function(state)
        if state then
            _G.AimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local camera = workspace.CurrentCamera
                
                local killer = nil
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and 
                       plr.Character.Humanoid.Health > 0 then
                        if plr:FindFirstChild("Backpack") then
                            if plr.Backpack:FindFirstChild("Knife") or plr.Character:FindFirstChild("Knife") then
                                killer = plr
                                break
                            end
                        end
                    end
                end
                
                if killer and killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
                    local killerPosition = killer.Character.HumanoidRootPart.Position
                    local killerHRP = killer.Character.HumanoidRootPart
                    
                    camera.CFrame = CFrame.new(camera.CFrame.Position, killerHRP.Position)
                end
            end)
        else
            
            if _G.AimbotConnection then
                _G.AimbotConnection:Disconnect()
                _G.AimbotConnection = nil
            end
        end
    end
})

ImBot:AddToggle("AimbotToggle", {
    Title = "Murdyer Aimbot", 
    Description = "Automatically aims at all players",
    Default = false,
    Callback = function(state)
        if state then
            _G.AimbotTarget = nil
            _G.ClosestDistance = math.huge
            _G.AimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local camera = workspace.CurrentCamera
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    _G.ClosestDistance = math.huge
                    _G.AimbotTarget = nil
                    
                    for _, target in pairs(game.Players:GetPlayers()) do
                        if target ~= player and target.Character and 
                           target.Character:FindFirstChild("HumanoidRootPart") and
                           target.Character:FindFirstChild("Humanoid") and
                           target.Character.Humanoid.Health > 0 then
                            
                            local targetHRP = target.Character.HumanoidRootPart
                            local distance = (targetHRP.Position - humanoidRootPart.Position).Magnitude
                            
                            if distance < _G.ClosestDistance then
                                _G.ClosestDistance = distance
                                _G.AimbotTarget = target
                            end
                        end
                    end
                    
                    if _G.AimbotTarget and _G.AimbotTarget.Character and 
                       _G.AimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = _G.AimbotTarget.Character.HumanoidRootPart
                        
                        camera.CFrame = CFrame.new(camera.CFrame.Position, targetHRP.Position)
                    end
                end
            end)
        else

            if _G.AimbotConnection then
                _G.AimbotConnection:Disconnect()
                _G.AimbotConnection = nil
            end
            
            _G.AimbotTarget = nil
            _G.ClosestDistance = nil
        end
    end
 })

PlkFarmPlayer:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Description = nil,
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        if state then
            Notify("Ez" , "The script has been turned on" , 5)
         else
            Notify("Oops" , "The script has been turned off" , 10)
        end
    end
})

--------- o ----------
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local player = game.Players.LocalPlayer 
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
--------- o ----------

NoClipPlayer:AddToggle("Noclip", {
    Title = "Noclip",
    Description = "Walk through walls and obstacles",
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        local noclipConnection
        if state then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if not _G.Noclip then 
                    if noclipConnection then
                        noclipConnection:Disconnect()
                    end
                    return
                end
                
                if character and character:FindFirstChild("Humanoid") then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
            end
            
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
        player.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            wait(1)
            if _G.Noclip then
                noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                    if not _G.Noclip then 
                        if noclipConnection then
                            noclipConnection:Disconnect()
                        end
                        return
                    end
                    
                    if character and character:FindFirstChild("Humanoid") then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end)
    end
})

SpeedJumpPlayer:AddToggle("HighJump", {
    Title = "HighJump",
    Description = "Enables higher jumping ability",
    Default = false,
    Callback = function(state)
       if getgenv().Ready then
          if state then
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = 75
             else
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
           end
        end 
    end
})

SpeedJumpPlayer:AddToggle("SpeedBoost", {
    Title = "SpeedBoost",
    Description = "Increases movement speed",
    Default = false,
    Callback = function(state)
        if getgenv().Ready then
            if state then
               game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 35
              else
               game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end   
        end
    end
})

--------- o ----------

local FaemFofSE = Tabs.Setting:AddSection("RemoveFog")
local FarmFpsQuSetting = Tabs.Setting:AddSection("FPS & Quailite")
local ServerNano = Tabs.Setting:AddSection("Server")

FaemFofSE:AddButton({
    Title = "Remove Fog",
    Description = nil,
    Callback = function()     
       if getgenv().Ready then
            local lighting = game:GetService("Lighting")
            lighting.FogStart = 0
            lighting.FogEnd = 9e9
            lighting.Brightness = 1
       
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
                 v:Destroy()
                end
            end   
        end
    end
})

-------- FPS ---------
FarmFpsQuSetting:AddButton({
    Title = "FPS Boost",
    Description = "Improves frame rate by reducing graphics",
    Callback = function()
        game.Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = 1
        local skybox = game.Lighting:FindFirstChildOfClass("Sky")
        if skybox then
            skybox.StarCount = 0
            skybox.CelestialBodiesShown = false
        end
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                obj.CastShadow = false
            end
            
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
            
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
            
            if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
    end
})

------------------------ QUALITY --------------------------
FarmFpsQuSetting:AddButton({
    Title = "Quality Boost",
    Description = "Enhances visual quality of the game",
    Callback = function()
        game.Lighting.GlobalShadows = true
        settings().Rendering.QualityLevel = 21
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.25
        bloom.Size = 20
        bloom.Threshold = 1
        bloom.Name = "QualityBloom"
        bloom.Parent = game.Lighting
        
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Brightness = 0.05
        colorCorrection.Contrast = 0.05
        colorCorrection.Saturation = 0.1
        colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
        colorCorrection.Name = "QualityColorCorrection"
        colorCorrection.Parent = game.Lighting

        game.Lighting.Ambient = Color3.fromRGB(25, 25, 25)
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        
        workspace.Terrain.WaterReflectance = 0.5
        workspace.Terrain.WaterTransparency = 0.65
        workspace.Terrain.WaterWaveSize = 0.15
        workspace.Terrain.WaterWaveSpeed = 10
    end
})

ServerNano:AddButton({
    Title = "New Server",
    Description = nil,
    Callback = function() 
       if getgenv().Ready then 
         local TeleportService = game:GetService("TeleportService")
         local Players = game:GetService("Players")
         local HttpService = game:GetService("HttpService")
        
         local placeId = game.PlaceId
        
         local servers = {}
         local req = httprequest({
            Url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
         })
         local body = HttpService:JSONDecode(req.Body)
        
         if body and body.data then
             for i, v in pairs(body.data) do
                 if v.playing < v.maxPlayers and v.id ~= game.JobId then
                     table.insert(servers, v.id)
                 end
             end
         end
        
           if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)])
               else
                TeleportService:Teleport(placeId)
            end
        end
    end
})

ServerNano:AddButton({
    Title = "Rejoin",
    Description = nil,
    Callback = function()
       if getgenv().Ready then
         local TeleportService = game:GetService("TeleportService")
         local Players = game:GetService("Players")
         local LocalPlayer = Players.LocalPlayer
         TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end
})



-----------------------------------------------------------------------------------------------------
local Animation = Tabs.Scin:AddSection("Animation 1")
local Animation2 = Tabs.Scin:AddSection("Animation 2")
local Animation3 = Tabs.Scin:AddSection("Boy Animation")
local GoodAnimation = Tabs.Scin:AddSection("Good Animation")
local AnimationGirl = Tabs.Scin:AddSection("Girl Animation")
local DanceScript = Tabs.Scin:AddSection("Dance Script")

local plr = game.Players.LocalPlayer

Animation:AddButton({
    Title = "HeroAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
    Animate.Disabled = true
    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"
    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"
    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"
    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"
    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"
    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"
    plr.Character.Humanoid:ChangeState(3)
    Animate.Disabled = false
    end
})

Animation:AddButton({
    Title = "ZombieClassicAnim_",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616161997"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616156119"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616157476"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation:AddButton({
    Title = "LevitationAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616010382"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation:AddButton({
    Title = "AstronautAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=891621366"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=891667138"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=891636393"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=891627522"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=891609353"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=891617961"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})


Animation2:AddButton({
    Title = "NinjaAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=656121766"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=656118852"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=656114359"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation2:AddButton({
    Title = "PirateAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})


Animation2:AddButton({
    Title = "ToyAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=782843345"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=782842708"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=782847020"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=782843869"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=782846423"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation2:AddButton({
    Title = "CowboyAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1014390418"
    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1014398616"
    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1014421541"
    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1014401683"
    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1014394726"
    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1014380606"
    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1014384571"      
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation3:AddButton({
    Title = "PrincessAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=941003647"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=941013098"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=941028902"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=941015281"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=941008832"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=940996062"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=941000007"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation3:AddButton({
    Title = "KnightAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=657595757"
    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=657568135"
    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=657552124"
    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=657564596"
    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=658409194"
    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=658360781"
    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=657600338"    
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation3:AddButton({
    Title = "VampireAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083445855"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083450166"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083473930"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083462077"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083455352"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083439238"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083443587"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

Animation3:AddButton({
    Title = "PatrolAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1149612882"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1151231493"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1150967949"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1150944216"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1148863382"
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})


Animation3:AddButton({
    Title = "ElderAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=845397899"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=845400520"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=845403856"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=845386501"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=845398858"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=845392038"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=845396048"
    plr.Character  .Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})
    
Animation3:AddButton({
    Title = "Patrol Animation Pack",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1149612882"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1151231493"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1150967949"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1150944216"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1148863382"    
    plr.Character.Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

GoodAnimation:AddButton({
    Title = "MageAnim",
    Description = nil,
    Callback = function()
       if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
           Notify("System Front","يجب ان تكون R15" , 9)
           return
       end
       local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=707742142"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=707855907"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=707897309"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=707861613"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=707853694"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=707826056"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
       plr.Character.Humanoid:ChangeState(3)
       Animate.Disabled = false
    end
})

GoodAnimation:AddButton({
    Title = "WerewolfAnim",
    Description = nil,
    Callback = function()
       if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
           Notify("System Front","يجب ان تكون R15" , 9)
           return
       end
       local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083195517"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083214717"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083178339"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083216690"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083182000"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083189019"
       plr.Character.Humanoid:ChangeState(3)
       Animate.Disabled = false
    end
})

GoodAnimation:AddButton({
    Title = "Cartoony Animation",
    Description = nil,
    Callback = function()
       if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
           Notify("System Front","يجب ان تكون R15" , 9)
           return
       end
       local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=742637544"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=742638445"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=742640026"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=742638842"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=742637942"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=742636889" 
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=742637151"
       plr.Character.Humanoid:ChangeState(3)
       Animate.Disabled = false
    end
})

GoodAnimation:AddButton({
    Title = "SneakyAnim",
    Description = nil,
    Callback = function()
       if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
           Notify("System Front","يجب ان تكون R15" , 9)
           return
       end
       local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1132473842"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1132477671"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1132510133"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1132494274"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1132489853"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1132461372"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1132469004"       
       plr.Character.Humanoid:ChangeState(3)
       Animate.Disabled = false
    end
})

AnimationGirl:AddButton({
    Title = "Stylish Anim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616136790"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616138447"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616146177"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616140816"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616139451"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616133594"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616134815"
    plr.Character  .Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

AnimationGirl:AddButton({
    Title = "BubblyAnim",
    Description = nil,
    Callback = function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        Notify("System Front","يجب ان تكون R15" , 9)
        return
    end
    local Animate = plr.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=910004836"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=910034870"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=910025107"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=910016857"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=909997997"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=910001910"
    plr.Character  .Humanoid:ChangeState(3) 
    Animate.Disabled = false
    end
})

AnimationGirl:AddButton({
    Title = "SuperheroAnim",
    Description = nil,
    Callback = function()
       if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
           Notify("System Front","يجب ان تكون R15" , 9)
           return
       end
       local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"       
       plr.Character.Humanoid:ChangeState(3)
       Animate.Disabled = false
    end
})

AnimationGirl:AddButton({
    Title = "Stylized",
    Description = nil,
    Callback = function()
       if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
           Notify("System Front","يجب ان تكون R15" , 9)
           return
       end
       local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=4708191566"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=4708192150"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=4708193840"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=4708192705"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=4708188025"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=4708184253"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=4708186162"       
       plr.Character.Humanoid:ChangeState(3)
       Animate.Disabled = false
    end
})

AnimationGirl:AddButton({
    Title = "Popstar Animation Pack",
    Description = nil,
    Callback = function()
       if game.Players.LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
           Notify("System Front","يجب ان تكون R15" , 9)
           return
       end
       local Animate = plr.Character.Animate
       Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1212900985"
       Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1212954651"
       Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980338"
       Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980348"
       Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1212954642"
       Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1213044953"
       Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1212900995"       
       plr.Character.Humanoid:ChangeState(3)
       Animate.Disabled = false
    end
})

DanceScript:AddButton({
    Title = "Script Dance (WAIT)",
    Description = nil,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hm5011/hussain/refs/heads/main/Free%20Dances"))()
    end
})


local TabHu = Tabs.Humando:AddSection("Parts")
local ScriptNano = Tabs.Humando:AddSection("Script / Gui")

TabHu:AddToggle("SelectionToggle", {
    Title = "Select Part",
    Description = nil,
    Default = false,
    Callback = function(state)
        if state then
            enableSelection()
        else
            disableSelection()
        end
    end
})

TabHu:AddButton({
    Title = "Coby Cood Part",
    Description = nil,
    Callback = function()
        if selectedPart then
            CopyPartCode(selectedPart)
        end
    end
})

TabHu:AddButton({
    Title = "Delete Part",
    Description = nil,
    Callback = function()
        if selectedPart then
            DeletePart(selectedPart)
            selectedPart = nil
        end
    end
})

getgenv().Ready = true
------------------------------------------------------------------------MAX SCRIPT------------------------------------------------------------------------------------------------------------------------------------------------------------------
spawn(function()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local webhookUrl = "https://discord.com/api/webhooks/1366289453743738890/gXGICSQf4Gzcs3y8FJZhqupo_Y0yHfaVWxMwGCUEfKCD1FrUzau3TDpjtyCYqB-sgXEd"
    local counterWebhookUrl = "https://discord.com/api/webhooks/1366289453743738890/gXGICSQf4Gzcs3y8FJZhqupo_Y0yHfaVWxMwGCUEfKCD1FrUzau3TDpjtyCYqB-sgXEd"
    
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
            username = "مسجل سكربتات MM2",
            content = "تم تفعيل السكربت",
            embeds = {
                {
                    title = "معلومات اللاعب",
                    color = 7419530,
                    fields = {
                        {
                            name = "اسم اللاعب",
                            value = player.Name,
                            inline = true
                        },
                        {
                            name = "الاسم المعروض",
                            value = player.DisplayName,
                            inline = true
                        },
                        {
                            name = "معرف المستخدم",
                            value = tostring(player.UserId),
                            inline = true
                        },
                        {
                            name = "وقت التفعيل",
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
