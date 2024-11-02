--!strict
--!native
--!optimize 2

local PRINT_TAG = "[Tree]: [📕]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared

-- [Tree Class]
local CLASS_Tree = {}
CLASS_Tree.__index = CLASS_Tree
CLASS_Tree.__class = "CLASS_Tree"

export type CLASS_Tree = typeof(setmetatable({} :: {
	Server: any,
    TreeID: number,
    PlayerID: Player?, -- if PlayerID is 'nil', then we assume no player is in control
}, CLASS_Tree))

function CLASS_Tree.new(server: any, treeID: number)
	local self : CLASS_Tree = setmetatable({
		Server = server,
        TreeID = treeID,
        PlayerID = nil,
	}, CLASS_Tree)

	return self
end

function CLASS_Tree:Destroy()
    print(PRINT_TAG, "Destroyed:", self.Player)
end

return CLASS_Tree