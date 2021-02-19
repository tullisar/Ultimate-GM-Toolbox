rarity = "Common"
treasureRef = {
    GM_Equip_Generate_Armor_Mage = "ST_MageArmor",
    GM_Equip_Generate_Armor_Light = "ST_LightArmor",
    GM_Equip_Generate_Armor_Heavy = "ST_HeavyArmor",
    GM_Equip_Generate_Armor_Mix = "ST_RandomArmor",
    GM_Equip_Generate_Armor_Jewels = "ST_Jewels",
    GM_Equip_Generate_Weapon_OH = "ST_OneHanded",
    GM_Equip_Generate_Weapon_Dagger = "ST_Dagger",
    GM_Equip_Generate_Weapon_Wand = "ST_Wand",
    GM_Equip_Generate_Weapon_Staff = "ST_Staff",
    GM_Equip_Generate_Weapon_Shield = "ST_Shield",
    GM_Equip_Generate_Weapon_TH = "ST_TwoHanded",
    GM_Equip_Generate_Weapon_Ranged = "ST_Ranged"
}
rarityRef = {
    GM_Equip_Rarity_Common = "Common",
    GM_Equip_Rarity_Uncommon = "Uncommon",
    GM_Equip_Rarity_Rare = "Rare",
    GM_Equip_Rarity_Epic = "Epic"
}

local function GenerateTreasureFromTable(tab)
    local treasureTable = tab..rarity
    for char,x in pairs(selected) do
        local x,y,z = GetPosition(char)
        local pouch = Ext.GetItem(CreateItemTemplateAtPosition("LOOT_Pouch_A_244deb74-a42b-44b3-94b1-a7fe3620b98e", x, y, z))
        local level = CharacterGetLevel(char)
        GenerateTreasure(pouch.MyGuid, treasureTable, level, char)
        local inventory = pouch.GetInventoryItems(pouch)
        for i,item in pairs(inventory) do
            CharacterEquipItem(char, item)
        end
        ItemRemove(pouch.MyGuid)
    end
end

local function GenerateEquipment(item, event)
    local treasure = treasureRef[event]
    if treasure == nil then return end
    GenerateTreasureFromTable(treasure)
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", GenerateEquipment)

local function ChangeQuality(item, event)
    local newRarity = rarityRef[event]
    if newRarity == nil then return end
    rarity = newRarity
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", ChangeQuality)