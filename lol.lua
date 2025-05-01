--function
local function Notify(Title,Dis)
    pcall(function()
        Fluent:Notify({Title = tostring(Title),Content = tostring(Dis),Duration = 5})
        local sound = Instance.new("Sound", game.Workspace) sound.SoundId = "rbxassetid://3398620867" sound.Volume = 1 sound.Ended:Connect(function() sound:Destroy() end) sound:Play()
    end)
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
    SubTitle = "By Front Evill",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, High),
    Acrylic = false,
    Theme = Guitheme,
    MinimizeKey = Enum.KeyCode.B
})


-- Fluent provides Lucide Icons, they are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Targeting = Window:AddTab({ Title = "Target", Icon = "target" })
    Player = Window:AddTab({ Title = "Player", Icon = "user" })
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "http://www.roblox.com/asset/?id=6034767608" })
}

local AutoFatm = Tab:AddSection("AutoFarm")
local AutoMony = Tabs.Maim:AddSection("AutoMoney")

-- code


local PlayerNameTargetting = Tabs.Targeting:AddSection("Target")
local OptionsTargetting = Tabs.Targeting:AddSection("Options")

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
