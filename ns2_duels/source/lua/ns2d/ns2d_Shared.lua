
Script.Load( "lua/ns2d/ns2d_RoomManager.lua" )

globalRoomManager = RoomManager()

function getRoomManager()
	return globalRoomManager
end

Script.Load( "lua/ns2d/Elixer_Utility.lua" )
Elixer.UseVersion( 1.8 )

Script.Load("lua/ns2d/ns2d_RoomSpawn.lua")
Script.Load("lua/ns2d/ns2d_ClipWeapon.lua")