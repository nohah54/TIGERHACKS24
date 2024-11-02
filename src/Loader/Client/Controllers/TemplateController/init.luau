--!strict
--!native
--!optimize 2

local PRINT_TAG = "[TemplateController]: [📘]"

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
local TemplateController = {}

function TemplateController:Init()
    print(PRINT_TAG, "Initialized!")
end

-- [Pre-Init]
return function(client)
    if client then
        TemplateController.Client = client
	end

    return TemplateController, "TemplateController"
end