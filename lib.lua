-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
local char_to_hex = function(c)
	return string.format("%%%02X", string.byte(c))
end

-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
function URLEncode(url)
	if url == nil then
		return
	end
	url = url:gsub("\n", "\r\n")
	url = url:gsub("([^%w ])", char_to_hex)
	url = url:gsub(" ", "+")
	return url
end

function DebugDump(...)
	if HHEDebug then
		Dump(...)
	end
end

function Dump(...)
	if ... == nil then
		return
	end
	if type(...) == "table" then
		for k, v in pairs(...) do
			print(tostring(k) .. ": " .. tostring(v))
		end
	else
		print(tostring(...))
	end
end
