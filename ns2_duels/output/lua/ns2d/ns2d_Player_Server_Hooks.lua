local originalOnJoinTeam
originalOnJoinTeam = Class_ReplaceMethod("Player", "OnJoinTeam", function(self)
    self.sendTechTreeBase = true
    RoomManager:OnPlayerJoinedTeam(self)
end)