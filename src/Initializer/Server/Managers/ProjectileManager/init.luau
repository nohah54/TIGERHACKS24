--!strict
--!native
--!optimize 2

local PRINT_TAG = "[ProjectileManager]: [📕]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Utilities = FLDR_Shared.Utilities
local FLDR_Project = workspace.Project
local FLDR_Projectiles = FLDR_Project.Projectiles
local FLDR_Remotes = FLDR_Shared.Remotes
local FLDR_Assets = FLDR_Shared.Assets

-- [Remotes]
local RE_FireProjectile = FLDR_Remotes.RE_FP :: RemoteEvent

-- [Utilities]
local FastCast = require(FLDR_Utilities.FastCastRedux)
local PartCache = require(FLDR_Utilities.PartCache)

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoconutProjectile = FLDR_Assets.Coconut
local CastParams = RaycastParams.new()
CastParams.IgnoreWater = true
CastParams.FilterType = Enum.RaycastFilterType.Exclude
CastParams.FilterDescendantsInstances = {FLDR_Project.PlayerTrees}
local ProjectilesProvider = PartCache.new(CoconutProjectile, 500, FLDR_Projectiles)
local CastBehavior = FastCast.newBehavior()
CastBehavior.RaycastParams = CastParams
CastBehavior.MaxDistance = 1000
CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default
CastBehavior.CosmeticBulletContainer = FLDR_Projectiles
CastBehavior.CosmeticBulletProvider = ProjectilesProvider
CastBehavior.Acceleration = Vector3.new(0, -workspace.Gravity, 0)
CastBehavior.AutoIgnoreContainer = false

-- [Manager]
local ProjectileManager = {}
ProjectileManager.Casters = {}

function ProjectileManager:Init()
    RE_FireProjectile.OnServerEvent:Connect(function(...)
        self:FireProjectile(...)
    end)

    print(PRINT_TAG, "Initialized!")
end

function ProjectileManager:SetupCasters()
    local server = self.Server
    local managers = server.Managers
    local treeManager = managers["TreeManager"]

    local function Reflect(surfaceNormal, bulletNormal)
        return bulletNormal - (2 * bulletNormal:Dot(surfaceNormal) * surfaceNormal)
    end    

    local function OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
        local hitPart = raycastResult.Instance
        local hitPoint = raycastResult.Position
        local normal = raycastResult.Normal
        if hitPart ~= nil and hitPart.Parent ~= nil then -- Test if we hit something
        print(hitPart)
            if hitPart.Name == "EnemyBox" then
                print("yes hit")
                hitPart.Parent:Destroy()
            end
        end
    end
    
    local function OnRayPierced(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
        local position = raycastResult.Position
        local normal = raycastResult.Normal
        
        local newNormal = Reflect(normal, segmentVelocity.Unit)
        cast:SetVelocity(newNormal * segmentVelocity.Magnitude)
        cast:SetPosition(position)
    end
    
    local function OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
        if cosmeticBulletObject == nil then return end
        local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
        local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
        cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
    end
    
    local function OnRayTerminated(cast)
        local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
        if cosmeticBullet ~= nil then
            if CastBehavior.CosmeticBulletProvider ~= nil then
                CastBehavior.CosmeticBulletProvider:ReturnPart(cosmeticBullet)
            else
                cosmeticBullet:Destroy()
            end
        end
    end
    
    for _, tree in treeManager.Trees do
        local caster = FastCast.new()
        caster.DebugLogging = true
        self.Casters[tree.TreeID] = caster

        caster.RayHit:Connect(OnRayHit)
        caster.RayPierced:Connect(OnRayPierced)
        caster.LengthChanged:Connect(OnRayUpdated)
        caster.CastTerminating:Connect(OnRayTerminated)
    end
end

function ProjectileManager:FireProjectile(player: Player, mousePoint: Vector3)
    local playerID = player.UserId

    local server = self.Server
    local managers = server.Managers
    local treeManager = managers["TreeManager"]

    local treeMatch
    for _, tree in treeManager.Trees do
        if tree.PlayerID == playerID then
            treeMatch = tree
        end
    end

    local mouseDirection = (mousePoint - treeMatch.TreePart.CameraPart.Position).Unit
    local modifiedBulletSpeed = (mouseDirection * 300)

    if not treeMatch then return end

    local caster = self.Casters[treeMatch.TreeID]
    if not caster then return end

    local _projectile = caster:Fire(treeMatch.TreePart.CameraPart.Position, mouseDirection, modifiedBulletSpeed, CastBehavior)
end

-- [Pre-Init]
return function(server)
    if server then
        ProjectileManager.Server = server
	end

    return ProjectileManager, "ProjectileManager"
end