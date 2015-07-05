function OnArmorUpgradeTo(value)

    Shared.Message('setting Armor to: '..value)

	local techTree = GetTechTree(1)
	local i = 1
	while i <= 3 do
		Shared.Message('techid: '..StringToTechId('Armor'..i))
		local armorNode = techTree:GetTechNode(StringToTechId('Armor'..i))
		if i <= value then
			armorNode:SetResearched(true)
		else
			armorNode:SetResearched(false)
		end
		techTree:SetTechNodeChanged(armorNode, "researched or not")

		i = i + 1
	end
	if value > 0 then
    	techTree:QueueOnResearchComplete(StringToTechId('Armor'..value))
	else
		SendTeamMessage(GetGamerules():GetTeam(1), kTeamMessageTypes.ResearchLost, StringToTechId('Armor1'))
	end
    techTree:ComputeAvailability()
end

function OnWeaponsUpgradeTo(value)
    Shared.Message('setting Weapons to: '..value)

	local techTree = GetTechTree(1)
	local i = 1
	while i <= 3 do
		Shared.Message('techid: '..StringToTechId('Weapons'..i))
		local weaponsNode = techTree:GetTechNode(StringToTechId('Weapons'..i))
		if i <= value then
			weaponsNode:SetResearched(true)
		else
			weaponsNode:SetResearched(false)
		end
		techTree:SetTechNodeChanged(weaponsNode, "researched or not")

		i = i + 1
	end
	if value > 0 then
    	techTree:QueueOnResearchComplete(StringToTechId('Weapons'..value))
	else
		SendTeamMessage(GetGamerules():GetTeam(1), kTeamMessageTypes.ResearchLost, StringToTechId('Weapons1'))
	end
    techTree:ComputeAvailability()
end
