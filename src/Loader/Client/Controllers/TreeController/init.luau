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

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Manager]
local TreeController = {}

function TreeController:Init()
    print(PRINT_TAG, "Initialized!")
end

-- [Pre-Init]
return function(client)
    if client then
        TreeController.Client = client
	end

    return TreeController, "TreeController"
end