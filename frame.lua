local spellDatas = {}

local TEXT_CELL_PADDING = 3
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
		width = 175,
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
		formatString = "%.1f",
		justifyH = "RIGHT",
	},
	{
		fieldName = "Efficiency",
		width = 70,
		formatString = "%.2f",
		justifyH = "RIGHT",
	},
	{
		fieldName = "HealPerSecond",
		width = 70,
		formatString = "%.2f",
		justifyH = "RIGHT",
	},
	{
		fieldName = "IsGroupHeal",
		width = 50,
		justifyH = "CENTER",
	},
}

local cellInfoMap = {}
HHETABLE_ROW_WIDTH = 0
for _, v in pairs(cellInfos) do
	cellInfoMap[v.fieldName] = v
	HHETABLE_ROW_WIDTH = HHETABLE_ROW_WIDTH + v.width
end

local function newOnEnter(spellID)
	return function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(spellID)
		GameTooltip:Show()
	end
end

local function newOnLeave(spellID)
	return function()
		GameTooltip:Hide()
	end
end

local function overwriteRow(row, data)
	local i = 0
	for _, cellInfo in pairs(cellInfos) do
		i = i + 1
		local cell = row.columns[i]
		if cellInfo.fieldName == "Icon" then
			cell:SetTexture(data[cellInfo.fieldName])
			cell:SetScript("OnEnter", newOnEnter(data.SpellID))
			cell:SetScript("OnLeave", newOnLeave(data.SpellID))
		else
			local fieldText = data[cellInfo.fieldName]
			if cellInfo.formatString ~= nil then
				fieldText = string.format(cellInfo.formatString, fieldText)
			end
			cell:SetText(fieldText)
		end
	end
end

local function createRow(parent, data, index)
	local row = CreateFrame("Button", "HHEScrollFrameRow" .. tostring(index), parent)
	row:SetSize(HHETABLE_ROW_WIDTH, CELL_HEIGHT)
	row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * CELL_HEIGHT)
	row.columns = {}
	local prevCell = nil

	for i, cellInfo in pairs(cellInfos) do
		local cell;
		if cellInfo.fieldName == "Icon" then
			cell = row:CreateTexture(nil, "OVERLAY")
			cell:SetSize(cellInfo.width, CELL_HEIGHT)
			cell:SetTexture(data[cellInfo.fieldName])
			cell:SetScript("OnEnter", newOnEnter(data.SpellID))
			cell:SetScript("OnLeave", newOnLeave(data.SpellID))
		else
			cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			cell:ClearAllPoints()
			cell:SetSize(cellInfo.width - TEXT_CELL_PADDING, CELL_HEIGHT)
			local fieldText = data[cellInfo.fieldName]
			if cellInfo.formatString ~= nil then
				fieldText = string.format(cellInfo.formatString, fieldText)
			end
			cell:SetText(fieldText)
			cell:SetJustifyH(cellInfo.justifyH)
		end
		if not (prevCell == nil) then
			cell:SetPoint("TOPLEFT", prevCell, "TOPRIGHT", TEXT_CELL_PADDING, 0)
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
	child:SetSize(HHETABLE_ROW_WIDTH, CELL_HEIGHT * #spellDatas)

	if child.rows == nil then
		child.rows = {}
	end
	local max = #child.rows
	if #spellDatas > max then
		max = #spellDatas
	end
	for i = 1, max, 1 do
		local spell = spellDatas[i]
		if spell == nil then
			child.rows[i]:Hide()
		else
			if child.rows[i] == nil then
				child.rows[i] = createRow(child, spell, i)
			else
				overwriteRow(child.rows[i], spell)
			end
			child.rows[i]:Show()
		end
	end

	child:Show()
end


local function sortData()
	table.sort(spellDatas, NewSortFuncByField(HHESortKey, HHESortAsc))
end

function HandleSortClicked(columnKey)
	local lastSortKey = HHESortKey
	local hideLastKey = true
	if HHESortKey == columnKey then
		hideLastKey = false
		HHESortAsc = not HHESortAsc
	else
		HHESortKey = columnKey
		HHESortAsc = true
	end

	local arrowFrame = _G["HHEFrameColumnHeader" .. columnKey .. "Arrow"]
	arrowFrame:SetRotation((not HHESortAsc) and math.pi or 0)
	arrowFrame:Show()
	if hideLastKey then
		_G["HHEFrameColumnHeader" .. lastSortKey .. "Arrow"]:Hide()
	end

	sortData()
	updateRenderedData()
end

function HHEColumnHeader_OnShow(self)
	if not (self.sortType == HHESortKey) then
		_G["HHEFrameColumnHeader" .. self.sortType .. "Arrow"]:Hide()
	end
end

local function updateData()
	spellDatas = ParseSpellBook()
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

local eventsToRegister = {
	"SPELLS_CHANGED"
}

function HHEFrame_OnShow(self)
	for _, v in pairs(eventsToRegister) do
		self:RegisterEvent(v);
	end
end

function HHEFrame_OnHide(self)
	for _, v in pairs(eventsToRegister) do
		self:UnregisterEvent(v);
	end
end

function HHEFrame_OnEvent(self, event, ...)
	print("event" .. tostring(event))
	Dump(...)
	if event == "ADDON_LOADED" then
		local addonName = select(1, ...)
		if addonName == "HeiraldsHealEfficiencies" then
			if HHESortKey == nil then
				HHESortKey = "Name"
			end
			if HHESortAsc == nil then
				HHESortAsc = true
			end

			local arrowFrame = _G["HHEFrameColumnHeader" .. HHESortKey .. "Arrow"]
			arrowFrame:SetRotation((not HHESortAsc) and math.pi or 0)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		ShowHHEFrame()
	elseif event == "SPELLS_CHANGED" then
		updateData()
	end
end
