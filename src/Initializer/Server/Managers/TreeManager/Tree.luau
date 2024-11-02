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
    TreePart: BasePart,
    PlayerID: number, -- if PlayerID is 'nil', then we assume no player is in control
}, CLASS_Tree))

function CLASS_Tree.new(server: any, treePart: BasePart)
	local self : CLASS_Tree = setmetatable({
		Server = server,
        TreeID = treePart:GetAttribute("TreeID") :: number,
        TreePart = treePart,
        PlayerID = 0,
	}, CLASS_Tree)

    treePart:GetAttributeChangedSignal("PlayerID"):Connect(function() 
        self.PlayerID = treePart:GetAttribute("PlayerID") :: number

        if self.PlayerID == 0 then
            print(PRINT_TAG, "No Occupant")
        else
            print(PRINT_TAG, self.PlayerID, "Controlling!")
        end
    end)

	return self
end

function CLASS_Tree:Destroy()
    print(PRINT_TAG, "Destroyed:", self.Player)
end

return CLASS_Tree