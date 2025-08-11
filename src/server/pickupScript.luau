-- locally establish the Collection Service
local collectionService = game:GetService("CollectionService")
-- search for any Parts with the "Pickups" tag
local parts = collectionService:GetTagged("Pickups")

-- loop through each pickup
for _, part in ipairs(parts) do
    local debounce = true

    part.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player and not debounce then
            debounce = false
            
            -- remove part from world
            part:Destroy()
            -- add part to player's inventory
            player.Backpack:AddItem(part)
        end
    end)
end