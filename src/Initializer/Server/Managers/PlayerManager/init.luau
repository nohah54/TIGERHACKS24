--!strict
--!native
--!optimize 2

local PRINT_TAG = "[PlayerManager]: [📕]"

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

-- [Classes]
local CLASS_Player = require(script.Player)

-- [Manager]
local PlayerManager = {
    Players = {}
}

function PlayerManager:Init()
    local _onPlayerAdded = Players.PlayerAdded:Connect(function(player: Player)
        self:OnPlayerAdded(player)
    end)

    local _onPlayerRemoved = Players.PlayerRemoving:Connect(function(player: Player)
        self:OnPlayerRemoved(player)
    end)

    print(PRINT_TAG, "Initialized!")
end

function PlayerManager:OnPlayerAdded(player: Player)
    if self.Players[player] then
        warn(PRINT_TAG, player, "already exists within PlayerManager.Players")
        return
    end

    self.Players[player] = CLASS_Player.new(player, self.Server)
end

function PlayerManager:OnPlayerRemoved(player: Player)
    if not self.Players[player] then
        warn(PRINT_TAG, player,"does not exist within PlayerManager.Players")
        return
    end

    self.Players[player]:Destroy()
    self.Players[player] = nil
end

-- [Pre-Init]
return function(server)
    if server then
        PlayerManager.Server = server
	end

    for _, player in Players:GetPlayers() do
		if player then
			PlayerManager:OnPlayerAdded(player)
		end
	end

    return PlayerManager, "PlayerManager"
end