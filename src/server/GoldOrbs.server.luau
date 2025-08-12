print("Hello from Gold Orbs")

local collectionService = game:GetService("CollectionService")
local parts = collectionService:GetTagged("Pickups")

for _, part in ipairs(parts) do
    print("Found pickup part:", part.Name)
    local debounce = true

    part.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player and debounce then
            debounce = false

            print("Player touched pickup:", player.Name)
            local currentGold = player:GetAttribute("GoldOrbs") or 0
            player:SetAttribute("GoldOrbs", currentGold + 1)
            print("Player's Gold Orbs:", player:GetAttribute("GoldOrbs"))

            -- Optionally, you can destroy the part after pickup
            part:Destroy()
            
            task.wait(2)
            debounce = true
        end
    end)
end