--!strict
--!native
--!optimize 2

local PRINT_TAG = "[EnemyManager]: [📕]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Manager]
local EnemyManager = {}

function EnemyManager:Init()
    print(PRINT_TAG, "Initialized!")
end

-- [Pre-Init]
return function(server)
    if server then
        EnemyManager.Server = server
	end

    return EnemyManager, "EnemyManager"
end