local function getAverageAsRegrowthSpell(desc)
	local _, _, from, to, hot, hotSeconds = string.find(desc,
		"Heals a friendly target for (%d+) to (%d+) and another (%d+) over (%d+) sec.")
	if from == nil then
		return nil
	end

	return {
		Average = tonumber((from + to) / 2 + tonumber(hot)),
		HOTSeconds = tonumber(hotSeconds),
	}
end

local function getAverageAsLifebloom(desc)
	local _, _, value, hotSeconds, extraHeal = string.find(desc,
		"Heals the target for (%d+) over (%d+) sec. When Lifebloom completes its duration or is dispelled, the target instantly heals for (%d+)")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value + extraHeal),
		HOTSeconds = tonumber(hotSeconds),
	}
end

local function getAverageAsRejuv(desc)
	local _, _, value, hotSeconds = string.find(desc, "Heals the target for (%d+) over (%d+) sec.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value),
		HOTSeconds = tonumber(hotSeconds),
	}
end

local function getAverageAsTranquility(desc)
	local _, _, value, secInterval, forSeconds = string.find(desc,
		"Regenerates all nearby group members for (%d+) every (%d+) seconds for (%d+) sec.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value) * (tonumber(forSeconds) / tonumber(secInterval)),
		ChanneledForSeconds = tonumber(forSeconds),
	}
end

local function getAverageAsRenew(desc)
	local _, _, value, seconds = string.find(desc, "of (%d+) damage over (%d+) sec")
	if value == nil or not (string.match(desc, "Heal") or string.match(desc, "heal")) then
		return nil
	end
	return {
		Average = tonumber(value),
		HOTSeconds = tonumber(seconds),
	}
end

local function getAverageAsShieldSpell(desc)
	local _, _, absorbVal = string.find(desc, "absorbing (%d+) damage")
	if absorbVal == nil then
		return nil
	end
	return {
		Average = absorbVal,
	}
end

local function getAverageAsHealSpell(desc)
	if not string.match(desc, "heal")
		and not string.match(desc, "Heal") then
		return nil
	end

	local _, _, from, to = string.find(desc, "(%d+) to (%d+)")
	if from == nil then
		return nil
	end
	local average = (tonumber(from) + tonumber(to)) / 2
	return {
		Average = average
	}
end

local function getAverageAsPoM(desc)
	local _, _, value = string.find(desc, "a spell on the target that heals them for (%d+) the next time")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value),
	}
end

local function getAverageAsPenance(desc)
	local _, _, value, secInterval, forSeconds = string.find(desc,
		"or (%d+) healing to an ally, instantly and every (%d+) sec for (%d+) sec.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value) * (1 + tonumber(secInterval) * tonumber(forSeconds)),
		ChanneledForSeconds = tonumber(forSeconds),
	}
end

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

local parseFuncs = {
	getAverageAsRegrowthSpell,
	getAverageAsRejuv,
	getAverageAsLifebloom,
	getAverageAsTranquility,
	getAverageAsRenew,
	getAverageAsShieldSpell,
	getAverageAsHealSpell,
	getAverageAsPoM,
	getAverageAsPenance,
}

local function parseSpell(spellID, playerMaxMana)
	local desc = GetSpellDescription(spellID)
	local avg
	for i = 1, #parseFuncs, 1 do
		avg = parseFuncs[i](desc)
		if avg ~= nil then
			break
		end
	end
	if avg == nil then
		-- current spellID is not a healing/shield spell
		return {
			IsHealSpell = false,
		}
	end

	local _, _, icon, castingTimeMS, _, _, _ = GetSpellInfo(spellID)
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

	local valueHealed = tonumber(avg.Average)

	local IsGroupHeal = string.match(desc, "party members") or string.match(desc, "party or raid member") or
		string.match(desc, "group members")
	if IsGroupHeal then
		-- lets be optimistic
		valueHealed = valueHealed * 5
	end

	local efficiency = 0
	if cost > 0 then
		efficiency = valueHealed / cost
	end

	local cooldownMS, globalCooldownMS = GetSpellBaseCooldown(spellID)
	local cooldown = cooldownMS / 1000
	local globalCooldown = globalCooldownMS / 1000

	local healPerSecond;
	if valueHealed ~= nil and valueHealed > 0 then
		healPerSecond = calcHPS(
			valueHealed, {
				avg.HOTSeconds,
				avg.ChanneledForSeconds,
				castTime,
				cooldown,
				globalCooldown,
			})
	end

	return {
		IsHealSpell = true,
		Average = valueHealed or 0,
		HotSeconds = avg.HOTSeconds or 0,
		ChanneledForSeconds = avg.ChanneledForSeconds or 0,
		IsGroupHeal = IsGroupHeal and "Yes" or "No",
		CastingTime = castTime or 0,
		Cost = cost or 0,
		Icon = icon,
		Efficiency = efficiency or 0,
		Cooldown = cooldown,
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
