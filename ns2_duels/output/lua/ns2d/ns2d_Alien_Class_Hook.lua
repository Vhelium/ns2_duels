Script.Load("lua/GUIAlienBuyMenu.lua")
Script.Load("lua/ns2d/Hud/ns2d_GUIRoomSelection.lua")

local original_InitializeBackgroundAliens
original_InitializeBackgroundAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "_InitializeBackground", function (self)
	original_InitializeBackgroundAliens(self)
	RoomSpawnUI_Initialize(self)
end)

local original_SendKeyEventAliens
original_SendKeyEventAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "SendKeyEvent", function (self, key, down)
	local roomRes = RoomSpawnUI_SendKeyEvent(self, key, down)
	if not roomRes then
		return original_SendKeyEventAliens(self, key, down)
	end
	return roomRes
end)

local original_UpdateAliens
original_UpdateAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "Update", function (self, deltaTime)
	original_UpdateAliens(self, deltaTime)
	RoomSpawnUI_Update(self, deltaTime)
end)