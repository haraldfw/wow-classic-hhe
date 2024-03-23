local sortKey = "Name"
local sortAsc = true
local spellData = {}

local CELL_HEIGHT = 20

local cellInfos = {
    {
        fieldName = "Icon",
        width = 27,
        isIcon = true,
        justifyH = "LEFT",
    },
    {
        fieldName = "Name",
        width = 152,
        justifyH = "LEFT",
    },
    {
        fieldName = "Cost",
        width = 52,
        justifyH = "RIGHT",
    },
    {
        fieldName = "Average",
        width = 72,
        justifyH = "RIGHT",
    },
    {
        fieldName = "Efficiency",
        width = 52,
        formatDecimal = true,
        justifyH = "RIGHT",
    },
    {
        fieldName = "IsGroupHeal",
        width = 52,
        justifyH = "LEFT",
    },
}

local function overwriteRow(row, data)
    for i, cellInfo in pairs(cellInfos) do
        local cell = row.columns[i]
        cell:SetText(data[cellInfo.fieldName])
    end
end

local function createRow(parent, data, offsetIndex)
    -- one row:
    -- Icon | Spell Name + Rank | Amount healed average | Mana cost | Casting Time () | Healed per mana | Healing per second
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(200, CELL_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -offsetIndex * CELL_HEIGHT)
    row.columns = {}
    local prevCell = nil
    for i, cellInfo in pairs(cellInfos) do
        local cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        cell:ClearAllPoints()
        if not (prevCell == nil) then
            cell:SetPoint("TOPLEFT", prevCell, "TOPRIGHT")
        else
            cell:SetPoint("TOPLEFT", row, "TOPLEFT")
        end
        cell:SetSize(cellInfo.width, CELL_HEIGHT)
        cell:SetText(data[cellInfo.fieldName])

        row.columns[i] = cell
        prevCell = cell
        cell:SetJustifyH(cellInfo.justifyH)
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

local function updateData()
    spellData = ParseSpellBook()
    sortData()
    updateRenderedData()
end

function HHEFrameColumn_SetWidth(frame, width)
    frame:SetWidth(width);
    local name = frame:GetName() .. "Middle";
    local middleFrame = _G[name];
    if middleFrame then
        middleFrame:SetWidth(width - 9);
    end
end

function ShowHHEFrame()
    updateData()
    HHEFrame:Show()
end
