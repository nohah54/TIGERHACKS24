--!strict
--!native
--!optimize 2

local PRINT_TAG = "[ProjectileManager]: [📕]"

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
local ProjectileManager = {}

function ProjectileManager:Init()
    print(PRINT_TAG, "Initialized!")
end

-- [Pre-Init]
return function(server)
    if server then
        ProjectileManager.Server = server
	end

    return ProjectileManager, "ProjectileManager"
end