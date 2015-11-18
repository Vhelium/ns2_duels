function OnArmorUpgradeTo(client, value)

	RoomManager:OnUpgradeArmorTo(RoomManager:GetGroupFromPlayer(client:GetUserId()), value)

    Shared.Message('setting Armor to: '..value)
end

function OnWeaponsUpgradeTo(client, value)

	RoomManager:OnUpgradeWeaponsTo(RoomManager:GetGroupFromPlayer(client:GetUserId()), value)

    Shared.Message('setting Weapons to: '..value)
end
