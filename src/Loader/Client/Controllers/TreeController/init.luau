--!strict
--!native
--!optimize 2

local PRINT_TAG = "[TreeController]: [📘]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Utilities = FLDR_Shared.Utilities
local FLDR_Project = workspace.Project

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Utilities]
--local CameraService = require(FLDR_Utilities.CameraService)

-- [Enums]
local _Enums = require(FLDR_Shared.Enums)
local TREE_STATES = _Enums.TREE_STATES

-- [Fusion]
local Fusion = require(FLDR_Utilities.Fusion)
local Value = Fusion.Value
local Observer = Fusion.Observer

-- [Manager]
local TreeController = {}

function TreeController:Init()
    local client = self.Client
    local metadata = client.MetaData
    local values = metadata.Values

    local gameConfig = FLDR_Project.GameConfig

    -- listen to changes to tree values
    local _onTreeStateChange = Observer(values.TreeState):onChange(function() 
        local treeState = values.TreeState:get()

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

    print(PRINT_TAG, "Initialized!")
end

function TreeController:SetState(state: number)
    local client = self.Client
    local metadata = client.MetaData
    local values = metadata.Values

    values.TreeState:set(state)
end

function TreeController:Handle_OutOfGame()
    print(PRINT_TAG, "Out of Game")
end

function TreeController:Handle_ControllingTree()
    print(PRINT_TAG, "Controlling Tree")
end

function TreeController:Handle_SelectingTree()
    print(PRINT_TAG, "Selecting Tree")
end

-- [Pre-Init]
return function(client)
    if client then
        TreeController.Client = client
	end

    return TreeController, "TreeController"
end