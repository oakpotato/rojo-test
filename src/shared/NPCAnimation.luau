-- NPCAnimation.luau
-- Lightweight humanoid animation helper for server-driven NPCs.
-- Usage:
-- local AnimatorUtil = require(path.to.NPCAnimation)
-- local controller = AnimatorUtil.attach(humanoid, {
--     Animations = {
--         Idle = { Id = 507766666, Fade = 0.4 },
--         Walk = { Id = 507777826, Fade = 0.2 },
--     },
--     WalkSpeedThreshold = 2, -- studs/sec to switch to Walk
-- })

export type AnimationSpec = { Id: number, Fade: number? }
export type Config = {
    Animations: { Idle: AnimationSpec, Walk: AnimationSpec },
    WalkSpeedThreshold: number?,
}

local DEFAULTS = {
    WalkSpeedThreshold = 1.75,
}

local AnimatorUtil = {}

local function createAndLoad(animator: Animator, spec: AnimationSpec)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(spec.Id)
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Movement
    return track
end

function AnimatorUtil.attach(humanoid: Humanoid, config: Config)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local walkThreshold = config.WalkSpeedThreshold or DEFAULTS.WalkSpeedThreshold

    local idleSpec = config.Animations.Idle
    local walkSpec = config.Animations.Walk
    assert(idleSpec and walkSpec, "NPCAnimation: Idle and Walk specs required")

    local idleTrack = createAndLoad(animator, idleSpec)
    local walkTrack = createAndLoad(animator, walkSpec)

    local current: AnimationTrack? = nil
    local state: string = "Idle"

    local function play(track: AnimationTrack, fade: number?)
        if current == track then return end
        if current and current.IsPlaying then
            current:Stop(fade or 0.2)
        end
        current = track
        track:Play(fade or 0.2)
    end

    -- Start idle by default
    play(idleTrack, idleSpec.Fade)

    humanoid.Running:Connect(function(speed)
        local shouldWalk = speed >= walkThreshold
        if shouldWalk then
            if state ~= "Walk" then
                state = "Walk"
                play(walkTrack, walkSpec.Fade)
            end
        else
            if state ~= "Idle" then
                state = "Idle"
                play(idleTrack, idleSpec.Fade)
            end
        end
    end)

    return {
        GetState = function()
            return state
        end,
        PlayIdle = function()
            state = "Idle"
            play(idleTrack, idleSpec.Fade)
        end,
        PlayWalk = function()
            state = "Walk"
            play(walkTrack, walkSpec.Fade)
        end,
        StopAll = function()
            if current and current.IsPlaying then
                current:Stop(0.2)
            end
        end,
    }
end

return AnimatorUtil
