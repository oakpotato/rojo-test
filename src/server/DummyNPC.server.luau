-- -- DummyNPC.luau
-- -- Server script to make a Workspace model named "Dummy" wander to random points on the Baseplate using PathfindingService.

-- local PathfindingService = game:GetService("PathfindingService")
-- local Workspace = game:GetService("Workspace")

-- -- ===================== CONFIG ===================== --
-- local MODEL_NAME = "Dummy"           -- Name of the NPC Model in Workspace
-- local BASEPLATE_NAME = "Baseplate"   -- Name of the base plate part

-- local AGENT_PARAMS = {               -- Tune for your rig proportions
-- 	AgentRadius = 2,
-- 	AgentHeight = 5,
-- 	AgentCanJump = true,
-- }

-- -- (Debug logging removed for production; add a DEBUG flag if you need verbose output.)

-- local NEW_TARGET_DELAY = NumberRange.new(1, 3) -- Random wait before selecting next destination
-- local PATH_RETRY_DELAY = 0.5                   -- Delay before retrying a failed path
-- local MAX_PATH_RETRIES = 4                     -- How many times to retry a single destination

-- local EDGE_MARGIN = 5          -- Studs kept away from the very edge of the baseplate
-- local MIN_TRAVEL_DISTANCE = 25 -- Don’t pick a target closer than this (studs)

-- -- ================================================== --

-- local model: Model? = Workspace:FindFirstChild(MODEL_NAME) :: any
-- if not model or not model:IsA("Model") then
-- 	warn("DummyNPC: Model '" .. MODEL_NAME .. "' not found in Workspace")
-- 	return
-- end

-- local humanoid: Humanoid? = model:FindFirstChildWhichIsA("Humanoid")
-- if not humanoid then
-- 	warn("DummyNPC: Humanoid not found inside '" .. MODEL_NAME .. "'")
-- 	return
-- end

-- local rootPart: BasePart? = model:FindFirstChild("HumanoidRootPart") :: any
-- if not rootPart then
-- 	warn("DummyNPC: HumanoidRootPart missing in '" .. MODEL_NAME .. "'")
-- 	return
-- end

-- if not model.PrimaryPart then
-- 	-- Set a PrimaryPart if one is not yet assigned (needed for some workflows)
-- 	model.PrimaryPart = rootPart
-- end

-- local baseplate: BasePart? = Workspace:FindFirstChild(BASEPLATE_NAME) :: any
-- if not baseplate or not baseplate:IsA("BasePart") then
-- 	warn("DummyNPC: Baseplate part '" .. BASEPLATE_NAME .. "' not found")
-- 	return
-- end

-- -- Pre-create a reusable Path object.
-- local path: Path = PathfindingService:CreatePath(AGENT_PARAMS)

-- -- State
-- local currentWaypoints: { PathWaypoint }? = nil
-- local nextWaypointIndex = 0
-- local blockedConn: RBXScriptConnection? = nil
-- local reachedConn: RBXScriptConnection? = nil
-- local active = true

-- -- Utility: random float in range
-- local function randomFloat(min: number, max: number): number
-- 	return min + math.random() * (max - min)
-- end

-- local function randomDelay(range: NumberRange)
-- 	task.wait(randomFloat(range.Min, range.Max))
-- end

-- -- Compute a random reachable point on the baseplate surface.
-- local function getRandomTarget(): Vector3
-- 	local size = baseplate.Size
-- 	local center = baseplate.Position

-- 	-- Constrain within edges
-- 	local halfX = size.X * 0.5 - EDGE_MARGIN
-- 	local halfZ = size.Z * 0.5 - EDGE_MARGIN

-- 	local x = center.X + randomFloat(-halfX, halfX)
-- 	local z = center.Z + randomFloat(-halfZ, halfZ)
-- 	local y = center.Y + size.Y * 0.5 + 1 -- Just above surface

-- 	-- Random target chosen
-- 	return Vector3.new(x, y, z)
-- end

-- local function pickNextDestination(): Vector3
-- 	local origin = rootPart.Position
-- 	local dest
-- 	local tries = 0
-- 	repeat
-- 		dest = getRandomTarget()
-- 		tries += 1
-- 	until (origin - dest).Magnitude >= MIN_TRAVEL_DISTANCE or tries > 10
-- 	return dest
-- end

-- local function disconnectMoveConns()
-- 	if blockedConn then
-- 		blockedConn:Disconnect()
-- 		blockedConn = nil
-- 	end
-- 	if reachedConn then
-- 		reachedConn:Disconnect()
-- 		reachedConn = nil
-- 	end
-- end

-- local function followPath(destination: Vector3, attempt: number)
-- 	if not active then return end

-- 	-- Safety: ensure rig parts are unanchored and owned by server before each compute
-- 	for _, part in ipairs(model:GetDescendants()) do
-- 		if part:IsA("BasePart") then
-- 			if part.Anchored then
-- 				part.Anchored = false
-- 			end
-- 			-- Force server ownership
-- 			pcall(function()
-- 				part:SetNetworkOwner(nil)
-- 			end)
-- 		end
-- 	end

-- 	local success, _ = pcall(function()
-- 		path:ComputeAsync(rootPart.Position, destination)
-- 	end)

-- 	if not success or path.Status ~= Enum.PathStatus.Success then
-- 		if attempt < MAX_PATH_RETRIES and active then
-- 			task.wait(PATH_RETRY_DELAY)
-- 			followPath(destination, attempt + 1)
-- 		else
-- 			-- Give up on this destination; pick a new one soon.
-- 			-- Abandon destination & pick new
-- 			randomDelay(NEW_TARGET_DELAY)
-- 			followPath(pickNextDestination(), 0)
-- 		end
-- 		return
-- 	end

-- 	currentWaypoints = path:GetWaypoints()
-- 	nextWaypointIndex = 2 -- 1 is the start position
-- 	-- Waypoints acquired

-- 	-- Listen for path becoming blocked ahead.
-- 	blockedConn = path.Blocked:Connect(function(blockedIdx)
-- 		if blockedIdx >= nextWaypointIndex then
-- 			disconnectMoveConns()
-- 			followPath(destination, 0) -- Recompute same destination
-- 		end
-- 	end)

-- 	-- Movement progression
-- 	if not reachedConn then
-- 		reachedConn = humanoid.MoveToFinished:Connect(function(reached: boolean)
-- 			if not active then return end
-- 			if reached and currentWaypoints and nextWaypointIndex <= #currentWaypoints then
-- 				if nextWaypointIndex < #currentWaypoints then
-- 					nextWaypointIndex += 1
-- 					humanoid:MoveTo(currentWaypoints[nextWaypointIndex].Position)
-- 				else
-- 					-- Arrived at final waypoint; choose a new destination after a small delay.
-- 					disconnectMoveConns()
-- 					randomDelay(NEW_TARGET_DELAY)
-- 					followPath(pickNextDestination(), 0)
-- 				end
-- 			else
-- 				-- Failed to reach; retry destination once.
-- 				disconnectMoveConns()
-- 				task.wait(PATH_RETRY_DELAY)
-- 				followPath(destination, 0)
-- 			end
-- 		end)
-- 	end

-- 	-- Start moving (guard against short path of only one waypoint)
-- 	if currentWaypoints and currentWaypoints[2] then
-- 		humanoid:MoveTo(currentWaypoints[2].Position)

-- 		-- Stuck watchdog: if velocity stays near zero for a while, force re-path / direct move
-- 			task.delay(2, function()
-- 			if not active then return end
-- 			local vel = rootPart.AssemblyLinearVelocity.Magnitude
-- 				if vel < 0.5 then
-- 				-- Try re-issuing MoveTo or fallback direct move to final destination
-- 				if currentWaypoints and currentWaypoints[#currentWaypoints] then
-- 					humanoid:MoveTo(currentWaypoints[#currentWaypoints].Position)
-- 				end
-- 				-- If still stuck later, completely re-path
-- 					task.delay(1.5, function()
-- 					if rootPart.AssemblyLinearVelocity.Magnitude < 0.5 and active then
-- 						disconnectMoveConns()
-- 						followPath(pickNextDestination(), 0)
-- 					end
-- 				end)
-- 			end
-- 		end)
-- 	else
-- 		-- Path collapsed to start; pick a new destination.
-- 		disconnectMoveConns()
-- 		randomDelay(NEW_TARGET_DELAY)
-- 		followPath(pickNextDestination(), 0)
-- 	end
-- end

-- -- Attach simple Idle/Walk animations (replace asset IDs with custom NPC animations as desired)
-- -- Shared modules are mapped to ReplicatedStorage/Shared via Rojo (see default.project.json)
-- local SharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
-- local AnimatorUtil = require(SharedFolder:WaitForChild("NPCAnimation"))
-- local _animController = AnimatorUtil.attach(humanoid, {
-- 	Animations = {
-- 		Idle = { Id = 507766666, Fade = 0.3 },   -- Roblox default Idle
-- 		Walk = { Id = 507777826, Fade = 0.15 }, -- Roblox default Walk
-- 	},
-- 	WalkSpeedThreshold = 2,
-- })

-- -- Kick off wandering
-- task.defer(function()
-- 	-- Small initial delay to let world settle.
-- 	task.wait(0.25)
-- 	followPath(pickNextDestination(), 0)
-- end)

-- -- Optional: expose a simple API via a BindableEvent (uncomment if needed)
-- --[[
-- local apiEvent = Instance.new("BindableEvent")
-- apiEvent.Name = "DummyNPC_API"
-- apiEvent.Parent = model

-- -- Call with "Stop" to halt wandering, or "Resume" to continue.
-- apiEvent.Event:Connect(function(command)
-- 	if command == "Stop" then
-- 		active = false
-- 		humanoid:Move(Vector3.zero)
-- 		disconnectMoveConns()
-- 	elseif command == "Resume" then
-- 		if not active then
-- 			active = true
-- 			followPath(pickNextDestination(), 0)
-- 		end
-- 	end
-- end)
-- ]]

