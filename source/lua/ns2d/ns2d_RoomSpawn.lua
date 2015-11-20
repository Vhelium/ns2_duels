// Spawn locations for the duel rooms

class 'RoomSpawn' (Entity)

RoomSpawn.kMapName = "room_spawn"

local networkVars =
{
}

function RoomSpawn:OnCreate()

    Entity.OnCreate(self)
    
    self:SetPropagate(Entity.Propagate_Never)
    
    self:SetUpdates(false)
end

function RoomSpawn:GetIsMapEntity()
    return true
end    

function RoomSpawn:OnInitialized()

    Entity.OnInitialized(self)
end

function RoomSpawn:GetId()
	return self.RoomId
end

function RoomSpawn:GetTeamNr()
	return self.TeamNr
end

function RoomSpawn:GetName()
    return self.name
end

Shared.LinkClassToMap("RoomSpawn", RoomSpawn.kMapName, networkVars)