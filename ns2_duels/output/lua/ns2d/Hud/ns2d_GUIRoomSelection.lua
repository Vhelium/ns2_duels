// ns2d_GUIRoomSelection.lua

Script.Load("lua/GUIAnimatedScript.lua")

class 'ns2d_GUIRoomSelection' (GUIAnimatedScript)

ns2d_GUIRoomSelection.kBackgroundTexture = "ui/room_background_texture.dds"

ns2d_GUIRoomSelection.kFont = Fonts.kAgencyFB_Small

ns2d_GUIRoomSelection.kSmallIconSize = GUIScale( Vector(80, 80, 0) )

function combat_GUIMarineBuyMenu:SetHostStructure(hostStructure)

    self.hostStructure = hostStructure
    //self:_InitializeItemButtons()
    //self.selectedItem = nil
    
end