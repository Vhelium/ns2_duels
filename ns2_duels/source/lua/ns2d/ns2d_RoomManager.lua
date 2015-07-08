RoomManager = RoomManager or {}
RoomManager.playersInGroup = { }
RoomManager.groupInRoom = { }

function RoomManager:GetRoomFromGroup(groupId)
	for rId, grpId in pairs(self.groupInRoom) do
		if grpId == groupId then
			return rId
		end
	end

	return -1
end

function RoomManager:GetGroupFromPlayer(playerId)
	for grpId, grp in pairs(self.playersInGroup) do
		for pId, cl in pairs(self.playersInGroup[grpId]) do
			if pId == playerId then
				return grpId
			end
		end
	end

	return -1
end

function RoomManager:GetCurrentRoomForPlayer(playerId)
	return self:GetRoomFromGroup(self:GetGroupFromPlayer(playerId)) -- try to find current room from player
end

function RoomManager:PrintRooms()
    Shared.Message('  ')
    for grpId, grp in pairs(self.playersInGroup) do
        Shared.Message('Group '..grpId..' (Room '..self:GetRoomFromGroup(grpId)..'):')
        for pId, cl in pairs(self.playersInGroup[grpId]) do
            Shared.Message('    Player('..pId..')')
        end
        Shared.Message('  ')
    end
end