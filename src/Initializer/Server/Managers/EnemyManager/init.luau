--!strict
--!native
--!optimize 2

local PRINT_TAG = "[EnemyManager]: [📕]"

-- [Services]
local ServerStorage = game:GetService("ServerStorage")
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
local EnemySpawnPoint = FLDR_Enemies.EnemySpawnPoint

-- [Utilities]
local Constants = require(FLDR_Shared.Constants)

-- [Constants]
local ROUND_TIME = Constants.ROUND_TIME

-- [Manager]
local EnemyManager = {}

function EnemyManager:Init()
    print(PRINT_TAG, "Initialized!")
    local RoundConfig = FLDR_RoundInfo:WaitForChild("RoundConfig")
    local GameConfig = FLDR_Project:WaitForChild("GameConfig")

    RoundConfig:GetAttributeChangedSignal("Active"):Connect(function()
        local Active = RoundConfig:GetAttribute("Active")
        local CurrentWave= GameConfig:GetAttribute("Round")

        if Active==true then
            print(PRINT_TAG," Enemies of Wave:",CurrentWave,"Spawning")
            local maxEnemies = 40*CurrentWave
            for i=1,maxEnemies do
                task.wait(ROUND_TIME/maxEnemies)
                self:SpawnEnemy()
            end
            print(PRINT_TAG,"Spawning enemy")
        end
    end)

end


function EnemyManager:SpawnEnemy()
    local Server = self.Server
    local Managers = Server.Managers
    local TreeManager = Managers["TreeManager"]
    local TreeArray = FLDR_PlayerTrees:GetChildren()
    local TargetTree = nil
    if not TreeManager:AreTreesAlive() then return end -- game should end soon
    local GameConfig = FLDR_Project:WaitForChild("GameConfig")
    repeat
        local currentTree = FLDR_PlayerTrees:GetChildren()[math.random(1,#TreeArray)]
        if currentTree:GetAttribute("Health")>0 then
           TargetTree = currentTree 
        end
    until TargetTree ~= nil



    local FLDR_Enemy = Instance.new("Folder")
    FLDR_Enemy.Name = "EnemyItems"
    FLDR_Enemy.Parent = FLDR_Enemies
    FLDR_Enemy:SetAttribute("TargetTree",TargetTree.Position)
    local Path = Instance.new("Part")
    Path.Name = "EnemyPath"
    Path.Transparency=1
    Path.Parent = FLDR_Enemy
    Path.Anchored=true
    Path.CanCollide=false

    local Enemy = Instance.new("Part")
    Enemy.Name = "EnemyBox"
    Enemy.Anchored=true
    Enemy.Size= Vector3.new(4,6,2)
    Enemy.Parent = FLDR_Enemy
    Enemy.Parent=FLDR_Enemy
    Enemy.Color = Color3.fromRGB(220,1,1)
    Enemy.Transparency = 1
    Path.CFrame = EnemySpawnPoint.CFrame

    local TargetValue = Instance.new("ObjectValue")
    TargetValue.Name = "Target"
    TargetValue.Value = TargetTree
    TargetValue.Parent = FLDR_Enemy

    local enemyPath =  TweenService:Create(Path,TweenInfo.new(30,Enum.EasingStyle.Linear),{CFrame=TargetTree.CFrame})

    enemyPath:Play()
    task.spawn(function()
        task.wait(25)
        local TargetHealth = TargetTree:GetAttribute("Health")
        if TargetHealth<=0 then
            if not TreeManager:AreTreesAlive() then return end -- game should end soon
            print(PRINT_TAG,"switching targeted tree")
            TargetTree=nil
            repeat
                local currentTree = FLDR_PlayerTrees:GetChildren()[math.random(1,#TreeArray)]
                if currentTree:GetAttribute("Health")>0 then
                    TargetTree = currentTree 
                end
                if GameConfig:GetAttribute("Active") == false then
                    FLDR_Enemy:Destroy()
                    break
                end
            until TargetTree ~= nil
            if FLDR_Enemy then
                enemyPath:Pause()
                local distance = (Path.Position-TargetTree.Position).Magnitude
                enemyPath = TweenService:Create(Path,TweenInfo.new(distance/10,Enum.EasingStyle.Linear),{CFrame=TargetTree.CFrame})
                enemyPath:Play()
            end
        end
    end)

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
        enemyCast = RunService.Heartbeat:Connect(function()
            if Path.Parent then
                local raycastResult = workspace:Raycast(Path.Position, rayDirection, raycastParams)
                Enemy.Position= raycastResult.Position + Vector3.new(0,3,0)
            else
                Enemy:Destroy()
                disconnect()
            end
        end)
    end)

    enemyPath.Completed:Connect(function()
        if (Path.Position-TargetTree.Position).Magnitude <= 5 then
            print(PRINT_TAG,"Enemy should be deleted")
            local currentHealth = TargetTree:GetAttribute("Health")
            TargetTree:SetAttribute("Health",currentHealth-1)
            if currentHealth<=1 then
                if TargetTree:FindFirstChild("TreeModel") then  
                    TargetTree.TreeModel.Anchored=false
                    
                end
            end
            print(PRINT_TAG,"Enemy is getting destroyed")
            FLDR_Enemy:Destroy()
        else
            print(PRINT_TAG,"tweenservice was completed but shouldn't get deleted")
        end
    end)
end

-- [Pre-Init]
return function(server)
    if server then
        EnemyManager.Server = server
	end

    return EnemyManager, "EnemyManager"
end