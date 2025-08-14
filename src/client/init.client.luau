-- Client initialization script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SprintModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SprintModule"))

-- Initialize the sprint system
SprintModule.Init()

-- You can customize the sprint settings by passing a config table:
-- SprintModule.Init({
--     NORMAL_FOV = 70,
--     SPRINT_FOV = 85,
--     TWEEN_TIME = 0.3
-- })