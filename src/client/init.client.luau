-- Sprint feature: detects Shift (keyboard) and ButtonL3 (controller) for sprinting
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SprintEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SprintEvent")

local sprinting = false
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera
local NORMAL_FOV = 70
local SPRINT_FOV = 90
local TWEEN_TIME = 0.5

local function tweenFOV(targetFOV)
	local tween = TweenService:Create(camera, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = targetFOV})
	tween:Play()
end

local function setSprinting(state)
	if sprinting ~= state then
		sprinting = state
		SprintEvent:FireServer(sprinting)
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprinting(true)
		tweenFOV(SPRINT_FOV)
	elseif input.KeyCode == Enum.KeyCode.ButtonL3 then -- Controller left stick press
		setSprinting(true)
		tweenFOV(SPRINT_FOV)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprinting(false)
		tweenFOV(NORMAL_FOV)
	elseif input.KeyCode == Enum.KeyCode.ButtonL3 then
		setSprinting(false)
		tweenFOV(NORMAL_FOV)
	end
end)