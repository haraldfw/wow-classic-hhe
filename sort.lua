local function tieBreak(k1, k2, asc)
    local name1 = k1["Name"]
    local name2 = k2["Name"]
    if name1 == nil then
        name1 = ""
    end
    if name2 == nil then
        name2 = ""
    end
    if asc then
        return name1 < name2
    else
        return name1 > name2
    end
end

function NewSortFuncByField(fieldName, asc)
    return function(k1, k2)
        local v1 = k1[fieldName]
        local v2 = k2[fieldName]
        -- use Name if field to sort by is nil
        if v1 == nil then
            v1 = ""
        end
        if v2 == nil then
            v2 = ""
        end
        if v1 == v2 then
            return tieBreak(k1, k2, asc)
        end
        if asc then
            return v1 < v2
        else
            return v1 > v2
        end
    end
end
