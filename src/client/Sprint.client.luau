-- Dedicated sprint client script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SprintModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SprintModule"))

-- Initialize the sprint system with default settings
SprintModule.Init()

-- Optional: Initialize with custom settings
-- SprintModule.Init({
--     NORMAL_FOV = 70,
--     SPRINT_FOV = 85,
--     TWEEN_TIME = 0.3,
--     SPRINT_BUTTONS = {
--         [Enum.KeyCode.LeftShift] = true,
--         [Enum.KeyCode.RightShift] = true,
--         [Enum.KeyCode.ButtonL3] = true,
--         -- Add custom keys if needed
--     }
-- })
