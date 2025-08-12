-- Sprint feature: detects Shift (keyboard) and ButtonL3 (controller) for sprinting
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local SprintEvent = ReplicatedStorage:WaitForChild("SprintEvent")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SprintEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SprintEvent")

local sprinting = false

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
	elseif input.KeyCode == Enum.KeyCode.ButtonL3 then -- Controller left stick press
		setSprinting(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprinting(false)
	elseif input.KeyCode == Enum.KeyCode.ButtonL3 then
		setSprinting(false)
	end
end)