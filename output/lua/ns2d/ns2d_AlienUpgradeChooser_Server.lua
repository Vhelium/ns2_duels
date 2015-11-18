duelBioMassLevel = 1

function OnBiomassTo(client, value)

	RoomManager:OnUpgradeBiomassTo(RoomManager:GetGroupFromPlayer(client:GetUserId()), value)

    Shared.Message('setting Biomass to: '..value)
end