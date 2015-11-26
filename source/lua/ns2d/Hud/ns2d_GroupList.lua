
Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/Globals.lua")

class 'GroupList' (MenuElement)

local function GetBoundaries(self)

    local minY = -self:GetParent():GetContentPosition().y
    local maxY = minY + self:GetParent().contentStencil:GetSize().y
    
    return minY, maxY
    
end

-- Called after the table has changed (style or data).
local function RenderGroupList(self)

end

function GroupList:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    self:SetWidth(200)
    self:SetBackgroundColor(kNoColor)
    
end

function GroupList:Uninitialize()

    MenuElement.Uninitialize(self)
    
    self.tableData = { }
    self.serverEntries = { }
    
end

function GroupList:RenderNow()
    RenderGroupList(self)
end