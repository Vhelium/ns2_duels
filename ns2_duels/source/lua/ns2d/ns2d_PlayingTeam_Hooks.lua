
Class_ReplaceMethod("PlayingTeam", "ReplaceRespawnPlayer", function (self, player, origin, angles, mapName)
    local className = self.respawnEntity
    if mapName ~= nil then
        className = mapName
    end

    local teamNumber = player:GetTeamNumber()
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