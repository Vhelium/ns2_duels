Script.Load("lua/ns2d/Hud/ns2d_GUIMarineBuyMenu.lua")
Script.Load("lua/ns2d/Hud/ns2d_GUIRoomSelection.lua")

local original_InitializeBackgroundRines
original_InitializeBackgroundRines = Class_ReplaceMethod("ns2d_GUIMarineBuyMenu", "_InitializeBackground", function (self)
	original_InitializeBackgroundRines(self)
	RoomSpawnUI_Initialize(self)
end)

local original_SendKeyEventMarines
original_SendKeyEventMarines = Class_ReplaceMethod("ns2d_GUIMarineBuyMenu", "SendKeyEvent", function (self, key, down)
	local roomRes = RoomSpawnUI_SendKeyEvent(self, key, down)
	if not roomRes then
		return original_SendKeyEventMarines(self, key, down)
	end
	return roomRes
end)

local original_UpdateMarines
original_UpdateMarines = Class_ReplaceMethod("ns2d_GUIMarineBuyMenu", "Update", function (self, deltaTime)
	original_UpdateMarines(self, deltaTime)
	RoomSpawnUI_Update(self, deltaTime)
end)

Class_ReplaceMethod("Marine", "Drop", function (self, player)
    -- nothing :>
end)