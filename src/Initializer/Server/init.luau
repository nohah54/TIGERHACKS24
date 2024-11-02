--!strict
--!native
--!optimize 2

local PRINT_TAG = "[Server]: [📕]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Managers = script.Managers

-- [Server]
local Server = {}

Server.Managers = {}
Server.Metadata = {
	Values = {},
}

return function()
	for _, module in FLDR_Managers:GetChildren() do
		local requiredModule, nameIndex = require(module)(Server)
		Server.Managers[nameIndex] = requiredModule
	end
	
	for _, controller in Server.Managers do
		controller:Init()
	end

	print(PRINT_TAG, "[✅] All managers initialized!")
	
	RunService.Heartbeat:Connect(function(dt)
		
	end)

	print(PRINT_TAG,"[✅] >> READY <<")

	return Server
end