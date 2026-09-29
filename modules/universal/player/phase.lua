local env = getgenv()

env.Noclip = env.Noclip or {}

local Noclip = env.Noclip
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Connection

local function SetCollision(state)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("BasePart") then
            Object.CanCollide = state
        end
    end
end

function Noclip.Enable()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    SetCollision(false)

    Connection = RunService.Stepped:Connect(function()
        if not LocalPlayer.Character then
            return
        end

        SetCollision(false)
    end)
end

function Noclip.Disable()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    SetCollision(true)
end

LocalPlayer.CharacterAdded:Connect(function(Character)
    if Connection then
        Character:WaitForChild("HumanoidRootPart", 10)
        SetCollision(false)
    end
end)

return Noclip
