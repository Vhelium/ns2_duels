
Script.Load("lua/GUIAlienBuyMenu.lua")
Script.Load("lua/ns2d/Hud/ns2d_GUIRoomSelection.lua")

local original_InitializeBackgroundAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "_InitializeBackground", function (self)
	original_InitializeBackgroundAliens()
	initializeRoomSpawnUI()
end)