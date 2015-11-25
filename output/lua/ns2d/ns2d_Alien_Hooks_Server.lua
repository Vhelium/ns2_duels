
Script.Load("lua/AlienTeam.lua")
Script.Load("lua/Egg.lua")

local UpdateCystConstruction = GetLocalFunction(AlienTeam.Update, "UpdateCystConstruction")

Class_ReplaceMethod("AlienTeam", "Update", function (self, timePassed)
    PlayingTeam.Update(self, timePassed)
    
    self:UpdateTeamAutoHeal(timePassed)
    
    local shellLevel = 3
    for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
    	if alien:GetIsAlive() then
		    local grpId = -1
		    local owner = Server.GetOwner(alien) -- the client object
		    if owner then
		        grpId = RoomManager:GetGroupFromPlayer(owner:GetUserId())
		    else
		        Shared.Message("SERVER: AlienTeam.Update: owner["..index.."] == nil??")
		    end
	        alien:UpdateArmorAmount(shellLevel)
	        alien:UpdateHealthAmount(math.min(12, RoomManager.upgradesOfGroup[grpId].BiomassLevel), self:GetMaxBioMassLevel())
	    end
    end
    
    UpdateCystConstruction(self, timePassed)
end)

Class_ReplaceMethod("AlienTeam", "SpawnInitialStructures", function (self, techPoint)
    local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()
    
    return tower, hive
end)

Class_ReplaceMethod("AlienTeam", "GetNumHives", function (self)
	return 6
end)

Class_ReplaceMethod("AlienTeam", "GetBioMassLevel", function (self)
	return 12
end)

Class_ReplaceMethod("AlienTeam", "GetMaxBioMassLevel", function (self)
	return 12
end)

Class_ReplaceMethod("Egg", "SpawnPlayer", function (self, player)
    -- nothing :>
end)

Class_ReplaceMethod("Exo", "GetCanEject", function (self, player)
	return false
end)

Class_ReplaceMethod("CommandStructure", "UpdateCommanderLogin", function (self, force)
	self.occupied = true
    self.commanderId = Entity.invalidId
end)

-- OVERRRIDE for faster evolve
function GetAlienCatalystTimeAmount(baseTime, entity)
    return baseTime*100
end

Class_ReplaceMethod("AlienUpgradeManager", "GetCanAffordUpgrade", function(self, upgradeId) return true end)

local function OnMessageEvolve(client, buyMessage)

    local player = client:GetControllingPlayer()
    
    -- TODO: check if alien :D
    if player and player:GetIsAllowedToBuy() then
    
        local purchaseTechIds = ParseBuyMessage(buyMessage)
        player:ProcessEvolveAction(purchaseTechIds)
        
    end
    
end

Server.HookNetworkMessage("Evolve", OnMessageEvolve)

-- choose a lifeforms and some upgrades
function Alien:ProcessEvolveAction(techIds)

    ASSERT(type(techIds) == "table")
    ASSERT(table.count(techIds) > 0)

    local success = false
    
    if GetGamerules():GetGameStarted() then
    
        local healthScalar = self:GetHealth() / self:GetMaxHealth()
        local armorScalar = self:GetMaxArmor() == 0 and 1 or self:GetArmor() / self:GetMaxArmor()
        
        local upgradeIds = {}
        -- pre default, we dont want to buy a new lifeform
        local lifeFormTechId = nil
        for _, techId in ipairs(techIds) do
            
            if LookupTechData(techId, kTechDataGestateName) then
                -- life form techId
                lifeFormTechId = techId
            else
                -- upgrade techId
                table.insertunique(upgradeIds, techId)
            end
            
        end

        local oldLifeFormTechId = self:GetTechId()
        
        local upgradesAllowed = true
        local upgradeManager = AlienUpgradeManager()
        -- clear existing upgrades
        self:ClearUpgrades()
        upgradeManager:Populate(self)
        -- clean any previous custom upgrades :>
        upgradeManager:RemoveUpgrade(oldLifeFormTechId)
        -- The 'new' lifeform
        -- Add this first because it will allow switching existing upgrades
        if lifeFormTechId then
            upgradeManager:AddUpgrade(lifeFormTechId)
        end
        for _, newUpgradeId in ipairs(techIds) do

            if newUpgradeId ~= kTechId.None and not upgradeManager:AddUpgrade(newUpgradeId, true) then
                upgradesAllowed = false 
                break
            end
            
        end

        local position = self:GetOrigin()
        local trace = Shared.TraceRay(position, position + Vector(0, -0.5, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
        
        if upgradesAllowed and trace.surface ~= "no_evolve" then
        
            -- Check for room
            local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
            local newLifeFormTechId = upgradeManager:GetLifeFormTechId()
            local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
            local physicsMask = PhysicsMask.Evolve
            
            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
            local evolveAllowed = self:GetIsOnGround() and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)

            local roomAfter
            local spawnPoint
       
            -- If not on the ground for the buy action, attempt to automatically
            -- put the player on the ground in an area with enough room for the new Alien.
            if not evolveAllowed then
            
                for index = 1, 100 do
                
                    spawnPoint = GetRandomSpawnForCapsule(eggExtents.y, math.max(eggExtents.x, eggExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
  
                    if spawnPoint then
                        self:SetOrigin(spawnPoint)
                        position = spawnPoint
                        break 
                    end
                    
                end
                

            end
            
            if not GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self:GetOrigin() + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, nil, EntityFilterOne(self)) then
           
                for index = 1, 100 do

                    roomAfter = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                    
                    if roomAfter then
                        evolveAllowed = true
                        break
                    end

                end
                
            else
                roomAfter = position
                evolveAllowed = true
            end
            
            if evolveAllowed and roomAfter ~= nil then

                local newPlayer = self:Replace(Embryo.kMapName)
                position.y = position.y + Embryo.kEvolveSpawnOffset
                newPlayer:SetOrigin(position)
                
                -- Clear angles, in case we were wall-walking or doing some crazy alien thing
                local angles = Angles(self:GetViewAngles())
                angles.roll = 0.0
                angles.pitch = 0.0
                newPlayer:SetOriginalAngles(angles)
                newPlayer:SetValidSpawnPoint(roomAfter)
                
                -- Eliminate velocity so that we dont slide or jump as an egg
                newPlayer:SetVelocity(Vector(0, 0, 0))                
                newPlayer:DropToFloor()
                
                newPlayer:SetResources(upgradeManager:GetAvailableResources())
                newPlayer:SetGestationData(upgradeManager:GetUpgrades(), self:GetTechId(), self:GetHealthFraction(), self:GetArmorScalar())
                
                if oldLifeFormTechId and lifeFormTechId and oldLifeFormTechId ~= lifeFormTechId then
                    newPlayer.oneHive = false
                    newPlayer.twoHives = false
                    newPlayer.threeHives = false
                end
                
                success = true
                
            end    
            
        end
    
    end
    
    if not success then
        self:TriggerInvalidSound()
    end    
    
    return success
    
end

local orig_atiOnUpdate
orig_atiOnUpdate = Class_ReplaceMethod("AlienTeamInfo", "OnUpdate", function(self, deltaTime)
    orig_atiOnUpdate(self, deltaTime)
    self.veilLevel = 3
    self.spurLevel = 3
    self.shellLevel = 3
end)