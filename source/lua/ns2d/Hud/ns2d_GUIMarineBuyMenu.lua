// ns2d_GUIMarineBuyMenu.lua

Script.Load("lua/GUIAnimatedScript.lua")

class 'ns2d_GUIMarineBuyMenu' (GUIAnimatedScript)

ns2d_GUIMarineBuyMenu.kBackgroundTexture = "ui/marine_background_texture.dds"
ns2d_GUIMarineBuyMenu.kButtonTexture = "ui/marine_buymenu_button.dds"
ns2d_GUIMarineBuyMenu.kMenuSelectionTexture = "ui/marine_buymenu_selector.dds"
ns2d_GUIMarineBuyMenu.kContentBgBackTexture = "ui/marine_background_texture.dds" //"ui/repeating_bg_black.dds"
ns2d_GUIMarineBuyMenu.kContentBgTexture = "ui/marine_background_texture.dds" //"ui/repeating_bg.dds"
ns2d_GUIMarineBuyMenu.kSmallIconTexture = "ui/combat_marine_buildmenu.dds"

ns2d_GUIMarineBuyMenu.kFont = Fonts.kAgencyFB_Small

ns2d_GUIMarineBuyMenu.itemsPerRow = 4
ns2d_GUIMarineBuyMenu.upgradeHeadlines = { "Drops", "Armor Up", "Weapon Up", "Weapons", "Utility", "Reset"}

local smallIconHeight = 80
local smallIconWidth = 80

local function GetSmallIconPixelCoordinates(upgrTechId)
    
    local rows = ns2d_GUIMarineBuyMenu.itemsPerRow
    local textureOffset_x1 = upgrTechId % rows
    local textureOffset_y1 = math.floor(upgrTechId / rows)
    
    local pixelXOffset = textureOffset_x1 * smallIconWidth
    local pixelYOffset = textureOffset_y1 * smallIconHeight
        
    return pixelXOffset, pixelYOffset, pixelXOffset + smallIconWidth, pixelYOffset + smallIconHeight

end

local function upgradeExists(upgrTechId)
    return upgrTechId ~= 3 and upgrTechId < 21
end

function ns2d_GUIMarineBuyMenu:SetHostStructure(hostStructure)

    self.hostStructure = hostStructure
    self:_InitializeItemButtons()
    self.selectedItem = nil
    
end

function ns2d_GUIMarineBuyMenu:OnClose()

    // Check if GUIMarineBuyMenu is what is causing itself to close.
	self.player.combatBuy = false
    if not self.closingMenu then
        // Play the close sound since we didnt trigger the close.
        MarineBuy_OnClose()
    end

end

function ns2d_GUIMarineBuyMenu:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.player = Client.GetLocalPlayer()
    self.mouseOverStates = { }
    
    self:_InitializeFields()
    self:_InitializeBackground()
    self:_InitializeCloseButton()
    self:_InitializeUpgradeButtons()

    MarineBuy_OnOpen() //play sound
end

function ns2d_GUIMarineBuyMenu:_InitializeFields()

    ns2d_GUIMarineBuyMenu.kTextColor = Color(kMarineFontColor)

    ns2d_GUIMarineBuyMenu.kResourceDisplayHeight = GUIScale(64)

    ns2d_GUIMarineBuyMenu.kSmallIconSize = GUIScale( Vector(80, 80, 0) )
    ns2d_GUIMarineBuyMenu.kSelectorSize = GUIScale( Vector(100, 100, 0) )

    ns2d_GUIMarineBuyMenu.kSmallIconOffset_x = GUIScale(120)
    ns2d_GUIMarineBuyMenu.kIconTopOffset = 40

    ns2d_GUIMarineBuyMenu.kBackgroundWidth = GUIScale(600)
    ns2d_GUIMarineBuyMenu.kBackgroundHeight = GUIScale(520)

    ns2d_GUIMarineBuyMenu.kCloseButtonColor = Color(1, 1, 0, 1)

    ns2d_GUIMarineBuyMenu.kButtonWidth = GUIScale(160)
    ns2d_GUIMarineBuyMenu.kButtonHeight = GUIScale(64)

    ns2d_GUIMarineBuyMenu.kMenuWidth = GUIScale(128)
    ns2d_GUIMarineBuyMenu.kPadding = GUIScale(8)
end

function ns2d_GUIMarineBuyMenu:Update(deltaTime)

    GUIAnimatedScript.Update(self, deltaTime)

	self.player = Client.GetLocalPlayer()
    self:_UpdateCloseButton(deltaTime)
    self:_UpdateItemButtons(deltaTime)
    self:_UpdateUpgradesButtons(deltaTime)
    
end

function ns2d_GUIMarineBuyMenu:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    self:_UninitializeBackground()
    self:_UninitializeCloseButton()
    self:_UninitializeItemButtons()

end

// ------------------------------------------------------------------------------------------------------------------------------------------------------

function ns2d_GUIMarineBuyMenu:_InitializeBackground()

    // This invisible background is used for centering only.
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor(Color(0.05, 0.05, 0.1, 0.7))
    self.background:SetLayer(kGUILayerPlayerHUDForeground4)
    
    self.content = GUIManager:CreateGraphicItem()
    self.content:SetSize(Vector(ns2d_GUIMarineBuyMenu.kBackgroundWidth, ns2d_GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.content:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.content:SetPosition(Vector((-ns2d_GUIMarineBuyMenu.kBackgroundWidth / 2), -ns2d_GUIMarineBuyMenu.kBackgroundHeight / 2, 0))
    self.content:SetTexture(ns2d_GUIMarineBuyMenu.kBackgroundTexture)
    self.content:SetTexturePixelCoordinates(0, 0, 512, 256)
    self.background:AddChild(self.content)
    
 //   self.scanLine = self:CreateAnimatedGraphicItem()
 //   self.scanLine:SetSize( Vector( Client.GetScreenWidth(), ns2d_GUIMarineBuyMenu.kScanLineHeight, 0) )
 //   self.scanLine:SetTexture(ns2d_GUIMarineBuyMenu.kScanLineTexture)
 //   self.scanLine:SetLayer(kGUILayerPlayerHUDForeground4)
 //   self.scanLine:SetIsScaling(false)
 //   
 //   self.scanLine:SetPosition( Vector(0, -ns2d_GUIMarineBuyMenu.kScanLineHeight, 0) )
 //   self.scanLine:SetPosition( Vector(0, Client.GetScreenHeight() + ns2d_GUIMarineBuyMenu.kScanLineHeight, 0), ns2d_GUIMarineBuyMenu.kScanLineAnimDuration, "MARINEBUY_SCANLINE", AnimateLinear, MoveDownAnim)

end

function ns2d_GUIMarineBuyMenu:_UninitializeBackground()
    
    GUI.DestroyItem(self.background)
    self.background = nil
    self.content = nil

end

function ns2d_GUIMarineBuyMenu:_InitializeCloseButton()

    self.closeButton = GUIManager:CreateGraphicItem()
    self.closeButton:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.closeButton:SetSize(Vector(ns2d_GUIMarineBuyMenu.kButtonWidth, ns2d_GUIMarineBuyMenu.kButtonHeight, 0))
    self.closeButton:SetPosition(Vector(-ns2d_GUIMarineBuyMenu.kButtonWidth, ns2d_GUIMarineBuyMenu.kPadding, 0))
    self.closeButton:SetTexture(ns2d_GUIMarineBuyMenu.kButtonTexture)
    self.closeButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.content:AddChild(self.closeButton)
    
    self.closeButtonText = GUIManager:CreateTextItem()
    self.closeButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.closeButtonText:SetFontName(ns2d_GUIMarineBuyMenu.kFont)
    self.closeButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.closeButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.closeButtonText:SetText("EXIT")
    self.closeButtonText:SetFontIsBold(true)
    self.closeButtonText:SetColor(ns2d_GUIMarineBuyMenu.kCloseButtonColor)
    self.closeButton:AddChild(self.closeButtonText)
    
end

function ns2d_GUIMarineBuyMenu:_UpdateCloseButton(deltaTime)

    if self:_GetIsMouseOver(self.closeButton) then
        self.closeButton:SetColor(Color(1, 1, 1, 1))
    else
        self.closeButton:SetColor(Color(0.5, 0.5, 0.5, 1))
    end

end

function ns2d_GUIMarineBuyMenu:_UninitializeCloseButton()
    
    GUI.DestroyItem(self.closeButton)
    self.closeButton = nil

end

function ns2d_GUIMarineBuyMenu:_InitializeUpgradeButtons()
    
    self.menu = GetGUIManager():CreateGraphicItem()
    self.menu:SetPosition(Vector( -ns2d_GUIMarineBuyMenu.kMenuWidth - ns2d_GUIMarineBuyMenu.kPadding, 0, 0))
    self.menu:SetTexture(ns2d_GUIMarineBuyMenu.kContentBgTexture)
    self.menu:SetSize(Vector(ns2d_GUIMarineBuyMenu.kMenuWidth, ns2d_GUIMarineBuyMenu.kBackgroundHeight, 0))
    self.menu:SetTexturePixelCoordinates(0, 0, 512, 256)
    self.content:AddChild(self.menu)
    
    self.menuHeader = GetGUIManager():CreateGraphicItem()
    self.menuHeader:SetSize(Vector(ns2d_GUIMarineBuyMenu.kMenuWidth, ns2d_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetPosition(Vector(0, -ns2d_GUIMarineBuyMenu.kResourceDisplayHeight, 0))
    self.menuHeader:SetTexture(ns2d_GUIMarineBuyMenu.kContentBgBackTexture)
    self.menuHeader:SetTexturePixelCoordinates(0, 0, 512, 256)
    self.menu:AddChild(self.menuHeader)
    
    self.menuHeaderTitle = GetGUIManager():CreateTextItem()
    self.menuHeaderTitle:SetFontName(ns2d_GUIMarineBuyMenu.kFont)
    self.menuHeaderTitle:SetFontIsBold(true)
    self.menuHeaderTitle:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.menuHeaderTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.menuHeaderTitle:SetTextAlignmentY(GUIItem.Align_Center)
    self.menuHeaderTitle:SetColor(ns2d_GUIMarineBuyMenu.kTextColor)
    self.menuHeaderTitle:SetText("Select Upgrades:")
    self.menuHeader:AddChild(self.menuHeaderTitle)
    
    self.itemButtons = { }

    local headlines = self.upgradeHeadlines
    local nextHeadline = 1
    
    local selectorPosX = -ns2d_GUIMarineBuyMenu.kSelectorSize.x + ns2d_GUIMarineBuyMenu.kPadding
    local fontScaleVector = Vector(0.8, 0.8, 0)
    local itemInRowNr = 0
    local k = 1
    xOffset  = 0
    
    for upgrTechId=0, (#headlines * self.itemsPerRow) - 1, 1 do
    
        if upgrTechId % self.itemsPerRow == 0 then     // the first in row

            // if its first next row, only set the headline
            if upgrTechId > 0 then
                itemInRowNr = 0
                xOffset = xOffset + ns2d_GUIMarineBuyMenu.kSmallIconOffset_x
            end
            
            // set the headline
            local graphicItemHeading = GUIManager:CreateTextItem()
            graphicItemHeading:SetFontName(ns2d_GUIMarineBuyMenu.kFont)
            graphicItemHeading:SetFontIsBold(true)
            graphicItemHeading:SetAnchor(GUIItem.Middle, GUIItem.Top)
            graphicItemHeading:SetPosition(Vector((-ns2d_GUIMarineBuyMenu.kSmallIconSize.x/ 2) + xOffset, 5 + (ns2d_GUIMarineBuyMenu.kSmallIconSize.y) * itemInRowNr, 0))
            graphicItemHeading:SetTextAlignmentX(GUIItem.Align_Min)
            graphicItemHeading:SetTextAlignmentY(GUIItem.Align_Min)
            graphicItemHeading:SetColor(ns2d_GUIMarineBuyMenu.kTextColor)
            graphicItemHeading:SetText(headlines[nextHeadline] or "nothing")
            self.menu:AddChild(graphicItemHeading)
            
            nextHeadline = nextHeadline + 1

        end

        if upgradeExists(upgrTechId) then          // legit upgrade id?
            
            local graphicItem = GUIManager:CreateGraphicItem()
            graphicItem:SetSize(ns2d_GUIMarineBuyMenu.kSmallIconSize)
            graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
            graphicItem:SetPosition(Vector((-ns2d_GUIMarineBuyMenu.kSmallIconSize.x/ 2) + xOffset, ns2d_GUIMarineBuyMenu.kIconTopOffset + (ns2d_GUIMarineBuyMenu.kSmallIconSize.y) * itemInRowNr, 0))
            // set the tecture file for the icons
            graphicItem:SetTexture(ns2d_GUIMarineBuyMenu.kSmallIconTexture)
            // set the pixel coordinate for the icon
            graphicItem:SetTexturePixelCoordinates(GetSmallIconPixelCoordinates(upgrTechId))

            local graphicItemActive = GUIManager:CreateGraphicItem()
            graphicItemActive:SetSize(ns2d_GUIMarineBuyMenu.kSelectorSize)          
            graphicItemActive:SetPosition(Vector(selectorPosX, -ns2d_GUIMarineBuyMenu.kSelectorSize.y / 2, 0))
            graphicItemActive:SetAnchor(GUIItem.Right, GUIItem.Center)
            graphicItemActive:SetTexture(ns2d_GUIMarineBuyMenu.kMenuSelectionTexture)
            graphicItemActive:SetIsVisible(false)
            
            graphicItem:AddChild(graphicItemActive)
            
            self.menu:AddChild(graphicItem)
            table.insert(self.itemButtons, { Button = graphicItem, Highlight = graphicItemActive, UpgrTechId = upgrTechId} )
              
            itemInRowNr = itemInRowNr + 1
        end
    
    end
    
    // to prevent wrong display before the first update
    self:_UpdateItemButtons(0)

end

function ns2d_GUIMarineBuyMenu:_UpdateItemButtons(deltaTime)

    if self and self.itemButtons then
        for i, item in ipairs(self.itemButtons) do
        
            if self:_GetIsMouseOver(item.Button) then       
                item.Highlight:SetIsVisible(true)
            else 
               item.Highlight:SetIsVisible(false)
            end
        end
    end

end

function UpgradeActive(upgrTechid)
    local armorLvl = PlayerUI_GetArmorLevel(true)
    local weaponsLvl = PlayerUI_GetWeaponLevel(true)

    if upgrTechid - 4 < 4 and upgrTechid - 4 == armorLvl or
        upgrTechid - 8 < 4 and upgrTechid - 8 == weaponsLvl then
        return true
    end

    return false
end

function ns2d_GUIMarineBuyMenu:_UpdateUpgradesButtons(deltaTime)
    if self and self.itemButtons then
        for i, item in ipairs(self.itemButtons) do

            local useColor = Color(1,1,1,1)
            if UpgradeActive(item.UpgrTechId) then
                local anim = math.cos(Shared.GetTime() * 6) * 0.5 + 0.5
                useColor = Color(1, 1, anim, 1)
            end
            item.Button:SetColor(useColor)
            item.Highlight:SetColor(useColor)
        end
    end
end

function ns2d_GUIMarineBuyMenu:_UninitializeItemButtons()

/*
    for i, item in ipairs(self.itemButtons) do
        GUI.DestroyItem(item.Button)
    end
    self.itemButtons = nil
    */

end

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

/**
 * Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
 */
function ns2d_GUIMarineBuyMenu:_GetIsMouseOver(overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver
    
end

function ns2d_GUIMarineBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then

        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
                    
            inputHandled, closeMenu = self:_HandleItemClicked(mouseX, mouseY) or inputHandled
            
            if not inputHandled then
            
                // Check if the close button was pressed.
                if self:_GetIsMouseOver(self.closeButton) then
                    closeMenu = true
                    inputHandled = true
                    self:OnClose()
                end
				
				// Check if the refund button was pressed.
				//if not closeMenu then
				//	if self:_GetIsMouseOver(self.refundButton) then
				//	self:_ClickRefundButton()
				//	closeMenu = true
                //    inputHandled = true
                //    self:OnClose()
				//	end
				//end
            end
        end
        
    end
    
    if InputKey.Escape == key and not down then
        closeMenu = true
        inputHandled = true
        self:OnClose()
    end

    if closeMenu then
        self.closingMenu = true
        self:OnClose()
    end
    
    return inputHandled
    
end

function ns2d_GUIMarineBuyMenu:_HandleItemClicked(mouseX, mouseY)
        
        for i, item in ipairs(self.itemButtons) do
    
            if self:_GetIsMouseOver(item.Button) then
                
                if item.UpgrTechId == 0 then                                 // Heal 
                    Shared.ConsoleCommand("heal 3000")
                elseif item.UpgrTechId == 1 then                             // catpack
                    Shared.ConsoleCommand("catpack")
                elseif item.UpgrTechId == 2 then                             // nanoshield
                    Shared.ConsoleCommand("nanoshield")
                elseif item.UpgrTechId >= 4 and item.UpgrTechId <= 7 then    // a0-a3
                    local a = item.UpgrTechId - 4
                    Shared.ConsoleCommand("a"..a)
                elseif item.UpgrTechId >= 8 and item.UpgrTechId <= 11 then   // w0-w3
                    local w = item.UpgrTechId - 8
                    Shared.ConsoleCommand("w"..w)
                elseif item.UpgrTechId == 12 then                            // rifle
                    if not self.player:isa("Exo") then
                        Shared.ConsoleCommand("give rifle")
                    end
                elseif item.UpgrTechId == 13 then                            // shotgun
                    if not self.player:isa("Exo") then
                        Shared.ConsoleCommand("give shotgun")
                    end
                elseif item.UpgrTechId == 14 then                            // GL
                    if not self.player:isa("Exo") then
                        Shared.ConsoleCommand("give grenadelauncher")
                    end
                elseif item.UpgrTechId == 15 then                            // FT
                    if not self.player:isa("Exo") then
                        Shared.ConsoleCommand("give flamethrower")
                    end
                elseif item.UpgrTechId == 16 then                            // JP
                    if not self.player:isa("Exo") then
                        Client.SendNetworkMessage( "RoomGiveJetpack", { } , true )
                        --Shared.ConsoleCommand("jetpack")
                    end
                elseif item.UpgrTechId == 17 then                            // exo
                    Shared.ConsoleCommand("exo")
                elseif item.UpgrTechId == 18 then                            // dualminigun
                    Shared.ConsoleCommand("dualminigun")
                elseif item.UpgrTechId == 19 then                            // dualrailgun
                    Shared.ConsoleCommand("dualrailgun")
                elseif item.UpgrTechId == 20 then                            // reset
                    Shared.ConsoleCommand("marine")
                    Shared.ConsoleCommand("give rifle")
                else
                    //nothing
                end

                return true, false
            end
            
        end 

    return false, false
    
end

//-----------------------------------------------------------------------------------------------------------------------------------