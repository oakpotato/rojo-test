-- ChaserNPC.luau
-- Contains logic for spawning and controlling the ChaserNPC

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local ChaserNPC = {}
ChaserNPC.chaseDistance = 20
ChaserNPC.checkInterval = 0.5

function ChaserNPC.spawn(position)
    local npcTemplate = ReplicatedStorage:FindFirstChild("ChaserNPC")
    if not npcTemplate then
        warn("ChaserNPC not found in ReplicatedStorage")
        return nil
    end
    local npc = npcTemplate:Clone()
    npc.Parent = Workspace
    local rootPart = npc:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(position or Vector3.new(0, 5, 0))
    else
        warn("HumanoidRootPart not found in NPC model")
    end
    return npc
end

function ChaserNPC.isPlayerInFront(npcRoot, playerRoot)
    local npcLook = npcRoot.CFrame.LookVector
    local toPlayer = (playerRoot.Position - npcRoot.Position).Unit
    local dot = npcLook:Dot(toPlayer)
    return dot > 0.5
end

function ChaserNPC.getClosestPlayer(npcRoot)
    local closestPlayer = nil
    local closestDistance = ChaserNPC.chaseDistance
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            local playerRoot = character:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                local distance = (npcRoot.Position - playerRoot.Position).Magnitude
                if distance <= ChaserNPC.chaseDistance and ChaserNPC.isPlayerInFront(npcRoot, playerRoot) then
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

function ChaserNPC.chase(npc)
    local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
    local rootPart = npc:FindFirstChild("HumanoidRootPart")
    if npcHumanoid and rootPart then
        spawn(function()
            while true do
                local target = ChaserNPC.getClosestPlayer(rootPart)
                if target then
                    npcHumanoid:MoveTo(target.Position)
                end
                wait(ChaserNPC.checkInterval)
            end
        end)
    end
end

return ChaserNPC
