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

-- [Utilities]
local Constants = require(FLDR_Shared.Constants)

-- [Constants]
local MAX_WAVES = Constants.MAX_WAVES
local ROUND_TIME = Constants.ROUND_TIME

-- [Manager]
local RoundManager = {}
function RoundManager:Init()
    
    -- initialize round config object (easy replication for clients)
    self.RoundConfig = Instance.new("Configuration")
    self.RoundConfig.Name = "RoundConfig"
    self.RoundConfig.Parent = FLDR_RoundInfo

    self.RoundConfig:SetAttribute("Active", false)
    self.RoundConfig:SetAttribute("Timer", 0)
    self.RoundConfig:SetAttribute("Wave", 0)

    -- round thread
    -- todo: 
        -- round timer, wave-based
        -- 60s maybe
    self:Setup()
    --self.RoundThread = task.spawn(function() self:Loop() end)

    print(PRINT_TAG, "Initialized!")
end

function RoundManager:Setup()
    self.RoundConfig:SetAttribute("Active", false)
    self.RoundConfig:SetAttribute("Timer", ROUND_TIME)
end

function RoundManager:Loop()
    local Server = self.Server
    local Managers = Server.Managers
    local TreeManager = Managers["TreeManager"]
    local GameManager = Managers["GameManager"]

    local RoundTimer = ROUND_TIME
    self.RoundConfig:SetAttribute("Active", true)
    print(PRINT_TAG, "Starting Loop")
    while task.wait(1) do 
        RoundTimer-=1
        self.RoundConfig:SetAttribute("Timer",RoundTimer)
        if RoundTimer <= 0 then
            break
        end
        if not TreeManager:AreTreesAlive() then
            GameManager:EndGame()
            break
        end
    end
    self.RoundConfig:SetAttribute("Active", false)
    print(PRINT_TAG, "Stopping Loop")
end

-- [Pre-Init]
return function(server)
    if server then
        RoundManager.Server = server
	end

    return RoundManager, "RoundManager"
end