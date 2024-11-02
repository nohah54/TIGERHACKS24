--!strict
--!native
--!optimize 2

local PRINT_TAG = "[GameManager]: [📕]"

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
local GameManager = {}

function GameManager:Init()
    local Server = self.Server
    local Managers = Server.Managers
    local RoundManager = Managers["RoundManager"]

    

    print(PRINT_TAG, "Initialized!")
end

-- [Pre-Init]
return function(server)
    if server then
        GameManager.Server = server
	end

    return GameManager, "GameManager"
end