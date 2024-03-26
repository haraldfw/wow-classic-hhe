local spellDatas = {}
local ignoredSpellDatas = {}

local TEXT_CELL_PADDING = 3
local CELL_HEIGHT = 20

local clickToSortAppendix = "\n\nClick to sort"
local cellInfos = {
	{
		fieldName = "Icon",
		width = CELL_HEIGHT,
		isIcon = true,
		justifyH = "LEFT",
		description = "Hover the spell's icon to show info on the spell." .. clickToSortAppendix,
	},
	{
		fieldName = "Name",
		width = 175,
		justifyH = "LEFT",
		description = "Name and rank of the spell." .. clickToSortAppendix,
	},
	{
		fieldName = "Cost",
		width = 50,
		justifyH = "RIGHT",
		description = "The spell's cost in mana." .. clickToSortAppendix,
	},
	{
		fieldName = "Average",
		width = 70,
		formatString = "%.1f",
		justifyH = "RIGHT",
		description =
			"The average heal value of the spell. For spells with a roll-range the average is used, for HoTs the total healed is used. For group spells a scalar for the heal value is used." ..
			clickToSortAppendix,
	},
	{
		fieldName = "Efficiency",
		width = 70,
		formatString = "%.2f",
		justifyH = "RIGHT",
		description = "How much the spell heals divided by how much mana it cost. Heal per Mana." ..
			clickToSortAppendix,
	},
	{
		fieldName = "HealPerSecond",
		width = 70,
		formatString = "%.2f",
		justifyH = "RIGHT",
		description =
			"How much the spell can heal per second, the longest duration-aspect of the spell is used. So the spell's healpotential divided by whichever is the longest of global cooldown, casting time, or channeling time." ..
			clickToSortAppendix,
	},
	{
		fieldName = "IsGroupHeal",
		width = 50,
		justifyH = "CENTER",
		description = "Whether or not the spell heals a group or not." .. clickToSortAppendix,
	},
}

local cellInfoMap = {}
HHETABLE_ROW_WIDTH = 0
for _, v in pairs(cellInfos) do
	cellInfoMap[v.fieldName] = v
	HHETABLE_ROW_WIDTH = HHETABLE_ROW_WIDTH + v.width
end
HHE_IGNORED_TABLE_ROW_WIDTH = cellInfoMap.Icon.width + cellInfoMap.Name.width

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


local function newDescriptionBoxWriter(spellName, desc, toChain)
	return function(...)
		if HHEDevEditBox == nil then
			HHEDevEditBox = CreateFrame("EditBox", "HHEDevEditBox", HHEFrame)
			HHEDevEditBox:SetFontObject(GameFontNormal)
			HHEDevEditBox:SetSize(190, 24)
			HHEDevEditBox:SetJustifyH("CENTER")
			HHEDevEditBox:SetPoint("BOTTOMRIGHT", HHEFrame, "TOPRIGHT")
			HHEDevEditBox:SetMultiLine(false)
			HHEDevEditBox:SetScript("OnEscapePressed", function(self)
				self:ClearFocus()
				self:Hide()
			end)
		elseif not HHEDevEditBox:IsShown() then
			HHEDevEditBox:Show()
		end
		HHEDevEditBox:SetText(spellName .. ": " .. desc)
		if toChain ~= nil then
			toChain(...)
		end
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
			if DEV_MODE then
				cell:SetScript("OnEnter",
					newDescriptionBoxWriter(data.NameWithoutRank, data.Description, newOnEnter(data.SpellID)))
			end
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
			if DEV_MODE then
				cell:SetScript("OnEnter",
					newDescriptionBoxWriter(data.NameWithoutRank, data.Description, newOnEnter(data.SpellID)))
			end
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
		if prevCell ~= nil then
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

local function createIgnoredSpellRow(parent, data, index)
	local row = CreateFrame("Button", "HHEIgnoredSpellsScrollFrameRow" .. tostring(index), parent)
	row:SetSize(HHE_IGNORED_TABLE_ROW_WIDTH, CELL_HEIGHT)
	row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * CELL_HEIGHT)
	row.columns = {}

	local ci = cellInfoMap.Icon
	local iconCell = row:CreateTexture(nil, "OVERLAY")
	iconCell:SetSize(ci.width, CELL_HEIGHT)
	iconCell:SetTexture(data.Icon)
	iconCell:SetScript("OnEnter", newOnEnter(data.SpellID))
	iconCell:SetScript("OnLeave", newOnLeave(data.SpellID))
	iconCell:SetPoint("TOPLEFT", row, "TOPLEFT")
	if DEV_MODE then
		iconCell:SetScript("OnEnter",
			newDescriptionBoxWriter(data.NameWithoutRank, data.Description, newOnEnter(data.SpellID)))
	end
	row.columns[1] = iconCell
	iconCell:Show()

	ci = cellInfoMap.Name
	local nameCell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	nameCell:ClearAllPoints()
	nameCell:SetSize(ci.width - TEXT_CELL_PADDING, CELL_HEIGHT)
	nameCell:SetText(data.Name)
	nameCell:SetJustifyH(ci.justifyH)
	nameCell:SetPoint("TOPLEFT", iconCell, "TOPRIGHT", TEXT_CELL_PADDING, 0)
	row.columns[2] = nameCell
	nameCell:Show()

	return row
end

local function overwriteIgnoredSpellRow(row, data)
	local iconCell = row.columns[1]
	iconCell:SetTexture(data.Icon)
	iconCell:SetScript("OnEnter", newOnEnter(data.SpellID))
	iconCell:SetScript("OnLeave", newOnLeave(data.SpellID))
	if DEV_MODE then
		iconCell:SetScript("OnEnter",
			newDescriptionBoxWriter(data.NameWithoutRank, data.Description, newOnEnter(data.SpellID)))
	end

	local nameCell = row.columns[2]
	nameCell:SetText(data.Name)
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
	if self.sortType ~= HHESortKey then
		_G["HHEFrameColumnHeader" .. self.sortType .. "Arrow"]:Hide()
	end
end

function HHEColumnHeader_OnEnter(self)
	local desc = cellInfoMap[self.sortType].description
	if desc == nil then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:SetText(desc, nil, nil, nil, nil, true)
	GameTooltip:Show()
end

function HHEColumnHeader_OnLeave(self)
	GameTooltip:Hide()
end

local function updateRenderedIgnoredSpells()
	table.sort(ignoredSpellDatas, NewSortFuncByField("Name", true))

	local child = HHEIgnoredSpellsInfoScrollFrameScrollChildFrame
	child:SetSize(HHETABLE_ROW_WIDTH, CELL_HEIGHT * #ignoredSpellDatas)
	HHEIgnoredSpellsInfoHeader:SetText("Ignored spells (" .. tostring(#ignoredSpellDatas) .. ")")

	if child.rows == nil then
		child.rows = {}
	end
	local max = #child.rows
	if #ignoredSpellDatas > max then
		max = #ignoredSpellDatas
	end
	for i = 1, max, 1 do
		local spell = ignoredSpellDatas[i]
		if spell == nil then
			child.rows[i]:Hide()
		else
			if child.rows[i] == nil then
				child.rows[i] = createIgnoredSpellRow(child, spell, i)
			else
				overwriteIgnoredSpellRow(child.rows[i], spell)
			end
			child.rows[i]:Show()
		end
	end

	child:Show()
end

local function updateData()
	spellDatas, ignoredSpellDatas = ParseSpellBook()
	sortData()
	updateRenderedData()
	if HHEIgnoredSpellsInfoFrame:IsShown() then
		updateRenderedIgnoredSpells()
	end
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

function ShowHHEIgnoredSpellsFrame()
	updateRenderedIgnoredSpells()
	HHEIgnoredSpellsInfoFrame:Show()
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
		if DEV_MODE then
			ShowHHEFrame()
		end
	elseif event == "SPELLS_CHANGED" then
		updateData()
	end
end
