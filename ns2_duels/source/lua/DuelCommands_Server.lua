local function OnRoom(client, id)

	if client ~= nil and Shared.GetCheatsEnabled() then
		local roomId = tonumber(id)

    	Shared.Message('Joining Room #'..id)

        local originMarine
        local originAlien

    	local roomSpawns = Shared.GetEntitiesWithClassname("RoomSpawn")
    	for index, spawn in ientitylist(roomSpawns) do
    		Shared.Message('Checking spawn loc #'..index)
                
            if spawn:GetId() == roomId then
            	if spawn:GetTeamNr() == 1 then
            		originMarine = spawn.GetOrigin()
            	else
            		originAlien = spawn.GetOrigin()
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

local function OnRoomTest(client, id)
    Shared.Message('Test: #'..id)
end

Event.Hook("Console_room", OnRoom)
Event.Hook("Console_roomtest", OnRoomTest)