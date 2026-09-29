local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local state = getgenv().InfiniteJumpState

if not state then
    state = {
        Enabled = false,
        Connection = nil
    }

    getgenv().InfiniteJumpState = state
end

local InfJump = {}

function InfJump.Enable()
    if state.Enabled then
        return
    end

    state.Enabled = true

    state.Connection = UserInputService.JumpRequest:Connect(function()
        if not state.Enabled then
            return
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function InfJump.Disable()
    state.Enabled = false

    if state.Connection then
        state.Connection:Disconnect()
        state.Connection = nil
    end
end

return InfJump
