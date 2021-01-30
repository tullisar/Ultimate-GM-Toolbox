local statusProperties = {
    "Name",
    "Level",
    "Using",
    "StatusType",
    "Icon",
    "DisplayName",
    "DisplayNameRef",
    "Description",
    "DescriptionRef",
    "DescriptionParams",
    "OverrideDefaultDescription",
    "FormatColor",
    "SavingThrow",
    "IsChanneled",
    "Instant",
    "StatusEffect",
    "StatusEffectOverrideForItems",
    "StatusEffectOnTurn",
    "MaterialType",
    "Material",
    "MaterialApplyBody",
    "MaterialApplyArmor",
    "MaterialApplyWeapon",
    "MaterialApplyNormalMap",
    "MaterialFadeAmount",
    "MaterialOverlayOffset",
    "MaterialParameters",
    "HealingEvent",
    "HealStat",
    "HealType",
    "HealValue",
    "StatsId",
    "IsInvulnerable",
    "IsDisarmed",
    "StackId",
    "StackPriority",
    "AuraRadius",
    "AuraSelf",
    "AuraAllies",
    "AuraEnemies",
    "AuraNeutrals",
    "AuraItems",
    "AuraFX",
    "ImmuneFlag",
    "CleanseStatuses",
    "MaxCleanseCount",
    "ApplyAfterCleanse",
    "SoundStart",
    "SoundLoop",
    "SoundStop",
    "DamageEvent",
    "DamageStats",
    "DeathType",
    "DamageCharacters",
    "DamageItems",
    "DamageTorches",
    "FreezeTime",
    "SurfaceChange",
    "PermanentOnTorch",
    "AbsorbSurfaceType",
    "AbsorbSurfaceRange",
    "Skills",
    "BonusFromAbility",
    "Items",
    "OnlyWhileMoving",
    "DescriptionCaster",
    "DescriptionTarget",
    "WinBoost",
    "LoseBoost",
    "WeaponOverride",
    "ApplyEffect",
    "ForGameMaster",
    "ResetCooldowns",
    "ResetOncePerCombat",
    "PolymorphResult",
    "DisableInteractions",
    "LoseControl",
    "AiCalculationSkillOverride",
    "HealEffectId",
    "ScaleWithVitality",
    "VampirismType",
    "BeamEffect",
    "HealMultiplier",
    "InitiateCombat",
    "Projectile",
    "Radius",
    "Charges",
    "MaxCharges",
    "DefendTargetPosition",
    "TargetConditions",
    "Toggle",
    "LeaveAction",
    "DieAction",
    "PlayerSameParty",
    "PlayerHasTag",
    "PeaceOnly",
    "Necromantic",
    "RetainSkills",
    "BringIntoCombat",
    "ApplyStatusOnTick",
    "IsResistingDeath",
    "TargetEffect",
    "DamagePercentage",
    "ForceOverhead",
    "TickSFX",
    "ForceStackOverwrite",
    "FreezeCooldowns",
}

local potionProperties = {
    "Name",
    "Level",
    "Using",
    "ModifierType",
    "VitalityBoost",
    "Strength",
    "Finesse",
    "Intelligence",
    "Constitution",
    "Memory",
    "Wits",
    "SingleHanded",
    "TwoHanded",
    "Ranged",
    "DualWielding",
    "RogueLore",
    "WarriorLore",
    "RangerLore",
    "FireSpecialist",
    "WaterSpecialist",
    "AirSpecialist",
    "EarthSpecialist",
    "Sourcery",
    "Necromancy",
    "Polymorph",
    "Summoning",
    "PainReflection",
    "Perseverance",
    "Leadership",
    "Telekinesis",
    "Sneaking",
    "Thievery",
    "Loremaster",
    "Repair",
    "Barter",
    "Persuasion",
    "Luck",
    "FireResistance",
    "EarthResistance",
    "WaterResistance",
    "AirResistance",
    "PoisonResistance",
    "PhysicalResistance",
    "PiercingResistance",
    "Sight",
    "Hearing",
    "Initiative",
    "Vitality",
    "VitalityPercentage",
    "MagicPoints",
    "ActionPoints",
    "ChanceToHitBoost",
    "AccuracyBoost",
    "DodgeBoost",
    "DamageBoost",
    "APCostBoost",
    "SPCostBoost",
    "APMaximum",
    "APStart",
    "APRecovery",
    "Movement",
    "MovementSpeedBoost",
    "Gain",
    "Armor",
    "MagicArmor",
    "ArmorBoost",
    "MagicArmorBoost",
    "CriticalChance",
    "Act",
    "Duration",
    "UseAPCost",
    "ComboCategory",
    "StackId",
    "BoostConditions",
    "Flags",
    "StatusMaterial",
    "StatusEffect",
    "StatusIcon",
    "SavingThrow",
    "Weight",
    "Value",
    "InventoryTab",
    "UnknownBeforeConsume",
    "Reflection",
    "Damage",
    "DamageType",
    "AuraRadius",
    "AuraSelf",
    "AuraAllies",
    "AuraEnemies",
    "AuraNeutrals",
    "AuraItems",
    "AuraFX",
    "RootTemplate",
    "ObjectCategory",
    "MinAmount",
    "MaxAmount",
    "Priority",
    "Unique",
    "MinLevel",
    "MaxLevel",
    "BloodSurfaceType",
    "MaxSummons",
    "AddToBottomBar",
    "SummonLifelinkModifier",
    "IgnoredByAI",
    "RangeBoost",
    "BonusWeapon",
    "AiCalculationStatsOverride",
    "RuneEffectWeapon",
    "RuneEffectUpperbody",
    "RuneEffectAmulet",
    "RuneLevel",
    "LifeSteal",
    "IsFood",
    "IsConsumable",
    "ExtraProperties"
}

function CreateStatusFromTemplate(template, name)
    local stat = Ext.GetStat(template, nil)
    local potion = Ext.GetStat(stat.StatsId)
    local properties = {
        name = name,
        original = template,
        status = {},
        potion = {}
    }
    for i,property in pairs(statusProperties) do
        if property ~= "Name" then
            properties.status[property] = stat[property]
        end
    end
    for i,property in pairs(potionProperties) do
        if property ~= "Name" then
            properties.potion[property] = potion[property]
        end
    end
    local formattedName = string.gsub(properties.name, " ", "_")
    properties.status.DisplayName = string.upper(formattedName).."_DisplayName"
    properties.status.Description = string.upper(formattedName).."_Description"
    properties.status.StatsId = "Stats_UGMT_"..formattedName
    properties.status.StackId = "Stack_UGMT_"..formattedName
    properties.status.DisplayNameRef = properties.name
    Ext.SaveFile("StatusSetup.txt", Ext.JsonStringify(properties))
    print("Status setup : see the StatusSetup.txt in your OsirisData folder. Use the !ugm_setupstatusfinish command to create a new status based on the properties in the file.")
end

function FinishStatusFromTemplate(keep)
    if keep == 1 then keep = true else keep = false end
    local properties = Ext.JsonParse(Ext.LoadFile("StatusSetup.txt"))
    local formattedName = string.gsub(properties.name, " ", "_")
    if NRD_StatExists("Stats_UGMT_"..formattedName) then print("Stat already exists."); return end
    Ext.CreateTranslatedString("Stats_UGMT_"..formattedName, properties.name)
    local newPotion = Ext.CreateStat("Stats_UGMT_"..formattedName, "Potion", Ext.GetStat(properties.original).StatsId)
    for field,value in pairs(properties.potion) do
        newPotion[field] = value
    end
    Ext.SyncStat(newPotion.Name, keep)
    local newStatus = Ext.CreateStat("UGMT_"..string.upper(formattedName), "StatusData", Ext.GetStat(properties.original).Name)
    for field,value in pairs(properties.status) do
        newStatus[field] = value
    end
    Ext.SyncStat(newStatus.Name, keep)
    
    if keep then
        PersistentVars.translatedKeys[newPotion.Name] = properties.name
    end
    print("New status "..newStatus.Name.." created.")
end

function ModifyStatusAttributeBonus(attribute, fixedBonus)
    -- Fixed bonus formula : closestHalf(sign(boost) * ceil(bonus/10 * level) * AttributeBoostGrowth)
    -- On level 20, the maximum boost is +15. It should be more than enough for most GMs.
    local properties = Ext.JsonParse(Ext.LoadFile("StatusSetup.txt"))
    local base = ClosestHalf(math.floor(fixedBonus/2)/Ext.ExtraData.AttributeBoostGrowth)
    properties.potion.Level = 20
    properties.potion[attribute] = tostring(base)
    Ext.SaveFile("StatusSetup.txt", Ext.JsonStringify(properties))
end