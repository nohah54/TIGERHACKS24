--!strict
--!native
--!optimize 2

local PRINT_TAG = "[EnemyController]: [📘]"

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- [Folders]
local FLDR_Shared = ReplicatedStorage.Shared
local FLDR_Project = workspace.Project
local FLDR_Enemies = FLDR_Project.Enemies
local FLDR_RoundInfo = FLDR_Project.RoundInfo
local FLDR_PlayerTrees = FLDR_Project.PlayerTrees

-- [Assets]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Manager]
local EnemyController = {}

function EnemyController:Init()

    print(PRINT_TAG, "Initialized!")
    FLDR_Enemies.ChildAdded:Connect(function(child)
        local Path = child.EnemyPath
        local Enemy = child.EnemyBox
        local EnemyView = FLDR_Shared.Assets.EnemyFolder.EnemyView:Clone()
        EnemyView.Parent=child
        EnemyView.HumanoidRootPart.Anchored=true
        local WalkAnim = EnemyView.walk.WalkAnim
        local Animator = EnemyView.AnimationController.Animator
        local TargetTree = child.Target.Value
        task.spawn(function()
            local enemyCast

            local function disconnect()
                enemyCast:Disconnect()
            end
            local rayDirection = Vector3.new(0, -150, 0)

            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {FLDR_Enemies}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.IgnoreWater = true
            
            Enemy.CFrame = CFrame.new(Enemy.Position,TargetTree.Position)
            Animator:LoadAnimation(WalkAnim):Play()
            enemyCast = RunService.Heartbeat:Connect(function()
                if Path.Parent then
                    local raycastResult = workspace:Raycast(Path.Position, rayDirection, raycastParams)
                    Enemy.Position= raycastResult.Position + Vector3.new(0,3,0)
                    EnemyView.HumanoidRootPart.CFrame = Enemy.CFrame
                else
                    EnemyView:Destroy()
                    disconnect()
                end
            end)
        end)

    end)

end

-- [Pre-Init]
return function(client)
    if client then
        EnemyController.Client = client
	end

    return EnemyController, "EnemyController"
end