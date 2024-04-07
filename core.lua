SLASH_HHE1 = "/hhe"
SLASH_HHE2 = "/heiraldshealefficiencies"
SLASH_HHE3 = "/heirald"

SlashCmdList.HHE = HHEHandleCommand

for i = 1, NUM_CHAT_WINDOWS do
	_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
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
