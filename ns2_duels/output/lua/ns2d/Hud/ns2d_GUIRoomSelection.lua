
RoomSpawnUI_roomButtons = { }

function RoomSpawnUI_Initialize(self)

    local parent = self.content
    if not self.content then // AlienUI
        parent = self.background
    end

    local roomcount = 5

    local backgroundTexture = "ui/marine_background_texture.dds"
    local roomTexture = "ui/combat_marine_buildmenu.dds"

    local width = GUIScale(200)
    local height = GUIScale(500)
    local offsetX = GUIScale(250)

    local iconSize = GUIScale( Vector(80, 80, 0) )

    self.roomContent = GUIManager:CreateGraphicItem()
    self.roomContent:SetSize(Vector(width, height, 0))
    self.roomContent:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.roomContent:SetPosition(Vector(offsetX, - parent:GetSize().y / 2, 0))
    self.roomContent:SetTexture(backgroundTexture)
    self.roomContent:SetTexturePixelCoordinates(0, 0, width, height)
    parent:AddChild(self.roomContent)

    local graphicItemHeading = GUIManager:CreateTextItem()
    graphicItemHeading:SetFontName(Fonts.kAgencyFB_Small)
    graphicItemHeading:SetFontIsBold(true)
    graphicItemHeading:SetAnchor(GUIItem.Middle, GUIItem.Top)
    graphicItemHeading:SetPosition(Vector(-iconSize.x/ 2, 10, 0))
    graphicItemHeading:SetTextAlignmentX(GUIItem.Align_Min)
    graphicItemHeading:SetTextAlignmentY(GUIItem.Align_Min)
    graphicItemHeading:SetColor(Color(kMarineFontColor))
    graphicItemHeading:SetText("Select Room:")
    self.roomContent:AddChild(graphicItemHeading)

    RoomSpawnUI_roomButtons = { }

    // Room Buttons:
    for roomId=1, roomcount, 1 do
        local graphicItem = GUIManager:CreateGraphicItem()
        graphicItem:SetSize(iconSize)
        graphicItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        graphicItem:SetPosition(Vector(-iconSize.x/ 2, -20 + (iconSize.y) * roomId, 0))
        // set the tecture file for the icons
        graphicItem:SetTexture(roomTexture)
        // set the pixel coordinate for the icon
        graphicItem:SetTexturePixelCoordinates(4 * 80, 0, 5 * 80, 80)

        local itemText = GUIManager:CreateTextItem()
        itemText:SetFontName(Fonts.kAgencyFB_Medium)
        itemText:SetFontIsBold(true)
        itemText:SetAnchor(GUIItem.Center, GUIItem.Center)
        itemText:SetPosition(Vector(1, 5, 0))
        itemText:SetTextAlignmentX(GUIItem.Align_Center)
        itemText:SetTextAlignmentY(GUIItem.Align_Center)
        itemText:SetScale(GUIScale(Vector(1, 1, 1)))
        itemText:SetColor(kAlienFontColor)
        itemText:SetText(""..roomId)

        graphicItem:AddChild(itemText)

        self.roomContent:AddChild(graphicItem)

        table.insert(RoomSpawnUI_roomButtons, { Button = graphicItem, Highlight = graphicItemActive, RoomId = roomId} )
    end
end

function RoomSpawnUI_Update(self, deltaTime)
    // NOT HOOKED YET
end

function RoomSpawnUI_Uninitialize(self)
    // NOT HOOKED YET
end

RoomSpawnUI_mousePressed = false

function RoomSpawnUI_SendKeyEvent(self, key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and RoomSpawnUI_mousePressed ~= down then

        RoomSpawnUI_mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
            inputHandled, closeMenu = RoomSpawnUI_HandleItemClicked(self, mouseX, mouseY) or inputHandled
        end
        
    end

    if closeMenu then
        self.closingMenu = true
        self:OnClose()
    end
    
    return inputHandled
end
function RoomSpawnUI_GetIsMouseOver(self, overItem)

    local mouseOver = GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    // if mouseOver and not self.mouseOverStates[overItem] then
    //    MarineBuy_OnMouseOver()
    //end
    //self.mouseOverStates[overItem] = mouseOver
    return mouseOver
end

function RoomSpawnUI_HandleItemClicked(self, mouseX, mouseY)
        
    for i, item in ipairs(RoomSpawnUI_roomButtons) do

        if RoomSpawnUI_GetIsMouseOver(self, item.Button) then

            RoomSpawnUI_mousePressed = false
            self.closingMenu = true
            self:OnClose()

            //Shared.ConsoleCommand("room "..item.RoomId)
            Client.SendNetworkMessage( "RoomJoinRoom", { RoomId = item.RoomId } , true )

            return true, true
        end
        
    end 

    return false, false
    
end