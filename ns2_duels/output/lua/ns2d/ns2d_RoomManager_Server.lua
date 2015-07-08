
Script.Load("lua/ns2d/ns2d_RoomManager.lua")
Script.Load("lua/ServerSponitor.lua")

RoomManager.existsEmptyGroup = false
RoomManager.roomSpawns = { } -- list (indexed by room) with spawn origins for rines[1] and aliens[2]

local function OnMapPostLoad()
	RoomManager.roomSpawns = { } -- clear out old spawns

    local roomSpawnEnts = Shared.GetEntitiesWithClassname("RoomSpawn")
    for index, spawn in ientitylist(roomSpawnEnts) do
        local roomId = spawn:GetId()
        local teamNr = spawn:GetTeamNr()
        local spawn = spawn:GetOrigin()
        
        if (teamNr == 1 or teamNr == 2) and spawn ~= nil then
        	if RoomManager.roomSpawns[roomId] == nil then
        		RoomManager.roomSpawns[roomId] = { }
        	end
        	RoomManager.roomSpawns[roomId][teamNr] = spawn
    	end
    end
end
Event.Hook("MapPostLoad", OnMapPostLoad)

local original_OnJoinTeam
original_OnJoinTeam = Class_ReplaceMethod("ServerSponitor", "OnJoinTeam", function (self, player, team)
	original_OnJoinTeam(self, player, team)
	-- Leave the Group if it's ready room:
	if team:GetTeamNumber() == kTeamReadyRoom then
		Shared.Message("SERVER: Player["..player:GetId().."] joined Ready Room")
		local owner = Server.GetOwner(player) -- the client object
		if owner then
			RoomManager:LeaveGroup(owner)
		end
	end
end)

function RoomManager:JoinGroup(client, groupId)
	local playerId = client:GetUserId()
	local prevGroup = self:GetGroupFromPlayer(playerId)

	if groupId ~= -1 and prevGroup == groupId then -- Player wants to join same grp
		Shared.Message("SERVER: Player["..playerId.."] is already in group "..groupId)
		return
	elseif prevGroup ~= -1 then  -- Player was already in another grp  before
		self:LeaveGroup(client)
	end

	if groupId == -1 then -- Player wants to join a new grp
		groupId = self:GetNewEmptyGroup()
	end

	if self.playersInGroup[groupId] == nil then -- Initialize new group
		self.playersInGroup[groupId] = {}
	end
	self.playersInGroup[groupId][playerId] = client

	Server.SendNetworkMessage("RoomPlayerJoinedGroup", { PlayerId = playerId, GroupId = groupId, PlayerName = client:GetControllingPlayer():GetName() })

	Shared.Message("SERVER: Player["..playerId.."] joined Group #"..groupId)

	-- 'teleport' player to corresponding Room, if any (otherwise he wil spawn in base == -1)
	local roomId = self:GetRoomFromGroup(groupId)
	self:SpawnPlayerInRoom(client, roomId)
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

		Shared.Message("SERVER: Player["..playerId.."] left Group #"..prevGroup)

		-- Check if group is empty now:
		if #(self.playersInGroup[prevGroup]) == 0 then -- no more players
			Shared.Message("SERVER: Group["..prevGroup.."] is now empty. Deleting..")
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
		Shared.Message("SERVER: Room "..roomId.." is already occupied by Group "..self.groupInRoom[roomId])
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

		Shared.Message("SERVER: Group["..groupId.."] joined Room #"..roomId)
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

		Shared.Message("SERVER: Group["..groupId.."] left Room #"..prevRoom)
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

function RoomManager:GetSpawnOrigin(player, roomId)
	if roomId == nil then
		local owner = Server.GetOwner(player) -- the client object
		if owner then
			roomId = self:GetCurrentRoomForPlayer(owner:GetUserId())
		end
	end

	if RoomManager.roomSpawns[roomId] ~= nil then
		return RoomManager.roomSpawns[roomId][player:GetTeamNumber()]
	end

	return nil
end

function RoomManager:SpawnPlayerInRoom(client, roomId)
	local player = client:GetControllingPlayer()
	local spawn = self:GetSpawnOrigin(player, roomId)
	if spawn ~= nil then
		player:SetOrigin(spawn) -- set Player's origin to corresponding room spawn
	else
		Shared.Message("SERVER: No spawn found: room="..roomId..", team="..player:GetTeamNumber())
	end
end

kMaxGroupIteration = 200
function RoomManager:GetNewEmptyGroup(client)
	for i=1, kMaxGroupIteration, 1 do
		if self.playersInGroup[i] == nil then -- empty group found
			self.playersInGroup[i] = { }
			return i;
		end
	end
end