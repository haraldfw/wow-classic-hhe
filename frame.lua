local sortKey = "Name"
local sortAsc = true
local spellData = {}

local CELL_HEIGHT = 20

local cellInfos = {
    {
        fieldName = "Icon",
        width = CELL_HEIGHT,
        isIcon = true,
        justifyH = "LEFT",
    },
    {
        fieldName = "Name",
        width = 150,
        justifyH = "LEFT",
    },
    {
        fieldName = "Cost",
        width = 50,
        justifyH = "RIGHT",
    },
    {
        fieldName = "Average",
        width = 70,
        justifyH = "RIGHT",
    },
    {
        fieldName = "Efficiency",
        width = 70,
        formatDecimal = true,
        justifyH = "RIGHT",
    },
    {
        fieldName = "IsGroupHeal",
        width = 50,
        justifyH = "LEFT",
    },
}

local cellInfoMap = nil
if cellInfoMap == nil then
    cellInfoMap = {}
    for _, v in pairs(cellInfos) do
        cellInfoMap[v.fieldName] = v
    end
end


local function overwriteRow(row, data)
    local i = 0
    for _, cellInfo in pairs(cellInfos) do
        i = i + 1
        local cell = row.columns[i]
        if cellInfo.fieldName == "Icon" then
            cell:SetTexture(data[cellInfo.fieldName])
        else
            cell:SetText(data[cellInfo.fieldName])
        end
    end
end

local function createRow(parent, data, offsetIndex)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(200, CELL_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -offsetIndex * CELL_HEIGHT)
    row.columns = {}
    local prevCell = nil
    for i, cellInfo in pairs(cellInfos) do
        local cell;
        if cellInfo.fieldName == "Icon" then
            cell = row:CreateTexture(nil, "OVERLAY")
            cell:SetSize(cellInfo.width, CELL_HEIGHT)
            cell:SetTexture(data[cellInfo.fieldName])
        else
            cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            cell:ClearAllPoints()
            cell:SetSize(cellInfo.width, CELL_HEIGHT)
            cell:SetText(data[cellInfo.fieldName])
            cell:SetJustifyH(cellInfo.justifyH)
        end
        if not (prevCell == nil) then
            cell:SetPoint("TOPLEFT", prevCell, "TOPRIGHT")
        else
            cell:SetPoint("TOPLEFT", row, "TOPLEFT")
        end
        row.columns[i] = cell
        prevCell = cell
        cell:Show()
    end
    return row
end

local function updateRenderedData()
    local child = HHEListScrollFrameScrollChildFrame
    child:SetHeight(CELL_HEIGHT * 20)

    if child.rows == nil then
        child.rows = {}
    end
    for i, spell in pairs(spellData) do
        if child.rows[i] == nil then
            child.rows[i] = createRow(child, spell, i - 1)
        else
            overwriteRow(child.rows[i], spell)
        end
        child.rows[i]:Show()
    end

    child:Show()
end


local function sortData()
    table.sort(spellData, NewSortFuncByField(sortKey, sortAsc))
end

function HandleSortClicked(columnKey)
    local lastSortKey = sortKey
    local hideLastKey = true
    if sortKey == columnKey then
        hideLastKey = false
        sortAsc = not sortAsc
    else
        sortKey = columnKey
        sortAsc = true
    end

    local arrowFrame = _G["HHEFrameColumnHeader" .. columnKey .. "Arrow"]
    arrowFrame:SetRotation((not sortAsc) and math.pi or 0)
    arrowFrame:Show()
    if hideLastKey then
        _G["HHEFrameColumnHeader" .. lastSortKey .. "Arrow"]:Hide()
    end

    sortData()
    updateRenderedData()
end

function HHEColumnHeader_OnShow(self)
    if not (self.sortType == sortKey) then
        _G["HHEFrameColumnHeader" .. self.sortType .. "Arrow"]:Hide()
    end
end

local function updateData()
    spellData = ParseSpellBook()
    sortData()
    updateRenderedData()
end

function HHEFrameColumn_SetWidth(self)
    local ci = cellInfoMap[self.sortType]
    if not ci then
        print("ERROR: missing cellInfo for sortType " .. self.sortType)
        return nil
    end
    local name = self:GetName() .. "Middle";
    local middleFrame = _G[name];
    if middleFrame then
        middleFrame:SetWidth(ci.width - 7);
    end
    self:SetWidth(ci.width + 2);
end

function ShowHHEFrame()
    updateData()
    HHEFrame:Show()
end
