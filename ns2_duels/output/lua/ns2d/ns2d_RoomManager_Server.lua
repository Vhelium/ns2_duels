
Script.Load( "lua/ns2d/ns2d_RoomManager.lua")

RoomManager.roomSpawns = { } -- list (indexed by room) with spawn origins for rines[1] and aliens[2]
RoomManager.duelCurrentRoom = -1
RoomManager.playersInGroup = { }
RoomManager.groupInRoom = { }

local function OnMapPostLoad()
	RoomManager.roomSpawns = { } -- clear out old spawns

    local roomSpawnEnts = Shared.GetEntitiesWithClassname("RoomSpawn")
    for index, spawn in ientitylist(roomSpawnEnts) do
        local roomId = spawn:GetId()
        local teamNr = spawn:GetTeamNr()
        local spawn = spawn:GetOrigin()
        
        if roomId ~= -1 and (teamNr == 1 or teamNr == 2) and spawn ~= nil then
        	if RoomManager.roomSpawns[roomId] == nil then
        		RoomManager.roomSpawns[roomId] = { }
        	end
        	RoomManager.roomSpawns[roomId][teamNr] = spawn
    	end
    end
end
Event.Hook("MapPostLoad", OnMapPostLoad)

function RoomManager:JoinGroup(client, groupId)
	local playerId = client:GetUserId()
	local prevGroup = self:GetGroupFromPlayer(playerId)
	if prevGroup ~= -1 then
		self.playersInGroup[prevGroup][playerId] = nil
	end
	if self.playersInGroup[groupId] == nil then -- Initialize group
		self.playersInGroup[groupId] = {}
	end
	self.playersInGroup[groupId][playerId] = client

	if prevGroup ~= -1 then
		Server.SendNetworkMessage("RoomPlayerLeftGroup", { PlayerId = playerId, GroupId = prevGroup })
	end
	Server.SendNetworkMessage("RoomPlayerJoinedGroup", { PlayerId = playerId, GroupId = groupId })

	Shared.Message("Player["..playerId.."] joined Group #"..groupId)

	-- 'teleport' player to corresponding Room, if any..
	local roomId = self:GetRoomFromGroup(groupId)
	if roomId ~= -1 then
		SpawnPlayerInRoom(client, roomId)
	end
end

local function OnJoinGroup(client, message)
	RoomManager:JoinGroup(client, message.GroupId)
end
Server.HookNetworkMessage( "RoomJoinGroup", OnJoinGroup )

function RoomManager:LeaveGroup(client)
	local playerId = client:GetUserId()
	local prevGroup = self:GetGroupFromPlayer(playerId)
	if prevGroup ~= -1 then
		self.playersInGroup[prevGroup][playerId] = nil
		Server.SendNetworkMessage("RoomPlayerLeftGroup", { PlayerId = playerId, GroupId = prevGroup })

		Shared.Message("Player["..playerId.."] left Group #"..prevGroup)
	end
end

function RoomManager:JoinRoomAsGroup(client, roomId)
	local playerId = client:GetUserId()
	local groupId = self:GetGroupFromPlayer(playerId)

	if self.groupInRoom[roomId] ~= nil then -- check if room is available
		Shared.Message("Room "..roomId.." is already occupied by Group "..self.groupInRoom[roomId])
		return
	end

	if groupId ~= -1 then
		local prevRoom = self:GetRoomFromGroup(groupId)
		if prevRoom ~= -1 then
			self.groupInRoom[prevRoom] = nil
		end
		self.groupInRoom[roomId] = groupId

		if prevRoom ~= -1 then
			Server.SendNetworkMessage("RoomGroupLeftRoom", { GroupId = groupId, RoomId = prevRoom })
		end
		Server.SendNetworkMessage("RoomGroupJoinedRoom", { GroupId = groupId, RoomId = roomId })

		-- Port all players from that group to the room:
		for pId, pClient in pairs(self.playersInGroup[groupId]) do
			self:SpawnPlayerInRoom(pClient, roomId)
		end

		Shared.Message("Group["..groupId.."] joined Room #"..roomId)
	end
end

local function OnJoinRoom(client, message)
	RoomManager:JoinRoomAsGroup(client, message.RoomId)
end
Server.HookNetworkMessage( "RoomJoinRoom", OnJoinRoom )

function RoomManager:LeaveRoomAsGroup(groupId)
	local prevRoom = self:GetRoomFromGroup(groupId)
	if prevRoom ~= -1 then
		self.groupInRoom[prevRoom] = nil
		Server.SendNetworkMessage("RoomGroupLeftRoom", { GroupId = groupId, RoomId = prevRoom })

		Shared.Message("Group["..groupId.."] left Room #"..prevRoom)
	end

	--TODO: Port to Marine/Alien base ?
end

-------------------------------------[ (DIS-)CONNECTING ]---------------------------------------------------------

local function OnClientConnect( client )
	RoomManager:JoinGroup(client, 1)
end
Event.Hook( "ClientConnect", OnClientConnect )

local function OnClientDisconnect( client )
	RoomManager:LeaveGroup(client)
end
Event.Hook( "ClientDisconnect", OnClientDisconnect )

-------------------------------------[ HELPER FUNCTIONS ] --------------------------------------------------------

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

function RoomManager:SpawnPlayerInRoom(client, roomId)
	local player = client:GetControllingPlayer()
	if RoomManager.roomSpawns[roomId][player:GetTeamNumber()] ~= nil then
		player:SetOrigin(RoomManager.roomSpawns[roomId][player:GetTeamNumber()]) -- set Player's origin to corresponding room spawn
	end
end