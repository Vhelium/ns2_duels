
Script.Load("lua/Balance.lua")

-- Override the original one:
function NS2Gamerules_GetUpgradedDamageScalar( attacker )
	if attacker:isa("Player") then

		local grpId = -1
		local owner = Server.GetOwner(attacker) -- the client object
		if owner then
			grpId = RoomManager:GetGroupFromPlayer(owner:GetUserId())
		else
			Shared.Message("SERVER: NS2Gamerules_GetUpgradedDamageScalar: owner == nil??")
		end

		if grpId ~= -1 then
			if RoomManager.upgradesOfGroup[grpId].WeaponsLevel == 3 then
		        return kWeapons3DamageScalar
		    elseif RoomManager.upgradesOfGroup[grpId].WeaponsLevel == 2 then
		        return kWeapons2DamageScalar
		    elseif RoomManager.upgradesOfGroup[grpId].WeaponsLevel == 1 then
		        return kWeapons1DamageScalar
		   	end
		end

	end

	return 1.0
end

ReplaceUpValue(NS2Gamerules.OnUpdate, "CheckForNoCommander", function() end, { LocateRecurse = true; CopyUpValues = true; })