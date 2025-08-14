-- Sprint Module: Handles client-side sprinting functionality
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SprintModule = {}

-- Default configuration
local DEFAULT_CONFIG = {
	NORMAL_FOV = 70,
	SPRINT_FOV = 80,
	TWEEN_TIME = 0.5,
	SPRINT_BUTTONS = {
		[Enum.KeyCode.LeftShift] = true,
		[Enum.KeyCode.RightShift] = true,
		[Enum.KeyCode.ButtonL3] = true
	}
}

local sprinting = false
local camera = workspace.CurrentCamera
local connections = {}
local config = DEFAULT_CONFIG -- Initialize with defaults

local function tweenFOV(targetFOV)
	local tween = TweenService:Create(
		camera, 
		TweenInfo.new(config.TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
		{FieldOfView = targetFOV}
	)
	tween:Play()
end

local function setSprinting(state, sprintEvent)
	if sprinting ~= state then
		sprinting = state
		if sprintEvent then
			sprintEvent:FireServer(sprinting)
		end
	end
end

-- Initialize the sprint system
function SprintModule.Init(customConfig)
	-- Ensure we're on the client
	if not RunService:IsClient() then
		warn("SprintModule should only be initialized on the client!")
		return
	end
	
	-- Merge custom config with defaults
	config = {}
	for key, value in pairs(DEFAULT_CONFIG) do
		config[key] = value
	end
	if customConfig then
		for key, value in pairs(customConfig) do
			config[key] = value
		end
	end
	
	-- Get the sprint event
	local sprintEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SprintEvent")
	
	-- Connect input events
	connections.inputBegan = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if config.SPRINT_BUTTONS[input.KeyCode] then
			setSprinting(true, sprintEvent)
			tweenFOV(config.SPRINT_FOV)
		end
	end)
	
	connections.inputEnded = UserInputService.InputEnded:Connect(function(input)
		if config.SPRINT_BUTTONS[input.KeyCode] then
			setSprinting(false, sprintEvent)
			tweenFOV(config.NORMAL_FOV)
		end
	end)
	
	print("Sprint system initialized!")
end

-- Clean up connections
function SprintModule.Cleanup()
	for _, connection in pairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end
	connections = {}
	sprinting = false
end

-- Get current sprint state
function SprintModule.IsSprinting()
	return sprinting
end

-- Update camera reference (useful if camera changes)
function SprintModule.UpdateCamera(newCamera)
	camera = newCamera or workspace.CurrentCamera
end

return SprintModule
