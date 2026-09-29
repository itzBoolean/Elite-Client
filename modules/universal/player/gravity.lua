local env = getgenv()

env.Gravity = env.Gravity or {}

local Gravity = env.Gravity

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Mode = "Velocity"
local GravityValue = 60

local OldGravity = nil
local GravityConnection = nil
local PropertyConnection = nil
local Changed = false

local function DisconnectConnections()
    if GravityConnection then
        GravityConnection:Disconnect()
        GravityConnection = nil
    end

    if PropertyConnection then
        PropertyConnection:Disconnect()
        PropertyConnection = nil
    end
end

local function GetCharacter()
    local Character = LocalPlayer.Character

    if not Character then
        return nil, nil, nil
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")

    return Character, Humanoid, RootPart
end

local function Update()
    DisconnectConnections()

    if not Enabled then
        if OldGravity ~= nil then
            Changed = true
            Workspace.Gravity = OldGravity
            Changed = false
            OldGravity = nil
        end

        return
    end

    if Mode == "Workspace" then
        if OldGravity == nil then
            OldGravity = Workspace.Gravity
        end

        Changed = true
        Workspace.Gravity = GravityValue
        Changed = false

        PropertyConnection = Workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
            if Changed then
                return
            end

            Changed = true
            Workspace.Gravity = GravityValue
            Changed = false
        end)

        return
    end

    GravityConnection = RunService.PreSimulation:Connect(function(DeltaTime)
        local _, Humanoid, RootPart = GetCharacter()

        if not Humanoid or not RootPart then
            return
        end

        if Humanoid.FloorMaterial == Enum.Material.Air then
            RootPart.AssemblyLinearVelocity += Vector3.new(
                0,
                DeltaTime * (Workspace.Gravity - GravityValue),
                0
            )
        end
    end)
end

function Gravity.Enable()
    Enabled = true
    Update()
end

function Gravity.Disable()
    Enabled = false
    Update()
end

function Gravity.SetType(Value)
    if Value ~= "Velocity" and Value ~= "Workspace" then
        return false
    end

    Mode = Value

    if Enabled then
        Update()
    end

    return true
end

function Gravity.SetValue(Value)
    Value = tonumber(Value)

    if not Value then
        return false
    end

    GravityValue = Value

    if Enabled and Mode == "Workspace" then
        Changed = true
        Workspace.Gravity = GravityValue
        Changed = false
    end

    return true
end

LocalPlayer.CharacterAdded:Connect(function()
    if Enabled and Mode == "Velocity" then
        task.defer(Update)
    end
end)

return Gravity
