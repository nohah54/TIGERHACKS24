--!strict
--!native
--!optimize 2

local PRINT_TAG = "[CameraController]: [📘]"

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
local CameraController = {}

function CameraController:Init()
    print(PRINT_TAG, "Initialized!")
end

-- [Pre-Init]
return function(client)
    if client then
        CameraController.Client = client
	end

    return CameraController, "CameraController"
end