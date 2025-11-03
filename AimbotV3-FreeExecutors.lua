--[[

	Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
	https://github.com/Exunys

]]

--// Cache

local game, workspace = game, workspace
local getmetatable, setmetatable, pcall, getgenv, next, tick = getmetatable, setmetatable, pcall, getgenv, next, tick

-- Safe Drawing API
local Drawingnew = Drawing and Drawing.new or function() 
    return setmetatable({}, {
        __index = function() return function() end end,
        __newindex = function() end
    })
end

local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, TweenInfo.new
local mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

-- Simple property access without metatable manipulation
local function __index(instance, property)
	return instance[property]
end

local function __newindex(instance, property, value)
	instance[property] = value
end

-- Direct property access for Drawing objects (no getrenderproperty/setrenderproperty)
local function getrenderproperty(obj, prop)
	return obj[prop]
end

local function setrenderproperty(obj, prop, value)
	obj[prop] = value
end

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--// Service Methods

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function FindFirstChild(parent, name)
	return parent:FindFirstChild(name)
end

local function FindFirstChildOfClass(parent, className)
	return parent:FindFirstChildOfClass(className)
end

local function GetDescendants(parent)
	return parent:GetDescendants()
end

local function WorldToViewportPoint(position)
	return Camera:WorldToViewportPoint(position)
end

local function GetPartsObscuringTarget(position, ignoreList)
	return Camera:GetPartsObscuringTarget({position}, ignoreList)
end

local function GetMouseLocation()
	return UserInputService:GetMouseLocation()
end

local function GetPlayers()
	return Players:GetPlayers()
end

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}

--// Checking for multiple processes

if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Exit then
	ExunysDeveloperAimbot:Exit()
end

--// Environment

getgenv().ExunysDeveloperAimbot = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1 -- Bigger = Slower
	},

	Settings = {
		Enabled = true,

		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,

		OffsetToMoveDirection = false,
		OffsetIncrement = 15,

		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		Sensitivity2 = 3.5, -- mousemoverel Sensitivity

		LockMode = 1, -- 1 = CFrame; 2 = mousemoverel
		LockPart = "Head", -- Body part to lock on

		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false
	},

	FOVSettings = {
		Enabled = true,
		Visible = true,

		Radius = 90,
		NumSides = 60,

		Thickness = 1,
		Transparency = 1,
		Filled = false,

		RainbowColor = false,
		RainbowOutlineColor = false,
		Color = Color3fromRGB(255, 255, 255),
		OutlineColor = Color3fromRGB(0, 0, 0),
		LockedColor = Color3fromRGB(255, 150, 150)
	},

	Blacklisted = {},
	FOVCircleOutline = Drawingnew("Circle"),
	FOVCircle = Drawingnew("Circle")
}

local Environment = getgenv().ExunysDeveloperAimbot

setrenderproperty(Environment.FOVCircle, "Visible", false)
setrenderproperty(Environment.FOVCircleOutline, "Visible", false)

--// Core Functions

local FixUsername = function(String)
	local Result

	for _, Value in next, GetPlayers() do
		local Name = Value.Name

		if stringsub(stringlower(Name), 1, #String) == stringlower(String) then
			Result = Name
		end
	end

	return Result
end

local GetRainbowColor = function()
	local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed

	return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local CancelLock = function()
	Environment.Locked = nil

	local FOVCircle = Environment.FOVCircle

	setrenderproperty(FOVCircle, "Color", Environment.FOVSettings.Color)
	UserInputService.MouseDeltaSensitivity = OriginalSensitivity

	if Animation then
		Animation:Cancel()
	end
end

local GetClosestPlayer = function()
	local Settings = Environment.Settings
	local LockPart = Settings.LockPart

	if not Environment.Locked then
		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000

		for _, Value in next, GetPlayers() do
			local Character = Value.Character
			local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")

			if Value ~= LocalPlayer and not tablefind(Environment.Blacklisted, Value.Name) and Character and FindFirstChild(Character, LockPart) and Humanoid then
				local PartPosition, TeamCheckOption = Character[LockPart].Position, Environment.DeveloperSettings.TeamCheckOption

				if Settings.TeamCheck and Value[TeamCheckOption] == LocalPlayer[TeamCheckOption] then
					continue
				end

				if Settings.AliveCheck and Humanoid.Health <= 0 then
					continue
				end

				if Settings.WallCheck then
					local BlacklistTable = GetDescendants(LocalPlayer.Character)

					for _, ChildValue in next, GetDescendants(Character) do
						BlacklistTable[#BlacklistTable + 1] = ChildValue
					end

					if #GetPartsObscuringTarget(PartPosition, BlacklistTable) > 0 then
						continue
					end
				end

				local Vector, OnScreen = WorldToViewportPoint(PartPosition)
				Vector = ConvertVector(Vector)
				local Distance = (GetMouseLocation() - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance, Environment.Locked = Distance, Value
				end
			end
		end
	elseif Environment.Locked and Environment.Locked.Character and Environment.Locked.Character[LockPart] then
		local Distance = (GetMouseLocation() - ConvertVector(WorldToViewportPoint(Environment.Locked.Character[LockPart].Position))).Magnitude
		if Distance > RequiredDistance then
			CancelLock()
		end
	end
end

local Load = function()
	OriginalSensitivity = UserInputService.MouseDeltaSensitivity

	local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings

	ServiceConnections.RenderSteppedConnection = RunService[Environment.DeveloperSettings.UpdateMode]:Connect(function()
		pcall(function()
			local OffsetToMoveDirection, LockPart = Settings.OffsetToMoveDirection, Settings.LockPart

			if FOVSettings.Enabled and Settings.Enabled then
			for Index, Value in next, FOVSettings do
				-- Skip custom settings that aren't valid Circle properties
				if Index == "Color" or Index == "Enabled" or Index == "RainbowColor" or Index == "RainbowOutlineColor" or Index == "LockedColor" or Index == "OutlineColor" then
					continue
				end

				if pcall(getrenderproperty, FOVCircle, Index) then
					setrenderproperty(FOVCircle, Index, Value)
					setrenderproperty(FOVCircleOutline, Index, Value)
				end
			end

			setrenderproperty(FOVCircle, "Color", (Environment.Locked and FOVSettings.LockedColor) or FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
			setrenderproperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)

			setrenderproperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
			setrenderproperty(FOVCircle, "Position", GetMouseLocation())
			setrenderproperty(FOVCircleOutline, "Position", GetMouseLocation())
		else
			setrenderproperty(FOVCircle, "Visible", false)
			setrenderproperty(FOVCircleOutline, "Visible", false)
		end

		if Running and Settings.Enabled then
			GetClosestPlayer()

			-- Safely calculate offset with nil checks
			if OffsetToMoveDirection and Environment.Locked then
				local Character = Environment.Locked.Character
				local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")
				Offset = Humanoid and Humanoid.MoveDirection * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3zero
			else
				Offset = Vector3zero
			end

			if Environment.Locked then
				-- Validate that the locked character and part still exist
				local Character = Environment.Locked.Character
				if not Character then
					CancelLock()
					return
				end
				
				local TargetPart = FindFirstChild(Character, LockPart)
				if not TargetPart then
					CancelLock()
					return
				end
				
				local LockedPosition_Vector3 = TargetPart.Position
				if not LockedPosition_Vector3 then
					CancelLock()
					return
				end
				
				local LockedPosition = WorldToViewportPoint(LockedPosition_Vector3 + Offset)

				if Environment.Settings.LockMode == 2 then
					if mousemoverel then
						mousemoverel((LockedPosition.X - GetMouseLocation().X) / Settings.Sensitivity2, (LockedPosition.Y - GetMouseLocation().Y) / Settings.Sensitivity2)
					end
				else
					if Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3)})
						Animation:Play()
					else
						Camera.CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3 + Offset)
					end

					UserInputService.MouseDeltaSensitivity = 0
				end

				setrenderproperty(FOVCircle, "Color", FOVSettings.LockedColor)
			end
		end
		end)
	end)

	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Typing then
			return
		end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			if Toggle then
				Running = not Running

				if not Running then
					CancelLock()
				end
			else
				Running = true
			end
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Toggle or Typing then
			return
		end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			Running = false
			CancelLock()
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Functions

function Environment.Exit(self) -- METHOD | ExunysDeveloperAimbot:Exit(<void>)
	assert(self, "EXUNYS_AIMBOT-V3.Exit: Missing parameter #1 \"self\" <table>.")

	for Index, Connection in next, ServiceConnections do
		Connection:Disconnect()
	end

	Load = nil; ConvertVector = nil; CancelLock = nil; GetClosestPlayer = nil; GetRainbowColor = nil; FixUsername = nil

	self.FOVCircle:Remove()
	self.FOVCircleOutline:Remove()
	getgenv().ExunysDeveloperAimbot = nil
end

function Environment.Restart() -- ExunysDeveloperAimbot.Restart(<void>)
	for Index, Connection in next, ServiceConnections do
		Connection:Disconnect()
	end

	Load()
end

function Environment.Blacklist(self, Username) -- METHOD | ExunysDeveloperAimbot:Blacklist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: User "..Username.." couldn't be found.")

	self.Blacklisted[#self.Blacklisted + 1] = Username
end

function Environment.Whitelist(self, Username) -- METHOD | ExunysDeveloperAimbot:Whitelist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." couldn't be found.")

	local Index = tablefind(self.Blacklisted, Username)

	assert(Index, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." is not blacklisted.")

	tableremove(self.Blacklisted, Index)
end

function Environment.GetClosestPlayer() -- ExunysDeveloperAimbot.GetClosestPlayer(<void>)
	GetClosestPlayer()
	local Value = Environment.Locked
	CancelLock()

	return Value
end

Environment.Load = Load -- ExunysDeveloperAimbot.Load()

setmetatable(Environment, {__call = Load})

return Environment
