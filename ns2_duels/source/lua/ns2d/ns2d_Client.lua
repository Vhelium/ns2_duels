decoda_name = "Client"
Script.Load("lua/ns2d/ns2d_Utility.lua")
Script.Load("lua/ns2d/ns2d_Player_Client.lua")
Script.Load("lua/ns2d/ns2d_Armory_Client.lua")

Script.Load("lua/ns2d/Hud/ns2d_GUIMarineBuyMenu.lua")

local RemoveScripts = GetLocalFunction(ClientUI.EvaluateUIVisibility, 'RemoveScripts' )
local kShowAsClass = GetLocalFunction(RemoveScripts, 'kShowAsClass')
local kShowOnTeam = GetLocalFunction(RemoveScripts, 'kShowOnTeam')

kShowAsClass["Marine"]["ns2d/ns2d_Marine_Class_Hook"] = true
kShowAsClass["Alien"]["ns2d/ns2d_Alien_Class_Hook"] = true