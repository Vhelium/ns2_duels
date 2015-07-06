// ns2d_Player_Client.lua

local g_AlienBuyMenu = nil
local g_MarineBuyMenu = nil

// starting the custom buy menu for aliens
Class_ReplaceMethod("Alien", "Buy", function(self)

   // Dont allow display in the ready room, or as phantom
    if Client.GetLocalPlayer() == self then
    
        // The Embryo cannot use the buy menu in any case.
        if self:GetTeamNumber() ~= 0 and not self:isa("Embryo") then
        
            if not self.buyMenu then

                Shared.Message("Alien buy menu opened..")
            
				self.combatBuy = true
                self.buyMenu = GetGUIManager():CreateGUIScript("GUIAlienBuyMenu")
				g_AlienBuyMenu = self.buyMenu
                MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
                
            else
                Shared.Message("Alien buy menu closed..")
				self.combatBuy = false
                self:CloseMenu(true)
				
            end
            
        else
            self:PlayEvolveErrorSound()
        end
        
    end
	
	if not self.buyMenu then
		self.combatBuy = true
	else
		self.combatBuy = false
	end			
end)

// starting the custom buy menu for marines
function JetpackMarine:Buy()
   Marine.Buy(self)
end

// starting the custom buy menu for marines
function Marine:Buy()
   // Dont allow display in the ready room, or as phantom
    if Client.GetLocalPlayer() == self then
        if self:GetTeamNumber() ~= 0 then
        
            if not self.buyMenu then
                Shared.Message("Marine buy menu opened..")

                // open the buy menu
                self.combatBuy = true
                self.buyMenu = GetGUIManager():CreateGUIScript("Hud/ns2d_GUIMarineBuyMenu")
                g_MarineBuyMenu = self.buyMenu
                MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
            else
                Shared.Message("Marine buy menu closed..")
                self.combatBuy = false
                self:CloseMenu()
            end
        end
    end
end

local originalHandleButtons
originalHandleButtons = Class_ReplaceMethod("Exo", "HandleButtons", 
function(self, input)
    originalHandleButtons(self, input)

    if bit.band(input.commands, Move.Buy) ~= 0 then
        self:CloseMenu()
        Marine.Buy(self)
    end
end)

// costum CloseMenu that our buy menu will not be closed all the time (cause no structure is nearby)
function CloseMenu_Hook(self, closeCombatBuy)

    if self:GetIsLocalPlayer() then
        if self.buyMenu and g_AlienBuyMenu then
            // Handle closing the alien buy menu.
            if closeCombatBuy or not self.combatBuy then
                GetGUIManager():DestroyGUIScript(g_AlienBuyMenu)
                g_AlienBuyMenu = nil
                self.buyMenu = nil
                MouseTracker_SetIsVisible(false)
                return true
            end
        end
    
        if self.buyMenu and g_MarineBuyMenu then
            // only close it if its not the combatBuy
            if closeCombatBuy or not self.combatBuy then    
                GetGUIManager():DestroyGUIScript(g_MarineBuyMenu)
                g_MarineBuyMenu = nil
                self.buyMenu = nil
                MouseTracker_SetIsVisible(false)
                return true
            end        
        end
    end
   
    return false
end

Class_ReplaceMethod("Marine", "CloseMenu", CloseMenu_Hook)
Class_ReplaceMethod("Player", "CloseMenu", CloseMenu_Hook)

local originalUpdateClientEffects
originalUpdateClientEffects = Class_ReplaceMethod("Marine", "UpdateClientEffects", 
function(self, deltaTime, isLocal)
    originalUpdateClientEffects(self, deltaTime, isLocal)

    // Stop the regular buy menu from staying open.
    if self.buyMenu then
        self:CloseMenu()
    end
end)

// Close the menu properly when a player dies.
// Note: This does not trigger when players are killed via the console as that calls 'Kill' directly.
local originalAddTakeDamageIndicator
originalAddTakeDamageIndicator = Class_ReplaceMethod("Player", "AddTakeDamageIndicator", 
function(self, damagePosition)    
    if not self:GetIsAlive() and not self.deathTriggered then    
        self:CloseMenu(true)        
    end

    originalAddTakeDamageIndicator(self, damagePosition)
end)  

local originalUpdateMisc
originalUpdateMisc = Class_ReplaceMethod("Player", "UpdateMisc", 
function(self, input)

    originalUpdateMisc(self, input)

    if not Shared.GetIsRunningPrediction() then

        // Close the buy menu if it is visible when the Player moves.
        if input.move.x ~= 0 or input.move.z ~= 0 then
            self:CloseMenu(true)
        end
    end
end)  