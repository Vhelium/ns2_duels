
--From Client:
Shared.RegisterNetworkMessage( "RoomJoinGroup", { GroupId = "integer (-1 to 100)" } )
Shared.RegisterNetworkMessage( "RoomJoinRoom", { RoomId = "integer (-1 to 100)" } )

--From Server
Shared.RegisterNetworkMessage( "RoomPlayerJoinedGroup", { PlayerId = "integer", GroupId = "integer (-1 to 100)", PlayerName = "string (255)"} )
Shared.RegisterNetworkMessage( "RoomPlayerLeftGroup", { PlayerId = "integer", GroupId = "integer (-1 to 100)" } )
Shared.RegisterNetworkMessage( "RoomGroupJoinedRoom", { GroupId = "integer (-1 to 100)", RoomId = "integer (-1 to 100)" } )
Shared.RegisterNetworkMessage( "RoomGroupLeftRoom", { GroupId = "integer (-1 to 100)", RoomId = "integer (-1 to 100)" } )

Shared.RegisterNetworkMessage( "RoomAddRoom", { RoomId = "integer (-1 to 100)", Description = "string (255)" } )