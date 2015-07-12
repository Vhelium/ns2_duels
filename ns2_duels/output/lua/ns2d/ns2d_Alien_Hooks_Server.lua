
Script.Load("lua/AlienTeam.lua")
Script.Load("lua/Egg.lua")

local UpdateCystConstruction = GetLocalFunction(AlienTeam.Update, "UpdateCystConstruction")

Class_ReplaceMethod("AlienTeam", "Update", function (self, timePassed)
    PlayingTeam.Update(self, timePassed)
    
    self:UpdateTeamAutoHeal(timePassed)
    
    local shellLevel = 3
    for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
	    local grpId = -1
	    local owner = Server.GetOwner(alien) -- the client object
	    if owner then
	        grpId = RoomManager:GetGroupFromPlayer(owner:GetUserId())
	    else
	        Shared.Message("SERVER: AlienTeam.Update: owner == nil??")
	    end
        alien:UpdateArmorAmount(shellLevel)
        alien:UpdateHealthAmount(math.min(12, RoomManager.upgradesOfGroup[grpId].BiomassLevel), self:GetMaxBioMassLevel())

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