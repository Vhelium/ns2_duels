Script.Load("lua/GUIAlienBuyMenu.lua")
Script.Load("lua/ns2d/Hud/ns2d_GUIRoomSelection.lua")
Script.Load("lua/ns2d/Hud/ns2d_GUIBiomassSelection.lua")

GUIAlienBuyMenu.kDisabledColor = Color(1, 1, 1, 1)
GUIAlienBuyMenu.kCannotBuyColor = Color(1, 1, 1, 1)

local original_InitializeBackgroundAliens
original_InitializeBackgroundAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "_InitializeBackground", function (self)
	original_InitializeBackgroundAliens(self)
	RoomSpawnUI_Initialize(self)
    GUIBiomass_Initialize(self)
end)

local original_UpdateAliens
original_UpdateAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "Update", function (self, deltaTime)
	original_UpdateAliens(self, deltaTime)
	RoomSpawnUI_Update(self, deltaTime)
    GUIBiomass_Update(self)
end)

--local getSelectedUpgradesCost = GetLocalFunction(updateEvolveButton, "GetSelectedUpgradesCost")

local function GetAlienOrUpgradeSelected(self)
    return self.selectedAlienType ~= AlienBuy_GetCurrentAlien() or GetNumberOfNewlySelectedUpgrades(self) > 0
end

local function GetNumberOfNewlySelectedUpgrades(self)

    local numSelected = 0
    local player = Client.GetLocalPlayer()
    
    if player then
    
        for i, currentButton in ipairs(self.upgradeButtons) do
        
            if currentButton.Selected and not player:GetHasUpgrade(currentButton.TechId) then
                numSelected = numSelected + 1
            end
            
        end
    
    end
    
    return numSelected 

end

local function MarkAlreadyPurchased( self )
    local isAlreadySelectedAlien = not self:GetNewLifeFormSelected()
    for i, currentButton in ipairs(self.upgradeButtons) do
        currentButton.Purchased = isAlreadySelectedAlien and AlienBuy_GetUpgradePurchased( currentButton.TechId )
    end
end

local sendKeyEvent = function(self, key, down)
	local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
    
        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
        
            local allowedToEvolve = PlayerUI_GetHasGameStarted()
            if allowedToEvolve and self:_GetIsMouseOver(self.evolveButtonBackground) then
            
                local purchases = { }
                -- Buy the selected alien if we have a different one selected.
                --if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
                    table.insert(purchases, { Type = "Alien", Alien = self.selectedAlienType })
                --end
                
               -- Buy all selected upgrades
                for i, currentButton in ipairs(self.upgradeButtons) do
                
                    if currentButton.Selected then
                        table.insert(purchases, { Type = "Upgrade", Alien = self.selectedAlienType, UpgradeIndex = currentButton.Index, TechId = currentButton.TechId })
                    end
                    
                end
                
                closeMenu = true
                inputHandled = true
                
                --if #purchases > 0 then
                    AlienBuy_Purchase(purchases)
                --end
                
                AlienBuy_OnPurchase()
                
            end
            
            inputHandled = self:_HandleUpgradeClicked(mouseX, mouseY) or inputHandled
            
            if not inputHandled then
            
                -- Check if an alien was selected.
                for k, buttonItem in ipairs(self.alienButtons) do
                
                    local researched, researchProgress, researching = true, true, false
                    if (researched or researching) and self:_GetIsMouseOver(buttonItem.Button) then
                    
                        -- Deselect all upgrades when a different alien type is selected.
                        if self.selectedAlienType ~= buttonItem.TypeData.Index then
                        
                            AlienBuy_OnSelectAlien(GUIAlienBuyMenu.kAlienTypes[buttonItem.TypeData.Index].Name)

                        end

                        self.selectedAlienType = buttonItem.TypeData.Index
                        MarkAlreadyPurchased( self )
                        self:SetPurchasedSelected()
                        
                        inputHandled = true
                        break
                        
                    end
                    
                end
                
                -- Check if the close button was pressed.
                if self:_GetIsMouseOver(self.closeButton) then
                
                    closeMenu = true
                    inputHandled = true
                    AlienBuy_OnClose()
                    
                end
                
            end
            
        end
        
    end
    
    // No matter what, this menu consumes MouseButton0/1 down.
    if down and (key == InputKey.MouseButton0 or key == InputKey.MouseButton1) then
        inputHandled = true
    end
    
    // AlienBuy_Close() must be the last thing called.
    if closeMenu then
    
        self.closingMenu = true
        AlienBuy_Close()
        
    end
    
    return inputHandled
end

local original_SendKeyEventAliens
original_SendKeyEventAliens = Class_ReplaceMethod("GUIAlienBuyMenu", "SendKeyEvent", function (self, key, down)
	local roomRes = RoomSpawnUI_SendKeyEvent(self, key, down)
	if not roomRes then

        local bioRes = GUIBiomass_SendKeyEvent(self, key, down)
        if not bioRes then
		    return sendKeyEvent(self, key, down)
        end
        return bioRes

	end
	return roomRes
end)

ReplaceUpValue(GUIAlienBuyMenu.Update, "UpdateEvolveButton", function(self)

    local researched, researchProgress, researching = true, true, false
    local selectedUpgradesCost = 0
    local numberOfSelectedUpgrades = 3
    local evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonTextureCoordinates
    local hasGameStarted = PlayerUI_GetHasGameStarted()
    local evolveText = Locale.ResolveString("ABM_EVOLVE_FOR")
    local evolveCost = 0
    
    self.evolveButtonBackground:SetTexturePixelCoordinates(unpack(evolveButtonTextureCoords))
    self.evolveButtonText:SetText(evolveText)
    self.evolveResourceIcon:SetIsVisible(evolveCost ~= nil)
    local totalEvolveButtonTextWidth = 0
    
    if evolveCost ~= nil then
    
        local evolveCostText = ToString(evolveCost)
        self.evolveButtonResAmount:SetText(evolveCostText)
        totalEvolveButtonTextWidth = totalEvolveButtonTextWidth + self.evolveResourceIcon:GetSize().x +
                                     self.evolveButtonResAmount:GetTextWidth(evolveCostText)
        
    end
    
    self.evolveButtonText:SetPosition(Vector(-totalEvolveButtonTextWidth / 2, 0, 0))
    
    local allowedToEvolve = hasGameStarted
    local veinsAlpha = 0
    self.evolveButtonBackground:SetScale(Vector(1, 1, 0))
    
    if allowedToEvolve then
    
        if self:_GetIsMouseOver(self.evolveButtonBackground) then
        
            veinsAlpha = 1
            self.evolveButtonBackground:SetScale(Vector(1.1, 1.1, 0))
            
        else
            veinsAlpha = (math.sin(Shared.GetTime() * 4) + 1) / 2
        end
        
    end
    
    self.evolveButtonVeins:SetColor(Color(1, 1, 1, veinsAlpha))

end, { LocateRecurse = true, CopyUpValues = true })

function AlienBuy_Purchase(purchaseTable)

    ASSERT(type(purchaseTable) == "table")
    
    local purchaseTechIds = { }
    
    for i, purchase in ipairs(purchaseTable) do

        if purchase.Type == "Alien" then
            table.insert(purchaseTechIds, IndexToAlienTechId(purchase.Alien))
        elseif purchase.Type == "Upgrade" then
            table.insert(purchaseTechIds, purchase.TechId)
        end
    
    end
    
    Client.SendNetworkMessage("Evolve", BuildBuyMessage(purchaseTechIds), true)
end