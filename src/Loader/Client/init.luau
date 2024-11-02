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

-- [Client]
local Client = {}

Client.Controllers = {}
Client.Metadata = {
	Values = {},
}

return function()
	for _, module in FLDR_Controllers:GetChildren() do
		local requiredModule, nameIndex = require(module)(Client)
		Client.Controllers[nameIndex] = requiredModule
	end
	
	for _, controller in Client.Controllers do
		controller:Init()
	end
	
	RunService.Heartbeat:Connect(function(dt)
		
	end)

	print(PRINT_TAG,"[✅] All systems initialized!")

	return Client
end