
Script.Load("lua/MarineTeam.lua")
Script.Load("lua/Marine.lua")

--TODO add DuelSettingsMixin

local function GetArmorLevel(self, player)

    local grpId = -1
    local owner = Server.GetOwner(player) -- the client object
    if owner then
        grpId = RoomManager:GetGroupFromPlayer(owner:GetUserId())
    else
        Shared.Message("SERVER: GetArmorLevel: owner == nil??")
    end
    
    return RoomManager.upgradesOfGroup[grpId].ArmorLevel

end

Class_ReplaceMethod("MarineTeam", "Update", function (self, timePassed)
     PlayingTeam.Update(self, timePassed)
    
    -- Update distress beacon mask
    self:UpdateGameMasks(timePassed)
    
    for index, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
        if player:GetIsAlive() then
            local armorLevel = GetArmorLevel(self, player)
            player:UpdateArmorAmount(armorLevel)
        end
    end
end)

-- Get some custom update stuff for 'rines going
local original_OnProcessMove
original_OnProcessMove = Class_ReplaceMethod("Marine", "OnProcessMove", function (self, input)

    -- med pack drops
    local client = Server.GetOwner(self)
    if client.duelParams.medSpamInterval > 0 and client.duelParams.timeLastMedpackHeal + client.duelParams.medSpamInterval / 1000.0 <= Shared.GetTime() then
        self:AddHealth(MedPack.kHealth, false, true)
        client.duelParams.timeLastMedpackHeal = Shared.GetTime()
    end

    original_OnProcessMove(self, input)
end)

Class_ReplaceMethod("MarineTeam", "SpawnInitialStructures", function (self, techPoint)
    -- Don't spawn any IP!!
    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    return tower, commandStation
end)

-- Class_ReplaceMethod("Marine", "Drop", function (self, player) end)