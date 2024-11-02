--!strict
--!native
--!optimize 2

local PRINT_TAG = "[TreeManager]: [📕]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Project = workspace.Project
local FLDR_PlayerTrees = FLDR_Project.PlayerTrees

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Classes]
local CLASS_Tree = require(script.Tree)

-- [Manager]
local TreeManager = {}
TreeManager.Trees = {} :: {[number]: CLASS_Tree.CLASS_Tree}

function TreeManager:Init()
    local function initializeTrees()
        for _, tree in FLDR_PlayerTrees:GetChildren() do
            local treeID = tree:GetAttribute("TreeID")
            local treeData = CLASS_Tree.new(server,treeID)
            self.Trees[treeID] = treeData
        end
    end

    print(PRINT_TAG, "Initialized!")
end

-- [Pre-Init]
return function(server)
    if server then
        TreeManager.Server = server
	end

    return TreeManager, "TreeManager"
end