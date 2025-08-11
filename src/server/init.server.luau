local ChaserNPC = require(script.ChaserNPC)

local npc = ChaserNPC.spawn(Vector3.new(0, 5, 0))
if npc then
    ChaserNPC.chase(npc)
end