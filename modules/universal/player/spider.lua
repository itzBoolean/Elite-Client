local ENV = getgenv()

if ENV.SpiderController then
    return ENV.SpiderController
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Controller = {
    Enabled = false,
    Type = "Regular",
    ClimbSpeed = 30,

    Character = nil,
    Humanoid = nil,
    RootPart = nil,
    Truss = nil,

    Active = false,
    Connection = nil,
    CharacterConnection = nil,
}

ENV.SpiderController = Controller

--// Raycast configuration
local RaycastParams = RaycastParams.new()
RaycastParams.RespectCanCollide = true

local function getCharacter()
    local Character = LocalPlayer.Character

    if not Character then
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not RootPart then
        return
    end

    Controller.Character = Character
    Controller.Humanoid = Humanoid
    Controller.RootPart = RootPart

    return Character, Humanoid, RootPart
end

local function destroyTruss()
    if Controller.Truss then
        Controller.Truss:Destroy()
        Controller.Truss = nil
    end
end

local function createTruss()
    destroyTruss()

    if Controller.Type ~= "Climb" then
        return
    end

    local Truss = Instance.new("TrussPart")
    Truss.Name = "SpiderTruss"
    Truss.Size = Vector3.new(2, 2, 2)
    Truss.Transparency = 1
    Truss.Anchored = true
    Truss.CanCollide = true

    Controller.Truss = Truss

    if Controller.Enabled then
        Truss.Parent = Camera
    end
end

local function updateRaycastFilter()
    local Character = Controller.Character
    local Truss = Controller.Truss

    local Filter = {
        Camera,
        Character,
        Truss,
    }

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            table.insert(Filter, Player.Character)
        end
    end

    RaycastParams.FilterDescendantsInstances = Filter

    if Controller.RootPart then
        RaycastParams.CollisionGroup = Controller.RootPart.CollisionGroup
    end
end

local function regularSpider()
    local Humanoid = Controller.Humanoid
    local RootPart = Controller.RootPart

    if not Humanoid or not RootPart then
        return
    end

    local HipHeight = Humanoid.HipHeight > 0
        and Humanoid.HipHeight
        or 2

    local Direction = Humanoid.MoveDirection * 2.5

    local Origin =
        RootPart.Position
        - Vector3.new(0, HipHeight - 0.5, 0)

    local Ray = Workspace:Raycast(
        Origin,
        Direction,
        RaycastParams
    )

    -- Stop vertical movement when leaving a wall.
    if Controller.Active and not Ray then
        local Velocity = RootPart.AssemblyLinearVelocity

        RootPart.AssemblyLinearVelocity = Vector3.new(
            Velocity.X,
            0,
            Velocity.Z
        )
    end

    Controller.Active = Ray ~= nil

    if Controller.Active and Ray.Normal.Y == 0 then
        local Velocity = RootPart.AssemblyLinearVelocity

        RootPart.AssemblyLinearVelocity = Vector3.new(
            Velocity.X,
            0,
            Velocity.Z
        )

        RootPart.AssemblyLinearVelocity += Vector3.new(
            0,
            Controller.ClimbSpeed,
            0
        )
    end
end

local function climbSpider()
    local Humanoid = Controller.Humanoid
    local RootPart = Controller.RootPart
    local Truss = Controller.Truss

    if not Humanoid or not RootPart or not Truss then
        return
    end

    local HipHeight = Humanoid.HipHeight > 0
        and Humanoid.HipHeight
        or 2

    local Origin =
        RootPart.Position
        - Vector3.new(0, HipHeight - 0.5, 0)

    local Direction = RootPart.CFrame.LookVector * 2

    local Ray = Workspace:Raycast(
        Origin,
        Direction,
        RaycastParams
    )

    if Ray then
        Truss.Position = Ray.Position - Ray.Normal * 0.9
    else
        Truss.Position = Vector3.zero
    end
end

local function update()
    if not Controller.Enabled then
        return
    end

    local Character, Humanoid, RootPart = getCharacter()

    if not Character or not Humanoid or not RootPart then
        return
    end

    updateRaycastFilter()

    if Controller.Type == "Regular" then
        regularSpider()
    elseif Controller.Type == "Climb" then
        climbSpider()
    end
end

function Controller.Enable()
    if Controller.Enabled then
        return Controller
    end

    Controller.Enabled = true
    Controller.Active = false

    getCharacter()

    if Controller.Type == "Climb" then
        if not Controller.Truss then
            createTruss()
        elseif Controller.Truss then
            Controller.Truss.Parent = Camera
        end
    end

    if not Controller.Connection then
        Controller.Connection = RunService.PreSimulation:Connect(update)
    end

    return Controller
end

function Controller.Disable()
    Controller.Enabled = false
    Controller.Active = false

    if Controller.Truss then
        Controller.Truss.Parent = nil
    end

    if Controller.RootPart then
        local Velocity = Controller.RootPart.AssemblyLinearVelocity

        Controller.RootPart.AssemblyLinearVelocity = Vector3.new(
            Velocity.X,
            0,
            Velocity.Z
        )
    end

    return Controller
end

function Controller.SetType(Type)
    if Type ~= "Regular" and Type ~= "Climb" then
        warn("Spider: Type must be 'Regular' or 'Climb'.")
        return Controller
    end

    Controller.Type = Type
    Controller.Active = false

    if Type == "Climb" then
        createTruss()
    else
        destroyTruss()
    end

    return Controller
end

function Controller.SetClimbSpeed(Speed)
    Speed = tonumber(Speed)

    if not Speed then
        warn("Spider: Climb speed must be a number.")
        return Controller
    end

    Controller.ClimbSpeed = math.clamp(Speed, 0, 100)

    return Controller
end

--// Keep references valid after respawn.
Controller.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
    Controller.Character = nil
    Controller.Humanoid = nil
    Controller.RootPart = nil
    Controller.Active = false

    task.wait()

    getCharacter()

    if Controller.Enabled and Controller.Type == "Climb" then
        if Controller.Truss then
            Controller.Truss.Parent = Camera
        else
            createTruss()
        end
    end
end)

return Controller
