--!strict
--!native
--!optimize 2

local PRINT_TAG = "[Player]: [📕]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared

-- [Player Class]
local CLASS_Player = {}
CLASS_Player.__index = CLASS_Player
CLASS_Player.__class = "CLASS_Player"

export type CLASS_Player = typeof(setmetatable({} :: {
	Server: any,
    Player: Player,
}, CLASS_Player))

function CLASS_Player.new(player: Player, server: any)
	local self : CLASS_Player = setmetatable({
		Server = server,
        Player = player,
	}, CLASS_Player)

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local killValue = Instance.new("NumberValue")
    killValue.Name = "Kills"
    killValue.Parent = leaderstats
	
    print(PRINT_TAG, "Created:", player)

	return self
end

function CLASS_Player:Destroy()
    print(PRINT_TAG, "Destroyed:", self.Player)
end

return CLASS_Player