local env = getgenv()

env.WaterWalk = env.WaterWalk or {}

local WaterWalk = env.WaterWalk

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Connection
local Platform
local RaycastParams = RaycastParams.new()

RaycastParams.FilterType = Enum.RaycastFilterType.Include

local function Cleanup()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    if Platform then
        Platform:Destroy()
        Platform = nil
    end
end

function WaterWalk.Enable()
    Cleanup()

    local Terrain = Workspace:FindFirstChildWhichIsA("Terrain")
    if not Terrain then
        return
    end

    RaycastParams.FilterDescendantsInstances = { Terrain }

    Platform = Instance.new("Part")
    Platform.Name = "WaterWalkPlatform"
    Platform.Size = Vector3.one
    Platform.Transparency = 1
    Platform.Anchored = true
    Platform.CanCollide = true
    Platform.CanQuery = false
    Platform.CanTouch = false
    Platform.Parent = Workspace

    Connection = RunService.PreSimulation:Connect(function()
        local Character = LocalPlayer.Character
        if not Character then
            return
        end

        local Root = Character:FindFirstChild("HumanoidRootPart")
        if not Root then
            return
        end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local HipHeight = Humanoid and Humanoid.HipHeight or 2

        local Distance = (Root.Size.Y / 2)
            + HipHeight
            + math.abs(Root.AssemblyLinearVelocity.Y * 0.032)

        local Ray = Workspace:Raycast(
            Root.Position,
            Vector3.new(0, -Distance, 0),
            RaycastParams
        )

        if Ray and Ray.Material == Enum.Material.Water then
            Platform.CFrame = CFrame.new(Ray.Position)
        else
            Platform.CFrame = CFrame.new(10000, 10000, 10000)
        end
    end)
end

function WaterWalk.Disable()
    Cleanup()
end

return WaterWalk
