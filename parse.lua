local function calcHPS(averageHeal, durations)
	local highestDuration = 0;
	for i = 1, #durations, 1 do
		local value = durations[i]
		if value ~= nil and value > highestDuration then
			highestDuration = value
		end
	end

	if highestDuration == 0 then
		return 0
	end
	return averageHeal / highestDuration
end

local parsers = {
	["PRIEST"] = PriestParsers,
	["DRUID"] = DruidParsers,
}

local function parseSpell(spellID, playerMaxMana)
	local desc = GetSpellDescription(spellID)
	local playerClass, _ = UnitClassBase("player")
	local spellParsers = parsers[playerClass]
	if spellParsers == nil then
		print("no parsers found for class: " .. playerClass)
		return {
			IsHealSpell = false,
			Description = desc,
		}
	end


	local spellName, _, icon, castingTimeMS, _, _, _ = GetSpellInfo(spellID)
	local parseFunc = spellParsers[spellName]
	if parseFunc == nil then
		return {
			IsHealSpell = false,
			Description = desc,
		}
	end

	local avg = parseFunc(desc)
	if avg == nil then
		-- current spellID is not a healing/shield spell
		return {
			IsHealSpell = false,
			Description = desc,
		}
	end

	local castTime = castingTimeMS / 1000
	local costObj = GetSpellPowerCost(spellID)[1]
	local cost
	if costObj == nil then
		cost = 0
	else
		if costObj.costPercent > 0 then
			cost = (costObj.costPercent / 100) * playerMaxMana
		elseif costObj.costPerSec > 0 then
			cost = costObj.costPerSec * castTime
		else
			cost = costObj.cost
		end

		-- "costObj.cost" is the max cost of the spell
		if cost > costObj.cost then
			cost = costObj.cost
		end
	end


	if avg.OptimisticNumberOfTargets > 1 then
		-- TODO: let user configure which scale to use
		avg.Average = avg.Average * avg.OptimisticNumberOfTargets
	end

	local efficiency = 0
	if cost > 0 then
		efficiency = avg.Average / cost
	end

	local _, globalCooldownMS = GetSpellBaseCooldown(spellID)
	local globalCooldown = globalCooldownMS / 1000

	local healPerSecond;
	if avg.Average > 0 then
		healPerSecond = calcHPS(
			avg.Average, {
				avg.HOTSeconds,
				avg.ChanneledForSeconds,
				castTime,
				globalCooldown,
			})
	end

	return {
		IsHealSpell = true,
		Description = desc,
		Average = avg.Average or 0,
		HotSeconds = avg.HOTSeconds or 0,
		ChanneledForSeconds = avg.ChanneledForSeconds or 0,
		IsGroupHeal = avg.OptimisticNumberOfTargets > 1 and "Yes" or "No",
		CastingTime = castTime or 0,
		Cost = cost or 0,
		Icon = icon,
		Efficiency = efficiency or 0,
		GlobalCooldown = globalCooldown,
		HealPerSecond = healPerSecond or 0,
	}
end

function ParseSpellBook()
	local playerClass = UnitClassBase("player")
	local playerMaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
	local spells = {}
	local ignoredSpells = {}
	for i = 1, GetNumSpellTabs() do
		local offset, numSlots = select(3, GetSpellTabInfo(i))
		for j = offset + 1, offset + numSlots do
			local name, rank, spellID = GetSpellBookItemName(j, BOOKTYPE_SPELL)
			local spellInfo = parseSpell(spellID, playerMaxMana)
			spellInfo.SpellID = spellID
			spellInfo.Name = name
			spellInfo.NameWithoutRank = name
			if rank ~= nil then
				spellInfo.Name = spellInfo.Name .. " " .. rank
			end
			if spellInfo.IsHealSpell then
				table.insert(spells, spellInfo)
			else
				local _, _, icon, _, _, _, _ = GetSpellInfo(spellID)
				spellInfo.Icon = icon
				table.insert(ignoredSpells, spellInfo)
			end
		end
	end

	return spells, ignoredSpells
end
