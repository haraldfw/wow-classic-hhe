local function getAverageAsHOTSpell(desc)
	local _, _, value, seconds = string.find(desc, "of (%d+) damage over (%d+) sec")
	if value == nil or not (string.match(desc, "Heal") or string.match(desc, "heal")) then
		return nil
	end
	return {
		Average = value,
		HOTSeconds = seconds,
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
		Average = value,
	}
end

local function toTruncNumber(val)
	return tonumber(string.format("%.2f", val))
end

local parseFuncs = {
	getAverageAsHOTSpell,
	getAverageAsShieldSpell,
	getAverageAsHealSpell,
	getAverageAsPoM,
}

local function parseSpell(spellID, playerMaxMana)
	local desc = GetSpellDescription(spellID)
	local avg
	for _, parseFunc in ipairs(parseFuncs) do
		avg = parseFunc(desc)
		if not (avg == nil) then
			break
		end
	end
	if avg == nil then
		-- current spellID is not a healing/shield spell
		return {
			IsHealSpell = false,
		}
	end

	local _, _, icon, castingTime, _, _, _ = GetSpellInfo(spellID)
	local costObj = GetSpellPowerCost(spellID)[1]
	local cost
	if costObj == nil then
		cost = 0
	else
		if costObj.costPercent > 0 then
			cost = (costObj.costPercent / 100) * playerMaxMana
		elseif costObj.costPerSec > 0 then
			cost = costObj.costPerSec * castingTime
		else
			cost = costObj.cost
		end

		if cost > costObj.cost then
			cost = costObj.cost
		end
	end

	local valueHealed = avg.Average

	local IsGroupHeal = string.match(desc, "party members") or string.match(desc, "party or raid member")
	if IsGroupHeal then
		-- lets be optimistic
		valueHealed = valueHealed * 5
	end

	local efficiency = 0
	if cost > 0 then
		efficiency = valueHealed / cost
	end
	return {
		IsHealSpell = true,
		SpellID = spellID,
		Average = valueHealed and toTruncNumber(valueHealed) or 0,
		HotSeconds = avg.HOTSeconds and toTruncNumber(avg.HOTSeconds) or 0,
		IsGroupHeal = IsGroupHeal and "Yes" or "No",
		CastingTime = castingTime and toTruncNumber(castingTime) or 0,
		Cost = cost and toTruncNumber(cost) or 0,
		Icon = icon,
		Efficiency = efficiency and toTruncNumber(efficiency) or 0,
	}
end

function ParseSpellBook()
	local playerMaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
	local spells = {}
	local spellIndex = 1
	for i = 1, GetNumSpellTabs() do
		local offset, numSlots = select(3, GetSpellTabInfo(i))
		for j = offset + 1, offset + numSlots do
			local name, rank, spellID = GetSpellBookItemName(j, "BOOKTYPE_SPELL")
			local healInfo = parseSpell(spellID, playerMaxMana)
			if healInfo.IsHealSpell then
				healInfo.Name = name
				if not (rank == nil) then
					healInfo.Name = healInfo.Name .. " " .. rank
				end
				spells[spellIndex] = healInfo
				spellIndex = spellIndex + 1
			end
		end
	end

	return spells
end
