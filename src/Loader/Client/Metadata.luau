--!strict
--!native
--!optimize 2

local PRINT_TAG = "[Client]: [📘]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Utilities = FLDR_Shared.Utilities

-- [Enums]
local _Enums = require(FLDR_Shared.Enums)
local TREE_STATES = _Enums.TREE_STATES

-- [Fusion]
local Fusion = require(FLDR_Utilities.Fusion)
local Value = Fusion.Value

-- [Metadata]

local Metadata = {
    Values = {
        TreeState = Value(TREE_STATES.OUT_OF_GAME)
    }
}

return Metadata