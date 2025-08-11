# copilot-instructions.md

## Purpose
These instructions define **best practices** for GitHub Copilot when generating code for this Roblox game project. They ensure consistency, maintainability, performance, and adherence to Roblox Lua coding standards.

---

## General Guidelines
1. **Language:** All scripts should be written in **Luau** (Roblox’s Lua dialect).
2. **Readability:** Favor **clear, maintainable code** over brevity. Use descriptive variable and function names.
3. **Commenting:** Add comments to explain logic, especially for complex gameplay mechanics or networking.
4. **Formatting:**
   - Use 4 spaces for indentation.
   - Keep lines under 100 characters.
   - Group related functions together.

---

## Roblox-Specific Rules
1. **Services:**
   - Always access services via `game:GetService("ServiceName")` instead of `game.ServiceName`.
   - Store service references at the top of the script for clarity.
     ```lua
     local Players = game:GetService("Players")
     local ReplicatedStorage = game:GetService("ReplicatedStorage")
     ```
   
2. **Module Scripts:**
   - Encapsulate reusable code in `ModuleScripts` with clear public functions.
   - Avoid global variables; use local scope wherever possible.

3. **Remote Events & Functions:**
   - Name remotes descriptively, e.g., `PlayerJoinedEvent`, `UpdateScoreEvent`.
   - Always **validate** remote event input server-side to prevent exploitation.

4. **Client/Server Separation:**
   - Only client scripts manipulate UI or local effects.
   - Only server scripts handle game logic, data storage, and authoritative actions.

---

## Performance Best Practices
1. **Avoid heavy loops** running every frame; use Roblox signals/events when possible.
2. **Cache** frequently accessed objects and services in variables.
3. **Debounce** player input events to prevent spamming.
4. For animations, use `TweenService` or `AnimationTracks` rather than manually stepping positions each frame.

---

## Naming Conventions
- **Variables:** `camelCase` for local variables, `PascalCase` for constants.
- **Functions:** `PascalCase` for public API, `camelCase` for internal helpers.
- **Assets:** Match in-game object names to script variable names when possible.

---

## Example Script Pattern
```lua
-- PlayerJoinHandler.lua
-- Handles player join events and setup

local Players = game:GetService("Players")

local function onPlayerAdded(player)
    print(player.Name .. " has joined the game!")
    -- Setup leaderstats, inventory, etc.
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

---

## Prohibited Practices
- Do not use `wait()` without a reason; prefer `task.wait()` or signals.
- Do not directly parent instances without checking if their parent exists.
- Never trust client data without validation.

---

## Documentation & Testing
- Use clear inline comments.
- For complex systems, create a **README.md** in the relevant folder explaining usage.
- When writing test scripts, ensure they are disabled in production unless specifically for debug.

---

## Commit Message Suggestions
When Copilot generates commits, follow this format:
```
[Type] Short description

Details of changes if needed.
```
Example:
```
[Feature] Add leaderboard system

Implemented server-side storage and client UI display for player scores.
```
