-- PlatformButtonHandler.luau
-- Handles color change for PlatformButton when touched by a player


print("PlatformButtonHandler initialized")

local roomFolder = workspace:FindFirstChild("TestRoom3")
local button = roomFolder and roomFolder:FindFirstChild("PlatformButton")
local platformsFolder = roomFolder and roomFolder:FindFirstChild("FloatingPlatforms")

if button then
    button.Touched:Connect(function(hit)
        local character = hit.Parent
        if character and character:FindFirstChild("Humanoid") then
            button.BrickColor = BrickColor.new("Bright green")
            if platformsFolder then
                for _, part in ipairs(platformsFolder:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end
        end
    end)
end
