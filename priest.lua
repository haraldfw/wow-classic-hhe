-- Circle of Healing: Heals all of target player's party members within 40 yards of target player for 432 to 479.
local function parseCircleOfHealing(desc)
	local _, _, fromVal, toVal = string.find(desc,
		"Heals all of target player's party members within 40 yards of target player for (%d+) to (%d+).")
	if fromVal == nil then
		return nil
	end
	return {
		Average = (tonumber(fromVal) + tonumber(toVal)) / 2,
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 2,
		OptimisticNumberOfTargets = 5,
	}
end

-- Desperate Prayer: Instantly heals the caster for 148 to 185.
local function parseDesperatePrayer(desc)
	local _, _, fromVal, toVal = string.find(desc, "Instantly heals the caster for (%d+) to (%d+).")
	if fromVal == nil then
		return nil
	end
	return {
		Average = (tonumber(fromVal) + tonumber(toVal)) / 2,
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Flash Heal: Heals a friendly target for 202 to 247.
local function parseFlashHeal(desc)
	local _, _, fromVal, toVal = string.find(desc, "Heals a friendly target for (%d+) to (%d+).")
	if fromVal == nil then
		return nil
	end
	return {
		Average = (tonumber(fromVal) + tonumber(toVal)) / 2,
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Greater Heal: A slow casting spell that heals a single target for 899 to 1013.
local function parseGreaterHeal(desc)
	local _, _, fromVal, toVal = string.find(desc, "A slow casting spell that heals a single target for (%d+) to (%d+)")
	if fromVal == nil then
		return nil
	end
	return {
		Average = (tonumber(fromVal) + tonumber(toVal)) / 2,
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Heal: Heal your target for 307 to 353.
local function parseHeal(desc)
	local _, _, fromVal, toVal = string.find(desc, "Heal your target for (%d+) to (%d+).")
	if fromVal == nil then
		return nil
	end
	return {
		Average = (tonumber(fromVal) + tonumber(toVal)) / 2,
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Lesser Heal: Heal your target for 47 to 58.
local function parseLesserHeal(desc)
	local _, _, fromVal, toVal = string.find(desc, "Heal your target for (%d+) to (%d+).")
	if fromVal == nil then
		return nil
	end
	return {
		Average = (tonumber(fromVal) + tonumber(toVal)) / 2,
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Penance: Launches a volley of holy light at the target, causing 125 Holy damage to an enemy, or 283 healing to an ally, instantly and every 1 sec for 2 sec.
local function parsePenance(desc)
	local _, _, value, secInterval, forSeconds = string.find(desc,
		"Launches a volley of holy light at the target, causing %d+ Holy damage to an enemy, or (%d+) healing to an ally, instantly and every (%d+) sec for (%d+) sec.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value) * (1 + tonumber(forSeconds) / tonumber(secInterval)),
		HOTSeconds = 0,
		ChanneledForSeconds = tonumber(forSeconds),
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Power Word: Shield: Draws on the soul of the party member to shield them, absorbing 55 damage.  Lasts 30 sec.  While the shield holds, spellcasting will not be interrupted by damage.  Once shielded, the target cannot be shielded again for 15 sec.
local function parsePowerWordShield(desc)
	local _, _, absorbed = string.find(desc,
		"Draws on the soul of the party member to shield them, absorbing (%d+) damage.  Lasts 30 sec.  While the shield holds, spellcasting will not be interrupted by damage.  Once shielded, the target cannot be shielded again for 15 sec.")
	if absorbed == nil then
		return nil
	end
	return {
		Average = tonumber(absorbed),
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end


-- Prayer of Healing: A powerful prayer heals party members within 30 yards for 312 to 333.
local function parsePrayerOfHealing(desc)
	local _, _, fromValue, toValue = string.find(desc,
		"A powerful prayer heals party members within 30 yards for (%d+) to (%d+).")
	if fromValue == nil then
		return nil
	end
	return {
		Average = (tonumber(fromValue) + tonumber(toValue)) / 2,
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 2,
		OptimisticNumberOfTargets = 5,
	}
end

-- Prayer of Mending: Places a spell on the target that heals them for 246 the next time they take damage or receive healing.  When the heal occurs, Prayer of Mending jumps to a party or raid member within 20 yards.  Jumps up to 5 times and lasts 30 sec after each jump.  This spell can only be placed on one target at a time.
local function parsePrayerOfMending(desc)
	local _, _, value, maxJumps = string.find(desc,
		"Places a spell on the target that heals them for (%d+) the next time they take damage or receive healing.  When the heal occurs, Prayer of Mending jumps to a party or raid member within 20 yards.  Jumps up to (%d+) times and lasts 30 sec after each jump.  This spell can only be placed on one target at a time.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value),
		HOTSeconds = 0,
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		-- POM is easy to maximize
		BalancedNumberOfTargets = tonumber(maxJumps),
		-- wording is ambiguous if max number of heals is amount of jumps or 1+amount of jumps. TODO: test if it heals 5 or 6 times
		OptimisticNumberOfTargets = tonumber(maxJumps),
	}
end

-- Renew: Heals the target of 54 damage over 15 sec.
local function parseRenew(desc)
	local _, _, value, seconds = string.find(desc, "of (%d+) damage over (%d+) sec")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value),
		HOTSeconds = tonumber(seconds),
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

PriestParsers = {
	["Circle of Healing"] = parseCircleOfHealing,
	["Desperate Prayer"] = parseDesperatePrayer,
	["Flash Heal"] = parseFlashHeal,
	["Greater Heal"] = parseGreaterHeal,
	["Heal"] = parseHeal,
	["Lesser Heal"] = parseLesserHeal,
	["Penance"] = parsePenance,
	["Power Word: Shield"] = parsePowerWordShield,
	["Prayer of Healing"] = parsePrayerOfHealing,
	["Prayer of Mending"] = parsePrayerOfMending,
	["Renew"] = parseRenew,
}
