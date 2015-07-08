
Script.Load( "lua/ns2d/ns2d_RoomManager.lua")

RoomManager.existsEmptyGroup = false
RoomManager.roomSpawns = { } -- list (indexed by room) with spawn origins for rines[1] and aliens[2]
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

		-- Check if group is empty now:
		if #self.playersInGroup[prevGroup] == 0 then -- no more players
			self:LeaveRoomAsGroup(prevGroup)
			self.playersInGroup[prevGroup] = nil
		end
	end
end

function RoomManager:JoinRoomAsGroup(client, roomId)
	local playerId = client:GetUserId()
	local groupId = self:GetGroupFromPlayer(playerId)

	if groupId == -1 then								-- Player not in a group
		if self.groupInRoom[roomId] ~= nil then 		-- Room is taken by a group
			self:JoinGroup(client, groupInRoom[roomId])
			return -- JoinGroup will handle the teleport
		else 											-- Assign the player to a new (empty) group and join the room
			groupId = self:GetNewEmptyGroup()
			self:JoinGroup(client, groupId)
			-- do not return --> later code will handle room-joining
		end
	elseif self.groupInRoom[roomId] ~= nil then -- check if room is available
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
	--RoomManager:JoinGroup(client, 1)
	-- New Players are not assigned to a group by default
end
Event.Hook( "ClientConnect", OnClientConnect )

local function OnClientDisconnect( client )
	RoomManager:LeaveGroup(client)
end
Event.Hook( "ClientDisconnect", OnClientDisconnect )

-------------------------------------[ HOOKS ] -------------------------------------------------------------------



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

function RoomManager:GetCurrentRoomForPlayer(playerId)
	return self:GetRoomFromGroup(self:GetGroupFromPlayer(playerId)) -- try to find current room from player
end

function RoomManager:GetSpawnOrigin(player, roomId)
	if roomId == nil or roomId == -1 then
		local owner = Server.GetOwner(player) -- the client object
		if owner then
			roomId = self:GetCurrentRoomForPlayer(owner:GetUserId())
		end
	end
	-- TODO: check if RoomId ~= -1
	return RoomManager.roomSpawns[roomId][player:GetTeamNumber()]
end

function RoomManager:SpawnPlayerInRoom(client, roomId)
	local player = client:GetControllingPlayer()
	local spawn = self:GetSpawnOrigin(player, roomId)
	if spawn ~= nil then
		player:SetOrigin(spawn) -- set Player's origin to corresponding room spawn
	end
end

kMaxGroupIteration = 200
function RoomManager:GetNewEmptyGroup(client)
	for i=1, kMaxGroupIteration, 1 do
		if self.playersInGroup[i] == nil or #self.playersInGroup[i] == 0 then -- empty group found
			self.playersInGroup[i] = { }
			return i;
		end
	end
end