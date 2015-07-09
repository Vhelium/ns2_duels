
Script.Load("lua/ns2d/ns2d_RoomManager.lua")

RoomManager.rooms = { }

----------------------------[ GROUPS ]---------------------------------------------------------

function RoomManager:PlayerJoinedGroup( playerId, groupId, playerName )
	-- if group does not exist, create group:
	if self.playersInGroup[groupId] == nil then
		self.playersInGroup[groupId] = { }
	end
	-- add player to group:
	self.playersInGroup[groupId][playerId] = playerName
	Shared.Message('CLIENT: Player['..playerId..'] joined group['..groupId..'] with name='..self.playersInGroup[groupId][playerId])
	-- update UI
	self:PrintRooms()
end

local function OnPlayerJoinedGroup( message )
	RoomManager:PlayerJoinedGroup( message.PlayerId, message.GroupId, message.PlayerName )
end
Client.HookNetworkMessage( "RoomPlayerJoinedGroup", OnPlayerJoinedGroup )

function RoomManager:PlayerLeftGroup( playerId, groupId )
	if self.playersInGroup[groupId] ~= nil then

		-- remove player from group
		self.playersInGroup[groupId][playerId] = nil

		-- if #group == 0, delete group
		if #self.playersInGroup[groupId] == 0 then
			self.playersInGroup[groupId] = nil
		end

		-- update UI
		self:PrintRooms()
	end
end

local function OnPlayerLeftGroup( message )
	RoomManager:PlayerLeftGroup( message.PlayerId, message.GroupId )
end
Client.HookNetworkMessage( "RoomPlayerLeftGroup", OnPlayerLeftGroup )

----------------------------[ ROOMS ]----------------------------------------------------------

function RoomManager:GroupJoinedRoom( groupId, roomId )
	-- add group to room
	self.groupInRoom[roomId] = groupId
	-- update UI
	self:PrintRooms()
end

local function OnGroupJoinedRoom( message )
	RoomManager:GroupJoinedRoom( message.GroupId, message.RoomId )
end
Client.HookNetworkMessage( "RoomGroupJoinedRoom", OnGroupJoinedRoom )

function RoomManager:GroupLeftRoom( groupId, roomId )
	-- remove group from room
	self.groupInRoom[roomId] = nil
	-- update UI
	self:PrintRooms()
end

local function OnGroupLeftRoom( message )
	RoomManager:GroupLeftRoom( message.GroupId, message.RoomId )
end
Client.HookNetworkMessage( "RoomGroupLeftRoom", OnGroupLeftRoom )

local function OnAddRoom( message )
	RoomManager.rooms[message.RoomId] = message.Description
	Shared.Message("CLIENT: OnAddRoom "..message.RoomId.." - "..message.Description)
end
Client.HookNetworkMessage( "RoomAddRoom", OnAddRoom )

------------------------------[ LOGIC ]-----------------------------------------------------------

