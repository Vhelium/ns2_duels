
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

Class_ReplaceMethod("MarineTeam", "SpawnInitialStructures", function (self, techPoint)
    -- Don't spawn any IP!!
    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    return tower, commandStation
end)

local function OnSetMedSpamInterval(client, message)
    local player = client:GetControllingPlayer()
    if player:isa("Marine") then
        player:SetMedSpamInterval(message.Time)
        Shared.Message("SERVER: Set med spam interval for Player["..player:GetId().."] to "..message.Time.." ms")
    end
end

Server.HookNetworkMessage( "RoomMedSpamInterval", OnSetMedSpamInterval )

-- Class_ReplaceMethod("Marine", "Drop", function (self, player) end)