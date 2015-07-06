
Script.Load("lua/ns2d/Hud/ns2d_GUIRoomSelection.lua")

local original_InitializeBackgroundRines = Class_ReplaceMethod("ns2d_GUIMarineBuyMenu", "_InitializeBackground", function (self)
	original_InitializeBackgroundRines()
	initializeRoomSpawnUI()
end)