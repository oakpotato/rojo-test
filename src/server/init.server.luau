local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Get the NPC model
local npcTemplate = ReplicatedStorage:FindFirstChild("ChaserNPC")
if not npcTemplate then
    warn("ChaserNPC not found in ReplicatedStorage")
    return
end

-- Clone and position the NPC
local npc = npcTemplate:Clone()
npc.Parent = Workspace

-- Position the NPC on the baseplate
local rootPart = npc:FindFirstChild("HumanoidRootPart")
if rootPart then
    rootPart.CFrame = CFrame.new(Vector3.new(0, 5, 0)) -- Change position as needed
else
    warn("HumanoidRootPart not found in NPC model")
end

local Players = game:GetService("Players")
local chaseDistance = 20 -- NPC will chase if player is within 20 studs
local checkInterval = 0.5 -- seconds

local function isPlayerInFront(npcRoot, playerRoot)
    local npcLook = npcRoot.CFrame.LookVector
    local toPlayer = (playerRoot.Position - npcRoot.Position).Unit
    local dot = npcLook:Dot(toPlayer)
    return dot > 0.5 -- Adjust threshold as needed (closer to 1 = more directly in front)
end

local function getClosestPlayer(npcRoot)
    local closestPlayer = nil
    local closestDistance = chaseDistance
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local playerRoot = character:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                local distance = (npcRoot.Position - playerRoot.Position).Magnitude
                if distance <= chaseDistance and isPlayerInFront(npcRoot, playerRoot) then
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = playerRoot
                    end
                end
            end
        end
    end
    return closestPlayer
end

local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
if npcHumanoid and rootPart then
    while true do
        local target = getClosestPlayer(rootPart)
        if target then
            npcHumanoid:MoveTo(target.Position)
        end
        wait(checkInterval)
    end
end