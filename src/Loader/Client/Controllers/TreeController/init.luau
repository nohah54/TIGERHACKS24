--!strict
--!native
--!optimize 2

local PRINT_TAG = "[TreeController]: [📘]"

-- [Services]
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Utilities = FLDR_Shared.Utilities
local FLDR_Project = workspace.Project
local FLDR_Cameras = FLDR_Project.Cameras
local FLDR_Remotes = FLDR_Shared.Remotes

-- [Remotes]
local RF_RequestControl  = FLDR_Remotes.RF_RC :: RemoteFunction
local RE_UnselectTree = FLDR_Remotes.RE_UT :: RemoteEvent
local RE_FireProjectile = FLDR_Remotes.RE_FP :: RemoteEvent

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()
local Highlight = Instance.new("Highlight")
Highlight.FillTransparency = 1
Highlight.OutlineTransparency = 0
local Select = game.SoundService.Select
local Hover = game.SoundService.Hover
local Poof = game.SoundService.Poof

-- [Utilities]
local CameraService = require(FLDR_Utilities.CameraService)

-- [Enums]
local _Enums = require(FLDR_Shared.Enums)
local TREE_STATES = _Enums.TREE_STATES
local TWEEN_INFO = TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- [Fusion]
local Fusion = require(FLDR_Utilities.Fusion)
local New = Fusion.New
local Value = Fusion.Value
local Observer = Fusion.Observer

-- [Manager]
local TreeController = {}

function TreeController:Init()
    local client = self.Client
    local metadata = client.MetaData
    local values = metadata.Values

    local gameConfig = FLDR_Project.GameConfig

    Camera.FieldOfView = 0

    -- listen to changes to tree values
    local _onTreeStateChange = Observer(values.TreeState):onChange(function() 
        local treeState = values.TreeState:get()

        if self.MainThread then
            self.MainThread:Disconnect()

            self.MainThread = nil
        end

        if treeState == TREE_STATES.OUT_OF_GAME then
            self:Handle_OutOfGame()
        elseif treeState == TREE_STATES.CONTROLLING_TREE then
            self:Handle_ControllingTree()
        elseif treeState == TREE_STATES.SELECTING_TREE then
            self:Handle_SelectingTree()
        end
    end)

    -- listen to game state changes
    local _onActiveChanged = gameConfig:GetAttributeChangedSignal("Active"):Connect(function() 
        local isActive = gameConfig:GetAttribute("Active")
        print(PRINT_TAG, "Active =", isActive)

        self:SetState(TREE_STATES.SELECTING_TREE)
    end)
    
    local function handleAction(actionName, inputState, inputObject)
        if actionName == "SELECTING_MODE" then
            if inputState == Enum.UserInputState.End and values.TreeState:get() == TREE_STATES.CONTROLLING_TREE then
                self:SetState(TREE_STATES.SELECTING_TREE)
                RE_UnselectTree:FireServer()
                Select:Play()
            end
        end
    end

    local _onFocusedTreeChange = Observer(values.TreeFocus):onChange(function()
        local tree = values.TreeFocus:get()

        if tree then
            Hover:Play()
            Highlight.Parent = tree.TreeModel
        else
            Highlight.Parent = ReplicatedStorage
        end

    end)

    ContextActionService:BindAction("SELECTING_MODE", handleAction, true, Enum.KeyCode.Backspace)

    self:Handle_OutOfGame()

    print(PRINT_TAG, "Initialized!")
end

function TreeController:SetState(state: number)
    local client = self.Client
    local metadata = client.MetaData
    local values = metadata.Values

    values.TreeState:set(state)
end

function TreeController:Handle_OutOfGame()
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CameraSubject = FLDR_Cameras.OutOfGameCamera

    TweenService:Create(Camera, TWEEN_INFO, {CFrame = FLDR_Cameras.SelectingCamera.CFrame, FieldOfView = 40}):Play()

    print(PRINT_TAG, "Out of Game")
end

function TreeController:Handle_ControllingTree()
    local client = self.Client
    local metadata = client.MetaData
    local values = metadata.Values

    local focusedTree = values.TreeFocus:get()
    local previousControlledTree = values.ControlledTree:get()

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    if previousControlledTree then
        TweenService:Create(previousControlledTree.TreeModel, tweenInfo, {Transparency = 0}):Play()
    end


    Highlight.Parent = ReplicatedStorage
    values.ControlledTree:set(focusedTree)

    local controlledTree = focusedTree
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CameraSubject = controlledTree.CameraPart

    TweenService:Create(Camera, TWEEN_INFO, {FieldOfView = 70}):Play()
    TweenService:Create(controlledTree.TreeModel, tweenInfo, {Transparency = 0.75}):Play()

    Camera.CFrame = controlledTree.CameraPart.CFrame
    Camera.CameraType = Enum.CameraType.Follow

    -- 
    local lastShot = tick()
    self.MainThread = RunService.Heartbeat:Connect(function(dt: number)
        local buttons = UserInputService:GetMouseButtonsPressed()

        local m1Pressed = false
        for _, button in pairs(buttons) do
            if button.UserInputType.Name == "MouseButton1" then
                m1Pressed = true
            end
        end

        if not m1Pressed then return end

        if (tick() - lastShot) > 0.1 then
            lastShot = tick()

            RE_FireProjectile:FireServer(Mouse.Hit.Position)
            Poof:Play()
        end
    end)

    print(PRINT_TAG, "Controlling Tree")
end

function TreeController:Handle_SelectingTree()
    local client = self.Client
    local metadata = client.MetaData
    local values = metadata.Values

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CameraSubject = FLDR_Cameras.SelectingCamera
    
    TweenService:Create(Camera, TWEEN_INFO, {CFrame = FLDR_Cameras.SelectingCamera.CFrame, FieldOfView = 40}):Play()

    local lastRequested = tick()
    local requesting = false

    local previousControlledTree = values.ControlledTree:get()

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    if previousControlledTree then
        TweenService:Create(previousControlledTree.TreeModel, tweenInfo, {Transparency = 0}):Play()
    end

    self.MainThread = RunService.Heartbeat:Connect(function(dt: number)
        local target = Mouse.Target
         
        if not target then return end
        if not (target.Name == "Tree") then return end

        values.TreeFocus:set(target)

        local buttons = UserInputService:GetMouseButtonsPressed()

        local m1Pressed = false
        for _, button in pairs(buttons) do
            if button.UserInputType.Name == "MouseButton1" then
                m1Pressed = true
            end
        end

        if not m1Pressed then return end
        local playerID = target:GetAttribute("PlayerID")
        local treeID = target:GetAttribute("TreeID")
        if playerID > 0 then return end

        if (tick() - lastRequested) > 1 and not requesting then
            lastRequested = tick()
            requesting = true

            print(PRINT_TAG, "Requesting !")

            local canControl = RF_RequestControl:InvokeServer(treeID)
            
            requesting = false

            if canControl then
                self:SetState(TREE_STATES.CONTROLLING_TREE)
            end
        end
    end)


    print(PRINT_TAG, "Selecting Tree")
end

-- [Pre-Init]
return function(client)
    if client then
        TreeController.Client = client
	end

    return TreeController, "TreeController"
end