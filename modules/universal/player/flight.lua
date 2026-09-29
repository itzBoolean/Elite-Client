--// Flight Module
--// Usage:
--// local Flight = loadstring(game:HttpGet("PASTEBIN_RAW_URL"))()
--//
--// Flight.Enable()
--// Flight.Disable()
--// Flight.SetHSpeed(80)
--// Flight.SetVSpeed(80)

local genv = getgenv()

-- Prevent duplicate module state when loadstring is executed again.
if genv.__FlightModule then
    local existing = genv.__FlightModule

    if existing._Connection then
        existing._Connection:Disconnect()
        existing._Connection = nil
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Flight = {
    _Enabled = false,
    _HSpeed = 50,
    _VSpeed = 50,
    _Connection = nil,
}

local function getCharacter()
    local character = LocalPlayer.Character

    if not character then
        return nil, nil, nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    return character, root, humanoid
end

local function getCamera()
    return workspace.CurrentCamera
end

local function stopConnection()
    if Flight._Connection then
        Flight._Connection:Disconnect()
        Flight._Connection = nil
    end
end

local function resetVelocity()
    local _, root = getCharacter()

    if root then
        local velocity = root.AssemblyLinearVelocity

        root.AssemblyLinearVelocity = Vector3.new(
            velocity.X,
            0,
            velocity.Z
        )
    end
end

function Flight.Enable()
    if Flight._Enabled then
        return
    end

    Flight._Enabled = true

    stopConnection()

    Flight._Connection = RunService.PreSimulation:Connect(function()
        if not Flight._Enabled then
            return
        end

        local character, root, humanoid = getCharacter()

        if not character or not root or not humanoid then
            return
        end

        local camera = getCamera()

        if not camera then
            return
        end

        local moveDirection = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection += camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection -= camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection -= camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection += camera.CFrame.RightVector
        end

        -- Prevent camera pitch from affecting horizontal flight.
        moveDirection = Vector3.new(
            moveDirection.X,
            0,
            moveDirection.Z
        )

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * Flight._HSpeed
        end

        local verticalVelocity = 0

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            verticalVelocity = Flight._VSpeed
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            verticalVelocity = -Flight._VSpeed
        end

        root.AssemblyLinearVelocity = Vector3.new(
            moveDirection.X,
            verticalVelocity,
            moveDirection.Z
        )
    end)
end

function Flight.Disable()
    if not Flight._Enabled then
        stopConnection()
        return
    end

    Flight._Enabled = false

    stopConnection()
    resetVelocity()
end

function Flight.SetHSpeed(value)
    value = tonumber(value)

    if not value then
        return
    end

    Flight._HSpeed = math.max(0, value)
end

function Flight.SetVSpeed(value)
    value = tonumber(value)

    if not value then
        return
    end

    Flight._VSpeed = math.max(0, value)
end

function Flight.GetHSpeed()
    return Flight._HSpeed
end

function Flight.GetVSpeed()
    return Flight._VSpeed
end

function Flight.IsEnabled()
    return Flight._Enabled
end

-- Store the module in getgenv so its state can be accessed
-- consistently after loadstring execution.
genv.__FlightModule = Flight

return Flight
