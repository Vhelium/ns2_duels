
Script.Load("lua/MarineTeam.lua")

Class_ReplaceMethod("MarineTeam", "SpawnInitialStructures", function (self, techPoint)
    -- Don't spawn any IP!!
    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    return tower, commandStation
end)

Class_ReplaceMethod("Egg", "SpawnPlayer", function (self, player)
    -- nothing :>
end)

Class_ReplaceMethod("PlayingTeam", "ReplaceRespawnPlayer", function (self, player, origin, angles, mapName)
    local className = player.lastClass or mapName or self.respawnEntity
    local teamNumber = self:GetTeamNumber()
    local extraValues = nil
    if player.lastClass == "exo" then
        extraValues = player.lastExoLayout
    end
    
    local newPlayer = player:Replace(className, teamNumber, false, nil, extraValues)
    -- Always disable 3rd person
    newPlayer:SetDesiredCameraDistance(0)

    -- Turns out if you give weapons to exos the game implodes! Who wouldve thought!
    if teamNumber == kTeam1Index and (className == "marine" or className == "jetpackmarine") and newPlayer.lastWeaponList then
        -- Restore weapons in reverse order so the main weapons gets selected on respawn
        for i = #newPlayer.lastWeaponList, 1, -1 do
            if newPlayer.lastWeaponList[i] ~= "axe" then
                newPlayer:GiveItem(newPlayer.lastWeaponList[i])
            end
        end
    end
    
    if teamNumber == kTeam2Index and newPlayer.lastUpgradeList then    
        newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
        newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
        newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
    end
    
    newPlayer:SetOrigin(RoomManager:GetSpawnOrigin(newPlayer))
    newPlayer:ClearEffects()
    
    return (newPlayer ~= nil), newPlayer
end)

local originalPlayingTeamUpdate
originalPlayingTeamUpdate = Class_ReplaceMethod("PlayingTeam", "Update", function (self, timePassed)
    originalPlayingTeamUpdate(self, timePassed)

    -- check for players to respawn:
    for grpId, grp in pairs(RoomManager.playersInGroup) do
        if RoomManager:IsOneTeamDown(grpId) then
            Shared.Message("SERVER: One team down: respawning all from that grp.")
            RoomManager:RespawnGroup(self, grpId) -- respawn all players from that grp
        end
    end
end)

local function OnCommandChangeClass2(className, teamNumber, extraValues, spawnLoc)

    return function(player)
        
        // Don't allow to use these commands if you're in the RR
        if player:GetTeamNumber() == kTeam1Index or player:GetTeamNumber() == kTeam2Index then
        
            // Switch teams if necessary
            if player:GetTeamNumber() ~= teamNumber then
                if Shared.GetCheatsEnabled() and not player:GetIsCommander() then
                
                    // Remember position and team for calling player for debugging
                    local playerOrigin = player:GetOrigin()
                    local playerViewAngles = player:GetViewAngles()
                    
                    local newTeamNumber = kTeam1Index
                    if player:GetTeamNumber() == kTeam1Index then
                        newTeamNumber = kTeam2Index
                    end
                    
                    local success, newPlayer = GetGamerules():JoinTeam(player, kTeamReadyRoom)
                    success, newPlayer = GetGamerules():JoinTeam(newPlayer, newTeamNumber)
                    
                    if spawnLoc ~= nil then
                    	newPlayer:SetOrigin(spawnLoc)
               		else
                    	newPlayer:SetOrigin(playerOrigin)
                    end
                    newPlayer:SetViewAngles(playerViewAngles)
                                    
                end
            end
            
            // Respawn shenanigans
            if Shared.GetCheatsEnabled() then
                local newPlayer = player:Replace(className, player:GetTeamNumber(), nil, nil, extraValues)
                
                // Always disable 3rd person
                newPlayer:SetDesiredCameraDistance(0)

                // Turns out if you give weapons to exos the game implodes! Who wouldve thought!
                if teamNumber == kTeam1Index and (className == "marine" or className == "jetpackmarine") and newPlayer.lastWeaponList then
                    // Restore weapons in reverse order so the main weapons gets selected on respawn
                    for i = #newPlayer.lastWeaponList, 1, -1 do
                        if newPlayer.lastWeaponList[i] ~= "axe" then
                            newPlayer:GiveItem(newPlayer.lastWeaponList[i])
                        end
                    end
                end
                
                if teamNumber == kTeam2Index and newPlayer.lastUpgradeList then    
                    newPlayer.upgrade1 = newPlayer.lastUpgradeList[1] or 1
                    newPlayer.upgrade2 = newPlayer.lastUpgradeList[2] or 1
                    newPlayer.upgrade3 = newPlayer.lastUpgradeList[3] or 1
                end

                if spawnLoc ~= nil then
                 	newPlayer:SetOrigin(spawnLoc)
                end
                
            end
            
        end
        
    end
    
end

// Modify the Players OnKill

function restoreDuelPlayer(self, killer)
    local duelKiller
    if killer then
        if killer:isa("Player") then
            duelKiller = killer
        else
            local realKiller = killer.GetOwner and killer:GetOwner() or nil
            if realKiller and realKiller:isa("Player") then
                duelKiller = realKiller
            end
        end
    end
    if duelKiller ~= nil and duelKiller:GetTeamNumber() ~= self:GetTeamNumber() then
    	//Ammmo:
        if duelKiller:isa("Marine") then
		local weapons = duelKiller:GetHUDOrderedWeaponList()
		    for index, weapon in ipairs(weapons) do
		    
		        if weapon:isa("ClipWeapon") then
		            weapon:GiveAmmo(5, false)
		        end
	    	end
		    self:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(duelKiller:GetOrigin())})
	    end

        //Heal:
        duelKiller:AddHealth(2000)

        // Give energy:
        if duelKiller:isa("Alien") then
        	duelKiller:SetEnergy(duelKiller:GetMaxEnergy())
    	end

        //Marine Armor:
        duelKiller:SetArmor(duelKiller.maxArmor)
    end
end

function respawnDuelPlayer(player)

    Shared.Message('Respawn player..')

    if player.lastClass and player.lastDeathPos and (player:GetTeamNumber() == kTeam1Index or player:GetTeamNumber() == kTeam2Index) and Shared.GetCheatsEnabled() then

        local teamNumber = kTeam2Index
        local extraValues = nil
        
        if player.lastClass == "exo" or player.lastClass == "marine" or player.lastClass == "jetpackmarine" then
            teamNumber = kTeam1Index
            
            if player.lastClass == "exo" then
                extraValues = player.lastExoLayout
            end
        end

        local respawnLoc = RoomManager:GetSpawnOrigin(player)

        local func = OnCommandChangeClass2(player.lastClass, teamNumber, extraValues, respawnLoc)
        func(player)
    end
end

--INACTIVE:
local function ns2dUpdateChangeToSpectator(self)

    if not self:GetIsAlive() and not self:isa("Spectator") then
    
        local time = Shared.GetTime()
        if self.timeOfDeath ~= nil and (time - self.timeOfDeath > kFadeToBlackTime) then
        
            local owner = Server.GetOwner(self)
            if owner then
                respawnDuelPlayer(self)
            end
            
        end
        
    end
end

--ReplaceLocals( Player.OnUpdatePlayer, { UpdateChangeToSpectator = ns2dUpdateChangeToSpectator } )

local originalPlayerOnKill
originalPlayerOnKill = Class_ReplaceMethod("Player", "OnKill", 
	function(self, killer, doer, point, direction)
		originalPlayerOnKill(self, killer, doer, point, direction)
		--restoreDuelPlayer(self, killer)
	end)