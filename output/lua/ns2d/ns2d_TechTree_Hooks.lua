
Class_ReplaceMethod("TechTree", "GetHasTech", function() return true end)
Class_ReplaceMethod("TechTree", "GetIsTechAvailable", function() return true end)
--Class_ReplaceMethod("TechTree", "SendTechTreeBase", function() return true end)
Class_ReplaceMethod("TechTree", "SendTechTreeUpdates", function() return true end)

function TechTree:SendTechTreeUpdates2(playerList)

    for techNodeIndex, techNode in ipairs(self.techNodesChanged) do
    
        local techNodeUpdateTable = BuildTechNodeUpdateMessage(techNode)
        
        for playerIndex, player in ipairs(playerList) do
        
            Server.SendNetworkMessage(player, "TechNodeUpdate", techNodeUpdateTable, true)
            
        end
        
    end
    
    table.clear(self.techNodesChanged)
    
end