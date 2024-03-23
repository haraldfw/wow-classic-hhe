local function main()
    local spells = ParseSpellBook()
    for _, v in pairs(spells) do
        print(v.Name .. " " .. v.Cost)
    end

    print("HHE Loaded!")
end

SLASH_HHE1 = "/hhe"
SLASH_HHE2 = "/heiraldshealefficiencies"
SLASH_HHE3 = "/heirald"

SlashCmdList.HHE = ShowHHEFrame

for i = 1, NUM_CHAT_WINDOWS do
    _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
end

main()
