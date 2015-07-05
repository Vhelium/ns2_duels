// ns2d_GUIMarineBuyMenu.lua

Script.Load("lua/GUIAnimatedScript.lua")

class 'ns2d_GUIMarineBuyMenu' (GUIAnimatedScript)

ns2d_GUIMarineBuyMenu.kBackgroundTexture = "ui/marine_background_texture.dds"
ns2d_GUIMarineBuyMenu.kButtonTexture = "ui/marine_buymenu_button.dds"

ns2d_GUIMarineBuyMenu.kFont = Fonts.kAgencyFB_Small

ns2d_GUIMarineBuyMenu.kSmallIconSize = GUIScale( Vector(80, 80, 0) )

ns2d_GUIMarineBuyMenu.kBackgroundWidth = GUIScale(600)
ns2d_GUIMarineBuyMenu.kBackgroundHeight = GUIScale(520)

ns2d_GUIMarineBuyMenu.kCloseButtonColor = Color(1, 1, 0, 1)

ns2d_GUIMarineBuyMenu.kButtonWidth = GUIScale(160)
ns2d_GUIMarineBuyMenu.kButtonHeight = GUIScale(64)

ns2d_GUIMarineBuyMenu.kPadding = GUIScale(8)

function ns2d_GUIMarineBuyMenu:SetHostStructure(hostStructure)

    self.hostStructure = hostStructure
    //self:_InitializeItemButtons()
    //self.selectedItem = nil
    
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
    
    self:_InitializeBackground()
    self:_InitializeCloseButton()

    MarineBuy_OnOpen() //play sound
    
end

function ns2d_GUIMarineBuyMenu:Update(deltaTime)

    GUIAnimatedScript.Update(self, deltaTime)

	self.player = Client.GetLocalPlayer()
    self:_UpdateBackground(deltaTime)
    self:_UpdateCloseButton(deltaTime)
    
end

function ns2d_GUIMarineBuyMenu:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)

    self:_UninitializeBackground()
    self:_UninitializeCloseButton()

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
    self.content:SetTexturePixelCoordinates(0, 0, ns2d_GUIMarineBuyMenu.kBackgroundWidth, ns2d_GUIMarineBuyMenu.kBackgroundHeight)
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

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
				
				// Check if the close button was pressed.
				if not closeMenu then
					if self:_GetIsMouseOver(self.refundButton) then
					self:_ClickRefundButton()
					closeMenu = true
                    inputHandled = true
                    self:OnClose()
					end
				end
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