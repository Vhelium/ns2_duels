
Script.Load("lua/ns2d/ns2d_RoomManager.lua")

RoomManager.playersInGroup = { }
RoomManager.groupInRoom = { }

local function OnPlayerJoinedGroup( message )
	-- if group does not exist, create group
	-- add player to group
	-- update UI
end
Client.HookNetworkMessage( "RoomPlayerJoinedGroup", OnPlayerJoinedGroup )

local function OnPlayerLeftGroup( message )
	-- remove player from groyp
	-- if #group == 0, delete group
	-- update UI
end
Client.HookNetworkMessage( "RoomPlayerLeftGroup", OnPlayerLeftGroup )

local function OnGroupJoinedRoom( message )
	-- add group to room
	-- update UI
end
Client.HookNetworkMessage( "RoomGroupJoinedRoom", OnGroupJoinedRoom )

local function OnGroupLeftRoom( message )
	-- remove group from room
	-- update UI
end
Client.HookNetworkMessage( "RoomGroupLeftRoom", OnGroupLeftRoom )