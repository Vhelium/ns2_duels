duelBioMassLevel = 1

function OnBiomassTo(value)

    Shared.Message('setting Biomass to: '..value)

	local techTree = GetTechTree(2)
	local i = 2
	while i <= 9 do
		Shared.Message('techid: '..StringToTechId('BioMassTwo'))
		local bioNode = techTree:GetTechNode(StringToTechId('BioMassTwo'))
		if i <= value then
			bioNode:SetResearched(true)
		else
			bioNode:SetResearched(false)
		end
		techTree:SetTechNodeChanged(bioNode, "researched or not")

		i = i + 1
	end
	i = i - 1
	if i > 0 then
    	techTree:QueueOnResearchComplete(StringToTechId('BioMassTwo'))
	else
		SendTeamMessage(GetGamerules():GetTeam(1), kTeamMessageTypes.ResearchLost, StringToTechId('BioMassTwo'))
	end
    techTree:ComputeAvailability()
end