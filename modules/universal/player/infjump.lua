local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local enabled = false
local connection

local InfJump = {}

function InfJump.Enable()
    if enabled then return end
    enabled = true

    connection = UserInputService.JumpRequest:Connect(function()
        if not enabled then return end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function InfJump.Disable()
    enabled = false

    if connection then
        connection:Disconnect()
        connection = nil
    end
end

return InfJump
