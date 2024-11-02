--!strict
--!native
--!optimize 2

local PRINT_TAG = "[RoundManager]: [📕]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Project = workspace.Project
local FLDR_RoundInfo = FLDR_Project.RoundInfo

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Manager]
local RoundManager = {}

function RoundManager:Init()
    
    -- initialize round config object (easy replication for clients)
    self.RoundConfig = Instance.new("Configuration")
    self.RoundConfig.Name = "RoundConfig"
    self.RoundConfig.Parent = FLDR_RoundInfo

    -- round thread
    self.RoundThread = task.spawn(function() self:Loop() end)

    print(PRINT_TAG, "Initialized!")
end

function RoundManager:Loop()
    while task.wait(1) do
        
    end
end

-- [Pre-Init]
return function(server)
    if server then
        RoundManager.Server = server
	end

    return RoundManager, "RoundManager"
end