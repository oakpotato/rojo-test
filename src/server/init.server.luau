local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")

local SprintEvent = repStorage:WaitForChild("Shared"):WaitForChild("SprintEvent")

if SprintEvent then
    print("SprintEvent found")
else
    print("SprintEvent not found")
end


local NORMAL_SPEED = 16
local SPRINT_SPEED = 28

Players.PlayerAdded:Connect(function(player)
    print("Player joined:", player.Name)
    player:SetAttribute("GoldOrbs", 0)

    player.CharacterAdded:Connect(function(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = NORMAL_SPEED
        end
    end)
end)

SprintEvent.OnServerEvent:Connect(function(player, isSprinting)
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            print("Player", player.Name, "is sprinting:", isSprinting)
            humanoid.WalkSpeed = isSprinting and SPRINT_SPEED or NORMAL_SPEED
        end
    end
end)

local ChaserNPC = require(script.ChaserNPC)

local npc = ChaserNPC.spawn(Vector3.new(0, 5, 0))
if npc then
    ChaserNPC.chase(npc)
end