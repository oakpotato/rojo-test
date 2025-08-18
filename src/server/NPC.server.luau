local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

-- ===================== CONFIG ===================== --
local MODEL_NAME = "Dummy"           -- Name of the NPC Model in Workspace
local BASEPLATE_NAME = "Baseplate"   -- Name of the base plate part

local AGENT_PARAMS = {               -- Tune for your rig proportions
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = true,
}

-- ================================================== --

local npc = Workspace:WaitForChild(MODEL_NAME)
local goalPart = Workspace:WaitForChild("GoalPart")

local humanoid: Humanoid? = npc:FindFirstChildWhichIsA("Humanoid")
if not humanoid then
	warn("DummyNPC: Humanoid not found inside '" .. MODEL_NAME .. "'")
	return
end

local rootPart: BasePart? = npc:FindFirstChild("HumanoidRootPart") :: any
if not rootPart then
	warn("DummyNPC: HumanoidRootPart missing in '" .. MODEL_NAME .. "'")
	return
end

-- Pre-create a reusable Path object.
local path = PathfindingService:CreatePath()

local success, errorMessage = pcall(function()
    path:ComputeAsync(npc.PrimaryPart.Position, goalPart.Position)
end)

if success then
    for _, waypoint in ipairs(path:GetWaypoints()) do
        local part = Instance.new("Part")
        part.Position = waypoint.Position
        part.Anchored = true
        part.Shape = "Ball"
        part.Parent = Workspace
        part.CanCollide = false
        part.Material = "Neon"
    end

else
    warn("Pathfinding failed: " .. errorMessage)
end
