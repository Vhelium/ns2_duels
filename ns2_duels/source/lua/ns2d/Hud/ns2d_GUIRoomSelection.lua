
local function initializeRoomSpawnUI (self)

    self.button = GUICreateButtonIcon("Drop")
    self.button:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.button:SetPosition(GUIScale(Vector(180, 120, 0)))
    self.content:AddChild(self.button)
    
    self.text = GetGUIManager():CreateTextItem()
    self.text:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.text:SetTextAlignmentX(GUIItem.Align_Center)
    self.text:SetTextAlignmentY(GUIItem.Align_Center)
    self.text:SetText(Locale.ResolveString("EJECT_FROM_EXO"))
    self.text:SetPosition(GUIScale(Vector(0, 20, 0)))
    self.text:SetScale(GUIScale(Vector(1, 1, 1)))
    self.text:SetFontName(Fonts.kAgencyFB_Small)
    self.text:SetColor(kMarineFontColor)

    self.button:AddChild(self.text)
    self.button:SetIsVisible(true)
end

local original_InitializeBackgroundRines = Class_ReplaceMethod("ns2d_GUIMarineBuyMenu", "_InitializeBackground", function (self)
	original_InitializeBackgroundRines()
	initializeRoomSpawnUI()
end)

local original_InitializeBackgroundAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "_InitializeBackground", function (self)
	original_InitializeBackgroundAliens()
	initializeRoomSpawnUI()
end)