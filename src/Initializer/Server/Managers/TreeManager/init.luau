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
local FLDR_Remotes = FLDR_Shared.Remotes

-- [Remotes]
local RF_RequestControl = FLDR_Remotes.RF_RC :: RemoteFunction
local RE_UnselectTree = FLDR_Remotes.RE_UT :: RemoteEvent

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Classes]
local CLASS_Tree = require(script.Tree)

-- [Manager]
local TreeManager = {}
TreeManager.Trees = {} :: {[number]: CLASS_Tree.CLASS_Tree}

function TreeManager:Init()
    local server = self.Server
    local managers = server.Managers
    local projectileManager = managers["ProjectileManager"]

    local function initializeTrees()
        for _, tree in FLDR_PlayerTrees:GetChildren() do
            local treeID = tree:GetAttribute("TreeID")
            local treeData = CLASS_Tree.new(server,tree)
            self.Trees[treeID] = treeData
        end
    end

    RF_RequestControl.OnServerInvoke = function(...) 
        return self:OnControlRequested(...)
    end

    RE_UnselectTree.OnServerEvent:Connect(function(...)
        self:UnselectTree(...)
    end)

    initializeTrees()

    projectileManager:SetupCasters()
    
    print(PRINT_TAG, "Initialized!")
end

function TreeManager:UnselectTree(player: Player)
    local playerID = player.UserId

    for _, tree in self.Trees do
        if tree.PlayerID == playerID then
            tree.TreePart:SetAttribute("PlayerID", 0)
            print(PRINT_TAG, "setting to 0")
        end
    end
end

function TreeManager:OnControlRequested(player: Player, treeID: number)
    local playerID = player.UserId

    local treeData = self.Trees[treeID]
    if not treeData then 
        warn(PRINT_TAG, "Tree does not exist:", treeID)
        return false
    end

    print(treeData)
    if treeData.PlayerID > 0 then
        print(PRINT_TAG, "Tree Occupied")
        return false
    end

    treeData.TreePart:SetAttribute("PlayerID", playerID)

    return true
end

function TreeManager:AreTreesAlive()
    local treesAlive = false
    for _, tree in FLDR_PlayerTrees:GetChildren() do
        local health = tree:GetAttribute("Health")
        if health>0 then
            treesAlive=true
            break
        end
    end
    return treesAlive
end

-- [Pre-Init]
return function(server)
    if server then
        TreeManager.Server = server
	end

    return TreeManager, "TreeManager"
end