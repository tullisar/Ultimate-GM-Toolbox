Ext.Require("Server/Selection.lua")
Ext.Require("Server/Movement.lua")
Ext.Require("Server/Tools.lua")
Ext.Require("Server/Equipment.lua")
Ext.Require("Server/Animations.lua")
Ext.Require("Server/OsiServices.lua")
Ext.Require("Server/UIHotbar.lua")

PersistentVars = {}
selected = {}
target = nil
quickSelection = nil
bypasslock = false

-- Initialization
currentLevel = ""

local function RestoreCharactersScaling()
    for character, scale in pairs(PersistentVars[currentLevel].scale) do
        if ObjectExists(character) == 1 and ObjectIsCharacter(character) == 1 then
            Ext.BroadcastMessage("UGM_SetCharacterScale", Ext.GetCharacter(character).NetID..":"..tostring(scale), nil)
        end
    end
end

local function RestoreCharactersAnimations()
    for character, anims in pairs(PersistentVars[currentLevel].anims) do
        if HasActiveStatus(character, "DEACTIVATED") == 0 then
            StartAnimations(anims)
        end
    end
    for character, anim in pairs(PersistentVars[currentLevel].animLoop) do
        if HasActiveStatus(character, "DEACTIVATED") == 0 then
            StartAnimLoop(anim)
        end
    end
end

local function GetCurrentLevel(map, isEditor)
    currentLevel = map
    if PersistentVars[currentLevel] == nil then
        PersistentVars[currentLevel] = {}
        PersistentVars[currentLevel].patrols = {}
    end
    if PersistentVars[currentLevel].scale == nil then
        PersistentVars[currentLevel].scale = {}
    end
    if PersistentVars[currentLevel].anims == nil then
        PersistentVars[currentLevel].anims = {}
    end
    if PersistentVars[currentLevel].animLoop == nil then
        PersistentVars[currentLevel].animLoop = {}
    end
    RestoreCharactersAnimations()
end

Ext.RegisterOsirisListener("GameStarted", 2, "before", GetCurrentLevel)

local function ClientLoaded(channel, payload)
    Ext.Print(payload)
    if payload == "RestoreScalings" then
        RestoreCharactersScaling()
    end
end

Ext.RegisterNetListener("UGM_ClientLoaded", ClientLoaded)


function LoadVars()
    --Ext.Print(Ext.JsonStringify(PersistentVars))
    if PersistentVars.selectType == nil then
        PersistentVars.selectType = {
            current = "GM_SELECTED",
            alternate = "GM_SELECTED_DISCREET"
        }
    end
    if PersistentVars.targetType == nil then
        PersistentVars.targetType = {
            current = "GM_TARGETED",
            alternate = "GM_TARGETED_DISCREET"
        }
    end
    if PersistentVars.options == nil then
        PersistentVars.options = {
            activatedOnly = "off",
            deactivatedOnly = "off",
        }
    end
    if PersistentVars.lock == nil then
        PersistentVars.lock = false
    end

    if PersistentVars.talkType == nil then
        PersistentVars.talkType = "normal"
    end
    if PersistentVars.translatedKeys ~= nil then
        for key,text in PersistentVars.translatedKeys do
            Ext.CreateTranslatedString(key, text)
        end
    end
end

Ext.RegisterListener("SessionLoaded", LoadVars)

-- Story invulnerability to avoid deactivation removing statuses
local function DeactivationInvulnerability(char, status, causee)
    if status == "DEACTIVATED" then
        Osi.SetInvulnerable_UseProcSetInvulnerable(char, 1)
    end
end

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "before", DeactivationInvulnerability)

local function Reactivation(char, status, causee)
    if status == "DEACTIVATED" then
        Osi.SetInvulnerable_UseProcSetInvulnerable(char, 0)
    end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", Reactivation)


-- Console commands
local UGM_consoleCommands = {
    ugm_shroudr = {"", "Regenerate entirely the level shroud. NOTE: only works in levels where shroud is activated.", handle = function() Ext.BroadcastMessage("UGM_Shroud_Manager", "Regenerate", nil) end},
    ugm_slock = {"", "Lock/Unlock the selections. A locked selection mean that the character won't be unselected after a tool use.", handle = function () ManageLock(nil, "GM_Lock_Switch") end},
    ugm_sswitch = {"", "Switch the selection type. In normal mode, you'll see an 'S' on the top of selected characters. In discreet mode, it's only shown in the console.", handle = function() SwitchSelectionType() end},
    Wipe = {"", "Wipe persistent vars table.", handle = function(params) PersistentVars = {}; LoadVars() end},
    PrintVars = {"", "Print persistent vars table", handle = function(params) Ext.Print(Ext.JsonStringify(PersistentVars)) end},
    ugm_setscale = {"<float>", "Set the character scale to the float value. Normal scale is 1.0, but it can vary. Not saved to templates, only on instances.", 
        handle = function(params)
            for character, s in pairs(selected) do
                Ext.BroadcastMessage("UGM_SetCharacterScale", Ext.GetCharacter(character).NetID..":"..tostring(params[1]), nil)
                PersistentVars[currentLevel].scale[character] = params[1]
            end
        end},
    Helpugm = {"", "Display this help", handle = function(params) return nil end},
    ugm_statusapply = {"<status> <duration>", "Apply status to the selected characters with the duration specified in turns. The status name should be the engine name, can be lowercase.",
        handle = function(params) UGM_ApplyStatus(params[1], params[2]) end
    },
    ugm_showstatuses = {"", "Display the engine names of the visible statuses of the character in the console.", handle= function(params) UGM_ShowVisibleStatuses() end},
    ugm_talk = {"", "Toggle anim-on-click.", handle = function(params) ToggleBark() end},
    ugm_talktype = {"<type>", "Change talk type. Can be : normal, angry, sad, thankful, ignore.", handle = function(params) SetBarkType(params[1]) end},
    ugm_talkloop = {"<type>", "/!\\ EXPERIMENTAL /!\\ Make the character loop randomly in the talking animations of the specified type.", handle = function(params) StartTalkingAnimationLoop(params[1]) end},
    ugm_animate = {"<anim1> <anim2> ...", "/!\\ EXPERIMENTAL /!\\ Make the character loop randomly between the specified animations. Can be a single one, or multiple animations.", handle = function(params) StartCharacterAnimation(params) end},
    ugm_animloop = {"<animation>", "Make the character continuously loop on the specified animation.", handle = function(params) StartCharacterAnimationLoop(params[1]) end},
    ugm_animstop = {"", "Stop animations.", handle = function(params) StopAnimationLoop() end},
    ugm_setupstatus = {"<template> <name>", "Setup a new status ased on the template specified.", handle = function(params) CreateStatusFromTemplate(params[1], params[2]) end},
    ugm_setupstatusfinish = {"<keep>", "Finish the status setup. If keep = 1, the status will be saved. If keep = 0, the status will disappear upon reload.", handle = function(params) FinishStatusFromTemplate(params[1]) end},
    ugm_setstatusattribute = {"<attribute> <fixedBonus>", "Set the base bonus of the current status setup to provide the final bonus you input, instead of doing it manually. Works only for attributes.", handle = function(params) ModifyStatusAttributeBonus(params[1], params[2]) end},
    ugm_statabilityset = {"<ability> <value>", "Set the base ability of the character to the value. Use ability engine names.", handle = function(params) CharacterSetAbility(params[1], params[2]) end},
    ugm_statabilitygivepoint = {"<value>", "Give ability point(s) to the selected character(s).", handle = function(params) CharacterAddAbilityPoints(params[1]) end},
    ugm_statattributeset = {"<attribute> <value>", "Set the base attribute of the character to the value.", handle = function(params) CharacterSetAttribute(params[1], params[2]) end},
    ugm_statattributegivepoint = {"<value>", "Give attribute point(s) to the selected character(s).", handle = function(params) CharacterAddAbilityPoints(params[1]) end},
    ugm_stattalentset = {"<talent> <boolean>", "Give the talent as base (1 = yes, 0 = no)", handle = function(params) CharacterEnableTalent(params[1], params[2]) end},
    ugm_stattalentgivepoint = {"<value>", "Give talent point(s) to the selected character(s)", handle = function(params) CharacterAddTalentPoints(params[1]) end},
    ugm_statgiveskill = {"<skill>", "Give the skill to the selected character(s). Use engine names.", handle = function(params) CharacterGiveSkill(params[1]) end},
    ugm_statcheckskills = {"", "List all the skills the character possess.", handle = function(params) CharacterCheckSkills() end},
    ugm_statrespec = {"", "Respec the selected player characters", handle = function(params) Respec() end}
}

local UGM_commandKeys = {}
for key, desc in pairs(UGM_consoleCommands) do
    table.insert(UGM_commandKeys, key)
end
table.sort(UGM_commandKeys)

local function UGM_DisplayHelp()
    print("-------------- Ultimate GM Toolbox console help --------------")
    print("Note : commands with descriptions starting with '*' mean that it require at least one selected character")
    for i, command in pairs(UGM_commandKeys) do
        local desc = UGM_consoleCommands[command]
        print(" - "..command.." "..desc[1])
        print("         "..desc[2])
    end
    print()
end

local function UGM_consoleCmd(cmd, ...)
	local params = {...}
	for i=1,10,1 do
		local par = params[i]
		if par == nil then break end
		if type(par) == "string" then
			par = par:gsub("&", " ")
			par = par:gsub("\\ ", "&")
			params[i] = par
		end
    end
    for command,desc in pairs(UGM_consoleCommands) do
        if cmd == command then desc.handle(params) end
    end
    -- if cmd == "ugm_shroud_r" then PostMessageToAllUsers("UGM_Shroud_Manager", "Regenerate") end
    -- if cmd == "ugm_s_switch" then SwitchSelectionType() end
    if cmd == "Helpugm" then UGM_DisplayHelp() end
    -- if cmd == "Wipe" then PersistentVars = {}; LoadVars() end
    -- if cmd == "PrintVars" then Ext.Print(Ext.JsonStringify(PersistentVars)) end
    -- if cmd == "GetGameState" then Ext.Print(Ext.GetGameState()) end
    -- if cmd == "ugm_setscale" then
    --     for character, s in pairs(selected) do
    --         PostMessageToAllUsers("UGM_SetCharacterScale", Ext.GetCharacter(character).NetID..":"..tostring(params[1]))
    --     end
    -- end
    -- if cmd == "ugm_s_lock" then ManageLock(nil, "GM_Lock_Switch") end
end

-- Create console commands
for command,desc in pairs(UGM_consoleCommands) do
    Ext.RegisterConsoleCommand(command, UGM_consoleCmd)
end
