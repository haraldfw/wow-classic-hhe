local function compareStrings(s1, s2, asc)
    if s1 == nil then
        s1 = ""
    end
    if s2 == nil then
        s2 = ""
    end
    s1 = s1:upper()
    s2 = s2:upper()
    if asc then
        return s1 < s2
    else
        return s1 > s2
    end
end

local function tieBreak(k1, k2)
    -- always sort name alphabetically ascending when used as a tiebreak
    return compareStrings(k1["Name"], k2["Name"], true)
end

function NewSortFuncByField(fieldName, asc)
    return function(k1, k2)
        local v1 = k1[fieldName]
        local v2 = k2[fieldName]
        if v1 == v2 then
            return tieBreak(k1, k2)
        end

        -- use Name if field to sort by is nil
        local v1Empty = v1 == nil or v1 == ""
        local v2Empty = v2 == nil or v2 == ""
        if v1Empty and v2Empty then
            return false
        elseif v1Empty then
            return true
        elseif v2Empty then
            return false
        end

        local n1 = tonumber(v1)
        local n2 = tonumber(v1)
        -- if either fails number conversion then compare as strings
        if n1 == nil or n2 == nil then
            return compareStrings(tostring(v1), tostring(v2), asc)
        end

        if asc then
            return v1 > v2
        else
            return v1 < v2
        end
    end
end
