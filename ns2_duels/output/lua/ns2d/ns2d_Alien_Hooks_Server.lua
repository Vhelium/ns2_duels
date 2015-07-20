
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
		        Shared.Message("SERVER: AlienTeam.Update: owner["..index.."] found.")
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

Class_ReplaceMethod("Alien", "ProcessBuyAction", function(self, techIds)

    ASSERT(type(techIds) == "table")

    local success = false
    
    if GetGamerules():GetGameStarted() then
    
        local healthScalar = self:GetHealth() / self:GetMaxHealth()
        local armorScalar = self:GetMaxArmor() == 0 and 1 or self:GetArmor() / self:GetMaxArmor()
        local totalCosts = 0
        
        local upgradeIds = {}
        local lifeFormTechId = nil
	    for _, techId in ipairs(techIds) do
	        
	        if LookupTechData(techId, kTechDataGestateName) then
	            lifeFormTechId = techId
	        else
	            table.insertunique(upgradeIds, techId)
	        end
	        
	    end

        local oldLifeFormTechId = self:GetTechId()
        
        local upgradesAllowed = true
        local upgradeManager = AlienUpgradeManager()
        upgradeManager:Populate(self)
        -- add this first because it will allow switching existing upgrades
        if lifeFormTechId then
            upgradeManager:AddUpgrade(lifeFormTechId)
        end

        for _, newUpgradeId in ipairs(techIds) do
            if newUpgradeId ~= kTechId.None and not upgradeManager:AddUpgrade(newUpgradeId, true) then
                upgradesAllowed = false 
                break
            end
            
        end

        if upgradesAllowed then
        
            // Check for room
            local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
            local newLifeFormTechId = upgradeManager:GetLifeFormTechId()
            local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
            local physicsMask = PhysicsMask.Evolve
            local position = self:GetOrigin()
            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
            local evolveAllowed = self:GetIsOnGround()
            evolveAllowed = evolveAllowed and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)
            evolveAllowed = evolveAllowed and GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, position + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)
            
            -- If not on the ground for the buy action, attempt to automatically
            -- put the player on the ground in an area with enough room for the new Alien.
            if not evolveAllowed then
            
                for index = 1, 100 do
                
                    local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                    if spawnPoint then
                    
                        self:SetOrigin(spawnPoint)
                        position = spawnPoint
                        evolveAllowed = true
                        break
                        
                    end
                    
                end
                
            end

            if evolveAllowed then

                local newPlayer = self:Replace(Embryo.kMapName)
                position.y = position.y + Embryo.kEvolveSpawnOffset
                newPlayer:SetOrigin(position)
                
                -- Clear angles, in case we were wall-walking or doing some crazy alien thing
                local angles = Angles(self:GetViewAngles())
                angles.roll = 0.0
                angles.pitch = 0.0
                newPlayer:SetOriginalAngles(angles)
                
                -- Eliminate velocity so that we don't slide or jump as an egg
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
end)