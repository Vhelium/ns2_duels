
RoomSpawnUI_roomButtons = { }
RoomSpawnUI_groupPanels = { }
RoomSpawnUI_cmdNewGroup = nil

function RoomSpawnUI_Initialize(self)

    RoomSpawnUI_roomButtons = { }
    RoomSpawnUI_groupPanels = { }
    RoomSpawnUI_cmdNewGroup = nil

    local parent = self.content
    if not self.content then // AlienUI
        parent = self.background
    end

    local roomcount = 5

    local backgroundTexture = "ui/marine_background_texture.dds"
    local roomTexture = "ui/combat_marine_buildmenu.dds"

    local widthGroups = GUIScale(250)
    local widthRooms = GUIScale(180)
    local height = GUIScale(500)
    local offsetX = GUIScale(50)

    local iconSize = GUIScale( Vector(80, 80, 0) )

    self.groupContent = GUIManager:CreateGraphicItem()
    self.groupContent:SetSize(Vector(widthGroups, height, 0))
    self.groupContent:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.groupContent:SetPosition(Vector(offsetX, - parent:GetSize().y / 2, 0))
    self.groupContent:SetTexture(backgroundTexture)
    self.groupContent:SetTexturePixelCoordinates(0, 0, widthGroups, height)
    parent:AddChild(self.groupContent)

    RoomSpawnUI_cmdNewGroup = GUIManager:CreateGraphicItem()
    RoomSpawnUI_cmdNewGroup:SetSize(GUIScale( Vector(160, 60, 0) ))
    RoomSpawnUI_cmdNewGroup:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    RoomSpawnUI_cmdNewGroup:SetPosition(Vector(- RoomSpawnUI_cmdNewGroup:GetSize().x / 2, - RoomSpawnUI_cmdNewGroup:GetSize().y - 20, 0))
    RoomSpawnUI_cmdNewGroup:SetTexture(roomTexture)
    RoomSpawnUI_cmdNewGroup:SetTexturePixelCoordinates(4 * 80, 0, 5 * 80, 80)
    self.groupContent:AddChild(RoomSpawnUI_cmdNewGroup)

    local newGroupText = GUIManager:CreateTextItem()
    newGroupText:SetFontName(Fonts.kAgencyFB_Medium)
    newGroupText:SetFontIsBold(true)
    newGroupText:SetAnchor(GUIItem.Middle, GUIItem.Middle)
    newGroupText:SetPosition(Vector(0, 0, 0))
    newGroupText:SetTextAlignmentX(GUIItem.Align_Center)
    newGroupText:SetTextAlignmentY(GUIItem.Align_Center)
    newGroupText:SetColor(Color(kAlienFontColor))
    newGroupText:SetText("Create Group")
    RoomSpawnUI_cmdNewGroup:AddChild(newGroupText)

    self.roomContent = GUIManager:CreateGraphicItem()
    self.roomContent:SetSize(Vector(widthRooms, height, 0))
    self.roomContent:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.roomContent:SetPosition(Vector(offsetX + self.groupContent:GetPosition().x + widthGroups + GUIScale(8), - parent:GetSize().y / 2, 0))
    self.roomContent:SetTexture(backgroundTexture)
    self.roomContent:SetTexturePixelCoordinates(0, 0, widthRooms, height)
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
        graphicItem:SetAnchor(GUIItem.Left, GUIItem.Top)
        graphicItem:SetPosition(Vector(GUIScale(14), -20 + (iconSize.y) * roomId, 0))
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

        local groupText = GUIManager:CreateTextItem()
        groupText:SetFontName(Fonts.kAgencyFB_Medium)
        groupText:SetFontIsBold(true)
        groupText:SetAnchor(GUIItem.Right, GUIItem.Center)
        groupText:SetPosition(Vector(8, 0, 0))
        groupText:SetTextAlignmentX(GUIItem.Align_Min)
        groupText:SetTextAlignmentY(GUIItem.Align_Center)
        groupText:SetScale(GUIScale(Vector(1, 1, 1)))
        groupText:SetColor(kAlienFontColor)
        groupText:SetText("empty")

        graphicItem:AddChild(groupText)

        self.roomContent:AddChild(graphicItem)

        table.insert(RoomSpawnUI_roomButtons, { Button = graphicItem, Highlight = graphicItemActive, RoomId = roomId, GroupText = groupText })
    end

    RoomSpawnUI_Update(self, 0) -- force Update to load GroupPanels
end

local function getPlayerTextList(grpId)
    local res = ""
    for pId, player in pairs(RoomManager.playersInGroup[grpId]) do
        res = res..''..player..'\n'
    end
    return res
end

function RoomSpawnUI_Update(self, deltaTime)
    for i, cmdRoom in ipairs(RoomSpawnUI_roomButtons) do
        if RoomManager.groupInRoom[cmdRoom.RoomId] ~= nil then
            cmdRoom.GroupText:SetText("(Group "..RoomManager.groupInRoom[cmdRoom.RoomId]..")")
        else
            cmdRoom.GroupText:SetText("empty")
        end
    end

    -- Check for GroupPanels-To-Remove:
    for grpId, grpPanel in pairs(RoomSpawnUI_groupPanels) do
        if RoomManager.playersInGroup[grpId] == nil then
            -- Remove the Group Panel
            Shared.Message("Remove unused GroupPanel: "..grpId)
            self.groupContent:RemoveChild(RoomSpawnUI_groupPanels[grpId].Panel)
            GUI.DestroyItem(RoomSpawnUI_groupPanels[grpId].Panel)
            RoomSpawnUI_groupPanels[grpId] = nil
        end
    end

    -- update existing or create new GroupPanels:
    for grpId, grp in pairs(RoomManager.playersInGroup) do
        -- check if group panel exists:
        if RoomSpawnUI_groupPanels[grpId] == nil then
            -- create group panel

            local groupTexture = "ui/combat_marine_buildmenu.dds"

            local groupPanel = GUIManager:CreateGraphicItem()
            groupPanel:SetSize(Vector(self.groupContent:GetSize().x, 1, 0))
            groupPanel:SetAnchor(GUIItem.Left, GUIItem.Top)
            groupPanel:SetPosition(Vector(4, 4, 0))
            groupPanel:SetColor(Color(0.05, 0.05, 0.1, 0.7))

            local groupButton = GUIManager:CreateGraphicItem()
            groupButton:SetSize(GUIScale( Vector(60, 60, 0) ))
            groupButton:SetAnchor(GUIItem.Left, GUIItem.Top)
            groupButton:SetPosition(Vector(GUIScale(3), GUIScale(3), 0))
            groupButton:SetTexture(groupTexture)
            groupButton:SetTexturePixelCoordinates(5 * 80, 0, 6 * 80, 80)

            local groupText = GUIManager:CreateTextItem()
            groupText:SetFontName(Fonts.kAgencyFB_Medium)
            groupText:SetFontIsBold(true)
            groupText:SetAnchor(GUIItem.Center, GUIItem.Center)
            groupText:SetPosition(Vector(1, 5, 0))
            groupText:SetTextAlignmentX(GUIItem.Align_Center)
            groupText:SetTextAlignmentY(GUIItem.Align_Center)
            groupText:SetScale(GUIScale(Vector(1, 1, 1)))
            groupText:SetColor(kAlienFontColor)
            groupText:SetText(""..grpId)

            groupButton:AddChild(groupText)

            groupPanel:AddChild(groupButton)

            local playerTextOffsetY = groupButton:GetSize().y / 3

            -- PlayerlistText
            local groupPlayersText = GUIManager:CreateTextItem()
            groupPlayersText:SetFontName(Fonts.kAgencyFB_Small)
            groupPlayersText:SetFontIsBold(true)
            groupPlayersText:SetAnchor(GUIItem.Left, GUIItem.Top)
            groupPlayersText:SetPosition(Vector(groupButton:GetPosition().x + groupButton:GetSize().x + 5, playerTextOffsetY, 0))
            groupPlayersText:SetTextAlignmentX(GUIItem.Align_Min)
            groupPlayersText:SetTextAlignmentY(GUIItem.Align_Center)
            groupPlayersText:SetScale(GUIScale(Vector(1, 1, 1)))
            groupPlayersText:SetColor(kAlienFontColor)
            groupPlayersText:SetText(getPlayerTextList(grpId))

            groupPanel:AddChild(groupPlayersText)

            -- apply height to groupPanel
            local height = math.max(playerTextOffsetY + groupPlayersText:GetSize().y, groupButton:GetSize().y + 8)
            groupPanel:SetSize(Vector(groupPanel:GetSize().x, height, 0))

            self.groupContent:AddChild(groupPanel)

            RoomSpawnUI_groupPanels[grpId] = { Panel = groupPanel, Button = groupButton, PlayersText = groupPlayersText }
        else
            -- update player list
            RoomSpawnUI_groupPanels[grpId].PlayersText:SetText(getPlayerTextList(grpId))

            -- apply height to groupPanel
            local playerTextOffsetY = RoomSpawnUI_groupPanels[grpId].Button:GetSize().y / 3
            local height = math.max(playerTextOffsetY + RoomSpawnUI_groupPanels[grpId].PlayersText:GetSize().y, RoomSpawnUI_groupPanels[grpId].Button:GetSize().y + 8)
            RoomSpawnUI_groupPanels[grpId].Panel:SetSize(Vector(RoomSpawnUI_groupPanels[grpId].Panel:GetSize().x, height, 0))
        end

        -- TODO: Align Group Panels Y
        
    end
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

    if RoomSpawnUI_GetIsMouseOver(self, RoomSpawnUI_cmdNewGroup) then
        Client.SendNetworkMessage( "RoomJoinGroup", { GroupId = -1 } , true )
        return true, false
    end
        
    for i, item in ipairs(RoomSpawnUI_roomButtons) do

        if RoomSpawnUI_GetIsMouseOver(self, item.Button) then

            RoomSpawnUI_mousePressed = false
            self.closingMenu = true
            self:OnClose()

            Client.SendNetworkMessage( "RoomJoinRoom", { RoomId = item.RoomId } , true )

            return true, true
        end
    end 

    for grpId, panel in pairs(RoomSpawnUI_groupPanels) do

        if RoomSpawnUI_GetIsMouseOver(self, panel.Button) then

            RoomSpawnUI_mousePressed = false

            Client.SendNetworkMessage( "RoomJoinGroup", { GroupId = grpId } , true )

            return true, false
        end
    end 

    return false, false
    
end