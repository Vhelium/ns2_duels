decoda_name = "Client"
Script.Load("lua/ns2d/ns2d_Shared.lua")

Script.Load("lua/ns2d/ns2d_Utility.lua")
Script.Load("lua/ns2d/ns2d_Player_Client.lua")
Script.Load("lua/ns2d/ns2d_Armory_Client.lua")

local function OnLoadComplete()
	Shared.ConsoleCommand("cheats 1")
	Shared.ConsoleCommand("alltech 1")
	Shared.Message("OnLoadComplete. Now loading custom GUI...")
	Script.Load("lua/ns2d/ns2d_GUIScripts.lua")
end

Event.Hook("LoadComplete", OnLoadComplete)