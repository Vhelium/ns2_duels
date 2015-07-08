local function OnRoom(client, id)

    if client ~= nil and Shared.GetCheatsEnabled() then
        local roomId = tonumber(id)

        Shared.Message('SERVER: Joining Room #'..id)

        local originMarine
        local originAlien

        local roomSpawns = Shared.GetEntitiesWithClassname("RoomSpawn")
        for index, spawn in ientitylist(roomSpawns) do
                
            if spawn:GetId() == roomId then
                if spawn:GetTeamNr() == 1 then
                    originMarine = spawn:GetOrigin()
                else
                    originAlien = spawn:GetOrigin()
                end
            end
            
        end

        if originMarine ~= nil then
            for index, marine in ipairs(GetEntitiesForTeam("Marine", 1)) do
                // port to Marine Room Spawn
                marine:SetOrigin(originMarine)
            end
        end

        if originAlien ~= nil then
            for index, alien in ipairs(GetEntitiesForTeam("Alien", 2)) do
                // port to Alien Room Spawn
                alien:SetOrigin(originAlien)
            end
        end
    end
    
end

local function OnRoomCurrent(client)
    Shared.Message('SERVER: Current Room for player '..client:GetUserId()..': #'..RoomManager:GetCurrentRoomForPlayer(client:GetUserId()))
end

local function OnRoomTest(client, id)
    Shared.Message('SERVER: Test: #'..id)
end

local function Ona0()
    OnArmorUpgradeTo(0)
end

local function Ona1()
    OnArmorUpgradeTo(1)
end

local function Ona2()
    OnArmorUpgradeTo(2)
end

local function Ona3()
    OnArmorUpgradeTo(3)
end

local function Onw0()
    OnWeaponsUpgradeTo(0)
end

local function Onw1()
    OnWeaponsUpgradeTo(1)
end

local function Onw2()
    OnWeaponsUpgradeTo(2)
end

local function Onw3()
    OnWeaponsUpgradeTo(3)
end

local function OnBiomass(client, value)
    OnBiomassTo(tonumber(value))
end

local function OnPrintRooms()
    RoomManager:PrintRooms()
end

Event.Hook("Console_room", OnRoom)

Event.Hook("Console_a0", Ona0)
Event.Hook("Console_a1", Ona1)
Event.Hook("Console_a2", Ona2)
Event.Hook("Console_a3", Ona3)
Event.Hook("Console_w0", Onw0)
Event.Hook("Console_w1", Onw1)
Event.Hook("Console_w2", Onw2)
Event.Hook("Console_w3", Onw3)

Event.Hook("Console_biomass", OnBiomass)

Event.Hook("Console_roomtest", OnRoomTest)
Event.Hook("Console_roomcurrent", OnRoomCurrent)
Event.Hook("Console_rooms", OnPrintRooms)