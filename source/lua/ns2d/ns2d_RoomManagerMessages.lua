
--From Client:
Shared.RegisterNetworkMessage( "RoomJoinGroup", { GroupId = "integer (-1 to 100)" } )
Shared.RegisterNetworkMessage( "RoomJoinRoom", { RoomId = "integer (-1 to 100)" } )

Shared.RegisterNetworkMessage( "RoomGiveJetpack", { } )
Shared.RegisterNetworkMessage( "RemoveUpgrade", { techId1 = "enum kTechId"})

Shared.RegisterNetworkMessage( "RoomMedSpamInterval", { Time = "integer (-1 to 2000000)" } )
Shared.RegisterNetworkMessage( "SetInstaRespawn", { InstaRespawn = "integer (0 to 1)" } )
Shared.RegisterNetworkMessage( "OnSetInstaRespawn", { InstaRespawn = "integer (0 to 1)" } )

local kEvolveMessage =
{
    techId1 = "enum kTechId",
    techId2 = "enum kTechId",
    techId3 = "enum kTechId",
    techId4 = "enum kTechId",
    techId5 = "enum kTechId",
    techId6 = "enum kTechId",
    techId7 = "enum kTechId",
    techId8 = "enum kTechId"
}

Shared.RegisterNetworkMessage("Evolve", kEvolveMessage)

--From Server
Shared.RegisterNetworkMessage( "RoomPlayerJoinedGroup", { PlayerId = "integer", GroupId = "integer (-1 to 100)", PlayerName = "string (255)"} )
Shared.RegisterNetworkMessage( "RoomPlayerLeftGroup", { PlayerId = "integer", GroupId = "integer (-1 to 100)" } )
Shared.RegisterNetworkMessage( "RoomGroupJoinedRoom", { GroupId = "integer (-1 to 100)", RoomId = "integer (-1 to 100)" } )
Shared.RegisterNetworkMessage( "RoomGroupLeftRoom", { GroupId = "integer (-1 to 100)", RoomId = "integer (-1 to 100)" } )

Shared.RegisterNetworkMessage( "RoomAddRoom", { RoomId = "integer (-1 to 100)", Description = "string (255)" } )