
Script.Load("lua/ns2d/ns2d_RoomManager.lua")
Script.Load("lua/ServerSponitor.lua")

RoomManager.existsEmptyGroup = false
RoomManager.upgradesOfGroup = { [-1] = { ArmorLevel=0, WeaponsLevel=0, BiomassLevel=1 } }
RoomManager.settingsOfGroup = { [-1] = { PlayerCount = 0, InstaRespawn=false } }
RoomManager.roomSpawns = { } -- list (indexed by room) with spawn origins for rines[1] and aliens[2]
RoomManager.roomNames = { }
RoomManager.roomIsRegion = { }

-------------------------------------[ local funcs ]---------------------------------------------------------

local function InitializeGroup(self, grpId)
	self.playersInGroup[grpId] = {}
	self.upgradesOfGroup[grpId] = { ArmorLevel=0, WeaponsLevel=0, BiomassLevel=1 }
	self.settingsOfGroup[grpId] = { PlayerCount=0, InstaRespawn=kInstaRespawn }
end

local function UninitializeGroup(self, grpId)
	self.playersInGroup[grpId] = nil
	self.upgradesOfGroup[grpId] = { ArmorLevel=0, WeaponsLevel=0, BiomassLevel=1 }
	self.settingsOfGroup[grpId] = self.settingsOfGroup[-1]
end

local function GetTechIdForArmorLevel(level)

    local armorTechId = {}
    
    armorTechId[1] = kTechId.Armor1
    armorTechId[2] = kTechId.Armor2
    armorTechId[3] = kTechId.Armor3
    
    return armorTechId[level]

end

local function GetTechIdForWeaponLevel(level)

    local weaponTechId = {}
    
    weaponTechId[1] = kTechId.Weapons1
    weaponTechId[2] = kTechId.Weapons2
    weaponTechId[3] = kTechId.Weapons3
    
    return weaponTechId[level]

end

local kBioMassTechIds =
{
    [1]=kTechId.BioMassOne,
    [2]=kTechId.BioMassTwo,
    [3]=kTechId.BioMassThree,
    [4]=kTechId.BioMassFour,
    [5]=kTechId.BioMassFive,
    [6]=kTechId.BioMassSix,
    [7]=kTechId.BioMassSeven,
    [8]=kTechId.BioMassEight,
    [9]=kTechId.BioMassNine
}

-------------------------------------[ GROUPS/ROOMS ]---------------------------------------------------------

local function OnMapPostLoad()
	RoomManager.roomSpawns = { } -- clear out old spawns

	local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
	local roomId
    for roomId = 1, #techPoints do

        local techPointName = string.lower(techPoints[roomId]:GetLocationName())
        local spawn = techPoints[roomId]:GetOrigin()

        	RoomManager.roomSpawns[roomId] = { }

        	local spawnDist = -1
        	local spawnAliens, spawnRines
        	for index=0, 8, 1 do

	        	local sAliens = GetRandomSpawnForCapsule(1.9, 0.5, spawn, 21, 40, EntityFilterAll())
	        	local sRines = GetRandomSpawnForCapsule(1.9, 0.5, spawn, 20, 40, EntityFilterAll())

	        	if sAliens and sRines then
		        	local dist = (sAliens - sRines):GetLength()

		        	if dist > spawnDist then
		        		spawnDist = dist
		        		spawnAliens = sAliens
		        		spawnRines = sRines
		        	end
	        	end

        	end

        	if not spawnAliens then
        		spawnAliens = spawn
        	end
        	if not spawnRines then
        		spawnRines = spawn
        	end

        	RoomManager.roomSpawns[roomId][1] = spawnAliens -- Rines
        	RoomManager.roomSpawns[roomId][2] = spawnRines -- Aliens

        	RoomManager.roomNames[roomId] = techPointName
        	RoomManager.roomIsRegion[roomId] = true

        	Shared.Message("SERVER: Room found: "..techPointName.." - is origin nil: "..tostring(spawn == nil))
    end

    -- local roomSpawnEnts = Shared.GetEntitiesWithClassname("RoomSpawn")
    -- for index, spawn in ientitylist(roomSpawnEnts) do
    --     local roomId = spawn:GetId()
    --     local teamNr = spawn:GetTeamNr()
    --     local spawn = spawn:GetOrigin()
        
    --     if (teamNr == 1 or teamNr == 2) and spawn ~= nil then
    --     	if RoomManager.roomSpawns[roomId] == nil then
    --     		RoomManager.roomSpawns[roomId] = { }
    --     	end
    --     	RoomManager.roomSpawns[roomId][teamNr] = spawn
    --    	RoomManager.roomIsRegion[roomId] = false
    -- 	end
    -- end

    -- Send Rooms to player!
    for roomId, spawns in pairs(RoomManager.roomSpawns) do
    	if roomId ~= -1 then
			Server.SendNetworkMessage(client, "RoomAddRoom", { RoomId = roomId, Description = RoomManager.roomNames[roomId] }, true)
		end
    end
end
Event.Hook("MapPostLoad", OnMapPostLoad)

function RoomManager:SetRoomSpawnLocation(teamNr, roomId, origin)
	if RoomManager.roomSpawns[roomId] then
		RoomManager.roomSpawns[roomId][teamNr] = origin
	end
end

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
		InitializeGroup(self, groupId)
	end
	self.playersInGroup[groupId][playerId] = client
	RoomManager.settingsOfGroup[groupId].PlayerCount = RoomManager.settingsOfGroup[groupId].PlayerCount + 1

	Server.SendNetworkMessage("RoomPlayerJoinedGroup", { PlayerId = playerId, GroupId = groupId, PlayerName = client:GetControllingPlayer():GetName() }, true)

	-- send all upgrades from that grp:
	self:SendAllTechTreeUpgrades(playerId, groupId)

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
		RoomManager.settingsOfGroup[prevGroup].PlayerCount = RoomManager.settingsOfGroup[prevGroup].PlayerCount - 1
		Server.SendNetworkMessage("RoomPlayerLeftGroup", { PlayerId = playerId, GroupId = prevGroup }, true)

		Shared.Message("SERVER: Player["..playerId.."] left Group #"..prevGroup)

		-- Check if group is empty now:
		if RoomManager.settingsOfGroup[prevGroup].PlayerCount == 0 then -- no more players
			Shared.Message("SERVER: Group["..prevGroup.."] is now empty. Deleting..")
			self:LeaveRoomAsGroup(prevGroup)
			UninitializeGroup(self, prevGroup)
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
			Server.SendNetworkMessage("RoomGroupLeftRoom", { GroupId = groupId, RoomId = prevRoom }, true)
		end
		Server.SendNetworkMessage("RoomGroupJoinedRoom", { GroupId = groupId, RoomId = roomId }, true)

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
		Server.SendNetworkMessage("RoomGroupLeftRoom", { GroupId = groupId, RoomId = prevRoom }, true)

		Shared.Message("SERVER: Group["..groupId.."] left Room #"..prevRoom)
	end

	--TODO: Port to Marine/Alien base ?
end

-------------------------------------[ (DIS-)CONNECTING ]---------------------------------------------------------

local function OnClientConnect( client )
	-- Initialize client params
	client.duelParams = { medSpamInterval = kMedSpamIntervalDefault, timeLastMedpackHeal = 0 }

	-- Note: New Players are not assigned to a group by default
    -- Send Rooms to player!
    for roomId, spawns in pairs(RoomManager.roomSpawns) do
    	if roomId ~= -1 then
			Server.SendNetworkMessage(client, "RoomAddRoom", { RoomId = roomId, Description = RoomManager.roomNames[roomId] }, true)
		end
    end

end
Event.Hook( "ClientConnect", OnClientConnect )

local function OnClientDisconnect( client )
	RoomManager:LeaveGroup(client)
end
Event.Hook( "ClientDisconnect", OnClientDisconnect )

-------------------------------------[ HOOKS ] -------------------------------------------------------------------

local original_GetUserId
original_GetUserId = Class_ReplaceMethod("ServerClient", "GetUserId", function(self)
	if self:GetIsVirtual() then
		return self.bot_userId
	else
		return original_GetUserId(self)
	end
end)

-------------------------------------[ SETTINGS ] ----------------------------------------------------------------

kMedSpamIntervalDefault = 0
kInstaRespawn = false

local function OnSetMedSpamInterval(client, message)
    local player = client:GetControllingPlayer()
    if player:isa("Marine") then
        client.duelParams.medSpamInterval = message.Time
        Shared.Message("SERVER: Set med spam interval for Player["..player:GetId().."] to "..message.Time.." ms")
    end
end

Server.HookNetworkMessage( "RoomMedSpamInterval", OnSetMedSpamInterval )

local function OnSetInstaRespawn(client, message)
    local playerId = client:GetUserId()
	local groupId = RoomManager:GetGroupFromPlayer(playerId)

	if groupId ~= -1 then
		RoomManager.settingsOfGroup[groupId].InstaRespawn=message.InstaRespawn
        Shared.Message("SERVER: Set insta respawn for group["..groupId.."] to "..message.InstaRespawn)
	end
end

Server.HookNetworkMessage( "SetInstaRespawn", OnSetInstaRespawn )


-------------------------------------[ PLAYER UPGRADES ] ---------------------------------------------------------

local function BuildTechNodeUpgradeMessage(techId, researched)
    local t = {}
    
    t.techId                    = techId
    t.available                 = true
    t.researchProgress          = 1
    t.prereqResearchProgress    = 1
    t.researched                = researched
    t.researching               = false
    t.hasTech                   = researched
    
    return t
end

function RoomManager:OnUpgradeArmorTo(grpId, lvlArmor)
	if grpId == -1 then return end

	local prevLevel = self.upgradesOfGroup[grpId].ArmorLevel
	if prevLevel == lvlArmor then return end

    self.upgradesOfGroup[grpId].ArmorLevel = math.max(0, math.min(3, lvlArmor))

    -- propagate this to the group members:
    for pId, clnt in pairs(self.playersInGroup[grpId]) do
		if prevLevel > lvlArmor then
			for i=prevLevel, lvlArmor+1, -1 do
				Server.SendNetworkMessage(clnt:GetControllingPlayer(), "TechNodeUpdate", BuildTechNodeUpgradeMessage(GetTechIdForArmorLevel(i), false), true)
			end
		else
			for i=prevLevel+1, lvlArmor, 1 do
				Server.SendNetworkMessage(clnt:GetControllingPlayer(), "TechNodeUpdate", BuildTechNodeUpgradeMessage(GetTechIdForArmorLevel(i), true), true)
			end
		end
	end
end

function RoomManager:OnUpgradeWeaponsTo(grpId, lvlWeapons)
	if grpId == -1 then return end
	
	local prevLevel = self.upgradesOfGroup[grpId].WeaponsLevel
	if prevLevel == lvlWeapons then return end

    self.upgradesOfGroup[grpId].WeaponsLevel = math.max(0, math.min(3, lvlWeapons))

    -- propagate this to the group members:
    for pId, clnt in pairs(self.playersInGroup[grpId]) do
		if prevLevel > lvlWeapons then
			for i=prevLevel, lvlWeapons+1, -1 do
				Server.SendNetworkMessage(clnt:GetControllingPlayer(), "TechNodeUpdate", BuildTechNodeUpgradeMessage(GetTechIdForWeaponLevel(i), false), true)
			end
		else
			for i=prevLevel+1, lvlWeapons, 1 do
				Server.SendNetworkMessage(clnt:GetControllingPlayer(), "TechNodeUpdate", BuildTechNodeUpgradeMessage(GetTechIdForWeaponLevel(i), true), true)
			end
		end
	end
end

function RoomManager:OnUpgradeBiomassTo(grpId, lvlBio)
	if grpId == -1 then return end
	
	local prevLevel = self.upgradesOfGroup[grpId].BiomassLevel
	if prevLevel == lvlBio then return end

    self.upgradesOfGroup[grpId].BiomassLevel = math.max(0, math.min(12, lvlBio))

    -- propagate this to the group members:
    for pId, clnt in pairs(self.playersInGroup[grpId]) do
		if prevLevel > lvlBio then
			for i=prevLevel, lvlBio+1, -1 do
				if kBioMassTechIds[i] ~= nil then Server.SendNetworkMessage(clnt:GetControllingPlayer(), "TechNodeUpdate", BuildTechNodeUpgradeMessage(kBioMassTechIds[i], false), true) end
			end
		else
			for i=prevLevel+1, math.min(9, lvlBio), 1 do
				Server.SendNetworkMessage(clnt:GetControllingPlayer(), "TechNodeUpdate", BuildTechNodeUpgradeMessage(kBioMassTechIds[i], true), true)
			end
		end
	end
end

function RoomManager:OnPlayerJoinedTeam(player)

	local owner = Server.GetOwner(player) -- the client object

	if owner and owner:GetIsVirtual() then -- its a bot
    	self:JoinGroup(owner, owner.initialGroup) -- add player to group 1

	elseif owner and (player:GetTeamNumber() == kTeam1Index or player:GetTeamNumber() == kTeam2Index) then
		playerId = owner:GetUserId()
		grpId = self:GetGroupFromPlayer(playerId)

		self:SendAllTechTreeUpgrades(playerId, grpId)
	end
end

function RoomManager:SendAllTechTreeUpgrades(playerId, grpId)
	if grpId == -1 then	return end

	for pId, clnt in pairs(self.playersInGroup[grpId]) do

		local player = clnt:GetControllingPlayer()

		--player:GetTeam():SendTechTreeBase(player) -- send 'empty' tech tree

		for a=1, 3, 1 do
			Server.SendNetworkMessage(player, "TechNodeUpdate", BuildTechNodeUpgradeMessage(GetTechIdForArmorLevel(a), (a <= self.upgradesOfGroup[grpId].ArmorLevel)), true)
		end
		for w=1, 3, 1 do
			Server.SendNetworkMessage(player, "TechNodeUpdate", BuildTechNodeUpgradeMessage(GetTechIdForWeaponLevel(w), (w <= self.upgradesOfGroup[grpId].WeaponsLevel)), true)
		end
		for b=1, 9, 1 do
			Server.SendNetworkMessage(player, "TechNodeUpdate", BuildTechNodeUpgradeMessage(kBioMassTechIds[b], (b <= self.upgradesOfGroup[grpId].BiomassLevel)), true)
		end

	end
end

-------------------------------------[ HELPER FUNCTIONS ] --------------------------------------------------------

function RoomManager:GetRandomPositionAround(player, origin)
	-- Compute random spawn location
    local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
    Shared.Message("SERVER: capsHeight="..capsuleHeight..", capsRadius="..capsuleRadius)

    local spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, 2, 5, EntityFilterAll())
    
    if not spawnOrigin then
        spawnOrigin = origin + Vector(2, 0.2, 2)
        Shared.Message("SERVER: No random pos found.")
    end

    spawnOrigin = GetGroundAtPointWithCapsule(spawnOrigin, player:GetExtents(), PhysicsMask.CommanderBuild)

    return spawnOrigin
end

function RoomManager:GetSpawnOrigin(player, roomId)
	if roomId == nil then
		local owner = Server.GetOwner(player) -- the client object
		if owner then
			roomId = self:GetCurrentRoomForPlayer(owner:GetUserId())
		else
			Shared.Message("SERVER: GetSpawnOrigin("..roomId.."): owner == nil????")
		end
	end

	if roomId == -1 then

		local initialTechPoint = player:GetTeam():GetInitialTechPoint()

		if initialTechPoint then
			local spawnOrigin = initialTechPoint:GetOrigin()
			return spawnOrigin
		end


	elseif RoomManager.roomSpawns[roomId] ~= nil then
		return RoomManager.roomSpawns[roomId][player:GetTeamNumber()]
	end

	return nil
end

function RoomManager:SpawnPlayerInRoom(client, roomId)
	local player = client:GetControllingPlayer()
	local spawn = self:GetSpawnOrigin(player, roomId)
	if spawn ~= nil then
		player:SetOrigin(self:GetRandomPositionAround(player, spawn)) -- set Player's origin to corresponding room spawn
	else
		Shared.Message("SERVER: No spawn found: room="..roomId..", team="..player:GetTeamNumber())
	end
end

kMaxGroupIteration = 200
function RoomManager:GetNewEmptyGroup()
	for i=1, kMaxGroupIteration, 1 do
		if self.playersInGroup[i] == nil then -- empty group found
			InitializeGroup(self, i)
			return i;
		end
	end
end

local function IsPlayerDeadLongEnough(player)
	local time = Shared.GetTime()
    if player.timeOfDeath ~= nil and (time - player.timeOfDeath > kFadeToBlackTime) then
		return true
    end
    return false
end

function RoomManager:IsOneTeamDown(grpId)
	local playersAlive = { [kTeam1Index]=0, [kTeam2Index]=0 } -- 0 means no players in team, 1=dead players, 2=at least one alive

	for pId, clnt in pairs(self.playersInGroup[grpId]) do
		local player = clnt:GetControllingPlayer()

		if player:GetIsAlive() or not IsPlayerDeadLongEnough(player) then -- there is a player still alive!
			playersAlive[player:GetTeamNumber()] = 2
		elseif playersAlive[player:GetTeamNumber()] == 0 then
			playersAlive[player:GetTeamNumber()] = 1
		end
	end

	return playersAlive[kTeam1Index] == 1 or playersAlive[kTeam2Index] == 1
end

local function RefillPlayer(player)

    if player:isa("Marine") then
	local weapons = player:GetHUDOrderedWeaponList()
	    for index, weapon in ipairs(weapons) do
	    
	        if weapon:isa("ClipWeapon") then
	            weapon:GiveAmmo(5, false)
	        end
    	end
	    player:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
    end

    --Heal:
    player:AddHealth(3000)

    -- Give energy:
    if player:isa("Alien") then
    	player:SetEnergy(player:GetMaxEnergy())
	end

    --Marine Armor:
    player:SetArmor(player.maxArmor)
end

function RoomManager:RespawnGroup(grpId)

	for pId, clnt in pairs(self.playersInGroup[grpId]) do
		local player = clnt:GetControllingPlayer()
		local playingTeam = player:GetTeam()
		if player == nil then
			Shared.Message("SERVER: RespawnGrp - PLAYER NIL!")
		elseif player:GetIsAlive() then
			RefillPlayer(player)
		else
			-- respawn in room:
            Shared.Message("SERVER: RespawnGroup - respawning player in team "..playingTeam:GetTeamNumber().."..")
			local success, newPlayer = playingTeam:ReplaceRespawnPlayer(player, nil, nil, player.lastClass)
			self:SpawnPlayerInRoom(clnt, self:GetCurrentRoomForPlayer(pId))
		end
	end
end

-- Used for insta respawn
function RoomManager:RespawnDeadPlayers(grpId)

	for pId, clnt in pairs(self.playersInGroup[grpId]) do
		local player = clnt:GetControllingPlayer()
		local playingTeam = player:GetTeam()
		if player == nil then
			Shared.Message("SERVER: RespawnGrp - PLAYER NIL!")
		elseif not player:GetIsAlive() and IsPlayerDeadLongEnough(player) then
			-- respawn in room:
            Shared.Message("SERVER: RespawnDeadPlayers - insta respawning player in grp "..grpId.."..")
			local success, newPlayer = playingTeam:ReplaceRespawnPlayer(player, nil, nil, player.lastClass)
			self:SpawnPlayerInRoom(clnt, self:GetCurrentRoomForPlayer(pId))
		end
	end
end