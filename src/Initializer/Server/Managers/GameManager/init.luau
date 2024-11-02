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
local FLDR_Remotes = FLDR_Shared.Remotes
local FLDR_Project = game.Workspace.Project

-- [Remotes]
local RE_PlayerReady = FLDR_Remotes.RE_PR :: RemoteEvent

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Utilities]
local Constants = require(FLDR_Shared.Constants)

-- [Constants]
local MAX_WAVES = Constants.MAX_WAVES

-- [Manager]
local GameManager = {}
GameManager.ReadyPlayers = {}

function GameManager:Init()
    local Server = self.Server
    local Managers = Server.Managers
    local RoundManager = Managers["RoundManager"]
    local PlayerManager = Managers["PlayerManager"]

    self.GameConfig = Instance.new("Configuration")
    self.GameConfig.Name = "GameConfig"
    self.GameConfig.Parent = FLDR_Project

    self.GameConfig:SetAttribute("Active", false)
    self.GameConfig:SetAttribute("Round",-1)

    local _onPlayerReady = RE_PlayerReady.OnServerEvent:Connect(function(player: Player) 
        self.ReadyPlayers[player] = true
        
        if self.GameConfig:GetAttribute("Active") == false then
            self:StartGame()
        end
    end)

    print(PRINT_TAG, "Initialized!")
end

function GameManager:StartGame()
    if self.GameConfig:GetAttribute("Active") == true then return end

    self.GameConfig:SetAttribute("Active", true)
    
    print(PRINT_TAG, "Starting Game")

    local Server = self.Server
    local Managers = Server.Managers
    local RoundManager = Managers["RoundManager"]
    local RoundConfig = FLDR_Project.RoundInfo.RoundConfig

    local currRound = task.spawn(function() RoundManager:Loop() end)
    print(PRINT_TAG, "Starting First Round")

    RoundConfig:GetAttributeChangedSignal("Active"):Connect(function()
        local Active = RoundConfig:GetAttribute("Active")
        if Active==false then
            local RoundNum = self.GameConfig:GetAttribute("Round")
            if RoundNum < MAX_WAVES and RoundNum>0 then
                print(PRINT_TAG, "Starting New Round")
                task.spawn(function() RoundManager:Loop() end)
            else
                self.EndGame()
            end
        else
            print(PRINT_TAG, "Round Ongoing")
        end
    end)
end

function GameManager:EndGame()
    if self.GameConfig:GetAttribute("Active") == false then return end

    self.GameConfig:SetAttribute("Active", false)
end

-- [Pre-Init]
return function(server)
    if server then
        GameManager.Server = server
	end

    return GameManager, "GameManager"
end