--!strict
--!native
--!optimize 2

local PRINT_TAG = "[Client]: [📘]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Controllers = script.Controllers
local FLDR_Utilities = FLDR_Shared.Utilities

-- [Fusion]
local Fusion = require(FLDR_Utilities.Fusion)
local Value = Fusion.Value

-- [Metadata]

local Metadata = {
    Values = {

    }
}

return Metadata