function GUIBiomass_Initialize(self)
    self.biomassButtons = {}

    local parent = self.content
    if not self.content then // AlienUI
        parent = self.background
    end

    local backgroundTexture = "ui/marine_background_texture.dds"
    local bioTexture = "ui/combat_marine_buildmenu.dds"
    local iconSize = GUIScale( Vector(30, 30, 0) )
    local kSelectorSize = GUIScale( Vector(33, 33, 0) )

    self.bioContent = GUIManager:CreateGraphicItem()
    self.bioContent:SetSize(Vector(iconSize.x, iconSize.y * 12, 0))
    self.bioContent:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.bioContent:SetPosition(Vector(-iconSize.x, 0, 0))
    --if Client.GetLocalPlayer():GetTeamNumber() == kAlienTeamType then self.bioContent:SetColor(kAlienFontColor) end
    parent:AddChild(self.bioContent)

    // Biomass Buttons:
    for index=1, 12, 1 do
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(iconSize)
        graphicItem:SetAnchor(GUIItem.Left, GUIItem.Top)
        graphicItem:SetPosition(Vector(0, (iconSize.y) * (index-1), 0))
        graphicItem:SetTexture(bioTexture)
        graphicItem:SetTexturePixelCoordinates(4 * 80, 0, 5 * 80, 80)
        graphicItem:SetColor(kAlienFontColor)

        local graphicItemActive = GUIManager:CreateGraphicItem()
        graphicItemActive:SetSize(kSelectorSize)          
        graphicItemActive:SetPosition(Vector(-kSelectorSize.x / 2, -kSelectorSize.y / 2, 0))
        graphicItemActive:SetAnchor(GUIItem.Center, GUIItem.Center)
        graphicItemActive:SetTexture(kMenuSelectionTexture)
        graphicItemActive:SetIsVisible(false)
        
        graphicItem:AddChild(graphicItemActive)

        local itemText = GUIManager:CreateTextItem()
        itemText:SetFontName(Fonts.kAgencyFB_Small)
        itemText:SetFontIsBold(true)
        itemText:SetAnchor(GUIItem.Center, GUIItem.Center)
        itemText:SetPosition(Vector(1, 5, 0))
        itemText:SetTextAlignmentX(GUIItem.Align_Center)
        itemText:SetTextAlignmentY(GUIItem.Align_Center)
        itemText:SetScale(GUIScale(Vector(1, 1, 1)))
        itemText:SetColor(kAlienFontColor)
        itemText:SetText(""..index)

        graphicItem:AddChild(itemText)

        self.bioContent:AddChild(graphicItem)

        table.insert(self.biomassButtons, { Button = graphicItem, Highlight = graphicItemActive, Index = index })
    end

end

local function PlayerUI_GetBiomassLevel(nop)
	return -1
end

function GUIBiomass_Update(self)
    for i, item in ipairs(self.biomassButtons) do
    
        if GUIBiomass_GetIsMouseOver(self, item.Button) then       
            item.Highlight:SetIsVisible(true)
        else 
            item.Highlight:SetIsVisible(false)
        end

        local useColor = Color(1,1,1,1)
        if PlayerUI_GetBiomassLevel(true) == i then
            local anim = math.cos(Shared.GetTime() * 6) * 0.5 + 0.5
            useColor = Color(1, 1, anim, 1)
        end
        item.Button:SetColor(useColor)
        item.Highlight:SetColor(useColor)

    end
end

function GUIBiomass_GetIsMouseOver(self, overItem)
    return GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
end

GUIBiomass_mousePressed = false

function GUIBiomass_SendKeyEvent(self, key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and GUIBiomass_mousePressed ~= down then

        GUIBiomass_mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
            inputHandled, closeMenu = GUIBiomass_HandleItemClicked(self, mouseX, mouseY) or inputHandled
        end
        
    end

    if closeMenu then
        self.closingMenu = true
        self:OnClose()
    end
    
    return inputHandled
end

function GUIBiomass_HandleItemClicked(self, mouseX, mouseY)

    for i, item in ipairs(self.biomassButtons) do

        if GUIBiomass_GetIsMouseOver(self, item.Button) then

            GUIBiomass_mousePressed = false

            Shared.ConsoleCommand("biomass "..item.Index)

            return true, true
        end
    end 

    return false, false
    
end

local kBioMassTechIds =
{
    [1]=kTechId.BioMassOne,
    [2]=kTechId.BioMassTwo,
    [3]=kTechId.BioMassThree,
    [4]=kTechId.BioMassFour,
    [5]=kTechId.BioMassFive,
    [6]=kTechId.BioMassSix,
    [7]=kTechId.BioMassSeven,
    [8]=kTechId.BioMassEight,
    [9]=kTechId.BioMassNine
}

-- returns 0 - 3
function PlayerUI_GetBiomassLevel(researched)
    local biomassLvl = 0
    
    if Client.GetLocalPlayer().gameStarted then
    
        local techTree = GetTechTree()
    
        if techTree then

        	for lvl = 9, 1, -1 do
            	local biomassNode = techTree:GetTechNode(kBioMassTechIds[lvl])
            	if biomassNode and biomassNode:GetResearched() then
            		biomassLvl = lvl
            		break
            	end
        	end
            
        end
    
    end

    return biomassLvl
end