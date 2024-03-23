SLASH_HHE1 = "/hhe"
SLASH_HHE2 = "/heiraldshealefficiencies"
SLASH_HHE3 = "/heirald"

SlashCmdList.HHE = ShowHHEFrame

for i = 1, NUM_CHAT_WINDOWS do
	_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
end
