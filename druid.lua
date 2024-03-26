-- Healing Touch: Heals a friendly target for 40 to 55.
local function parseHealingTouch(desc)
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

-- Lifebloom: Heals the target for 61 over 7 sec.  When Lifebloom completes its duration or is dispelled, the target instantly heals for 125 and the Druid regains half the cost of the spell.  This effect can stack up to 3 times on the same target.
local function parseLifebloom(desc)
	local _, _, value, hotSeconds, extraHeal = string.find(desc,
		"Heals the target for (%d+) over (%d+) sec.  When Lifebloom completes its duration or is dispelled, the target instantly heals for (%d+) and the Druid regains half the cost of the spell.  This effect can stack up to 3 times on the same target.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value + extraHeal),
		HOTSeconds = tonumber(hotSeconds),
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Regrowth: Heals a friendly target for 93 to 107 and another 98 over 21 sec.
local function parseRegrowth(desc)
	local _, _, from, to, hot, hotSeconds = string.find(desc,
		"Heals a friendly target for (%d+) to (%d+) and another (%d+) over (%d+) sec.")
	if from == nil then
		return nil
	end

	return {
		Average = tonumber((from + to) / 2 + tonumber(hot)),
		HOTSeconds = tonumber(hotSeconds),
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Rejuvenation: Heals the target for 32 over 12 sec.
local function parseRejuvenation(desc)
	local _, _, value, hotSeconds = string.find(desc, "Heals the target for (%d+) over (%d+) sec.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value),
		HOTSeconds = tonumber(hotSeconds),
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 1,
		OptimisticNumberOfTargets = 1,
	}
end

-- Tranquility: Regenerates all nearby group members for 94 every 2 seconds for 10 sec.  Druid must channel to maintain the spell.
local function parseTranquility(desc)
	local _, _, value, secInterval, forSeconds = string.find(desc,
		"Regenerates all nearby group members for (%d+) every (%d+) seconds for (%d+) sec.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value) * (tonumber(forSeconds) / tonumber(secInterval)),
		HOTSeconds = 0,
		ChanneledForSeconds = tonumber(forSeconds),
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 3,
		OptimisticNumberOfTargets = 5,
	}
end


-- Wild Growth: Heals all of target player's party members within 40 yards of target player for 521 over 7 sec. The amount healed is applied quickly at first, and slows down as Wild Growth reaches its full duration.
local function parseWildGrowth(desc)
	local _, _, value, hotSeconds = string.find(desc,
		"Heals all of target player's party members within 40 yards of target player for (%d+) over (%d+) sec. The amount healed is applied quickly at first, and slows down as Wild Growth reaches its full duration.")
	if value == nil then
		return nil
	end
	return {
		Average = tonumber(value),
		HOTSeconds = tonumber(hotSeconds),
		ChanneledForSeconds = 0,
		ConservativeNumberOfTargets = 1,
		BalancedNumberOfTargets = 3,
		OptimisticNumberOfTargets = 5,
	}
end

DruidParsers = {
	["Healing Touch"] = parseHealingTouch,
	["Lifebloom"] = parseLifebloom,
	["Regrowth"] = parseRegrowth,
	["Rejuvenation"] = parseRejuvenation,
	["Tranquility"] = parseTranquility,
	["Wild Growth"] = parseWildGrowth,
}
