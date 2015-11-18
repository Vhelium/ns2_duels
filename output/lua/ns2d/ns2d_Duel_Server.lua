

Script.Load("lua/ns2d/ns2d_TechTree_Hooks.lua")
Script.Load("lua/ns2d/ns2d_NS2Gamerules_Hooks.lua")
Script.Load("lua/ns2d/ns2d_Alien_Hooks_Server.lua")
Script.Load("lua/ns2d/ns2d_Marine_Hooks_Server.lua")
Script.Load("lua/ns2d/ns2d_PlayingTeam_Hooks.lua")

local function OnGiveJetpack(client, message)
    local player = client:GetControllingPlayer()
    if player:isa("Marine") then
        player:GiveJetpack()
    end
end

Server.HookNetworkMessage( "RoomGiveJetpack", OnGiveJetpack )