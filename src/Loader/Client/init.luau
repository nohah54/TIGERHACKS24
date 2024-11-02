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
local FLDR_Remotes = FLDR_Shared.Remotes

-- [Remotes]
local RE_PlayerReady = FLDR_Remotes.RE_PR :: RemoteEvent

-- [Client]
local Client = {}

Client.Controllers = {}

return function()
	Client.MetaData = require(script.Metadata)

	for _, module in FLDR_Controllers:GetChildren() do
		local requiredModule, nameIndex = require(module)(Client)
		Client.Controllers[nameIndex] = requiredModule
	end

	print("Required")
	
	for _, controller in Client.Controllers do
		controller:Init()
	end

	print(PRINT_TAG,"[✅] All controllers initialized!")
	
	RunService.Heartbeat:Connect(function(dt)
		
	end)

	RE_PlayerReady:FireServer()

	print(PRINT_TAG,"[✅] >> READY <<")

	return Client
end