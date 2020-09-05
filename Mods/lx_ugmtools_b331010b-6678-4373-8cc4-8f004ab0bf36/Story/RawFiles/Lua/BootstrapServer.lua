Ext.Require("UGM_Helpers.lua")
Ext.Require("UGM_Selection.lua")
Ext.Require("UGM_Movement.lua")

-- Users management
local users = {}

local function AddUser(userID, userName, userProfileID)
    users[userID] = userName
end

Ext.RegisterOsirisListener("UserConnected", 3, "before", AddUser)

local function RemoveUser(userID, userName, userProfileID)
    users[userID] = nil
end

Ext.RegisterOsirisListener("UserDisconnected", 3, "before", RemoveUser)

local function CheckIfUserExists(userID)
    local userProfileID = GetUserProfileID(userID)
    if userProfileID == nil then users[userID] = nil end
end

local function LookForUsers()
    IterateUsers("UGM_Count_Users")
end

local function AddUser2(userID, userEvent)
    if userEvent ~= "UGM_Count_Users" then return end
    print("Found user "..userID)
    users[userID] = GetUserName(userID)
end

Ext.RegisterOsirisListener("UserEvent", 2, "before", AddUser2)

local function PostMessageToAllUsers(channel, message)
    if GetTableSize(users) < 1 then 
        print("No user available. Now searching for users, please retry the command.")
        LookForUsers() 
        return
    end
    for userID, userProfileID in pairs(users) do
        if GetUserProfileID(userID) ~= nil then
            --print("Sending message to user "..userID)
            Ext.PostMessageToUser(userID, channel, message)
        end
    end
end


-- Console commands
local UGM_consoleCommands = {
    UGM_ShroudManager_Regenerate = {"", "Regenerate entirely the level shroud. NOTE: only works in levels where shroud is activated."},
    UGM_Selection_Type_Switch = {"", "Switch the selection type. In normal mode, you'll see an 'S' on the top of selected characters. In discreet mode, it's only shown in the console."},
    Help = {"", "Display this help."},
    Wipe = {"", "Wipe persistent vars table."},
    PrintVars = {"", "Print persistent vars table"},
    GetGameState = {"", "Get Current Game State"},
    UGM_SetScale = {"<float>", "Set the character scale to the float value. Normal scale is 1.0, but it can vary."},
    UGM_Selection_Lock = {"", "Lock/Unlock the selections. A locked selection mean that the character won't be unselected after a tool use."}
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
    if cmd == "UGM_ShroudManager_Regenerate" then PostMessageToAllUsers("UGM_Shroud_Manager", "Regenerate") end
    if cmd == "UGM_Selection_Type_Switch" then SwitchSelectionType() end
    if cmd == "Help" then UGM_DisplayHelp() end
    if cmd == "Wipe" then PersistentVars = {}; LoadVars() end
    if cmd == "PrintVars" then Ext.Print(Ext.JsonStringify(PersistentVars)) end
    if cmd == "GetGameState" then Ext.Print(Ext.GetGameState()) end
    if cmd == "UGM_SetScale" then
        for character, s in pairs(selected) do
            PostMessageToAllUsers("UGM_SetCharacterScale", Ext.GetCharacter(character).NetID..":"..tostring(params[1]))
        end
    end
    if cmd == "UGM_Selection_Lock" then ManageLock(nil, "GM_Lock_Switch") end
end

-- Create console commands
for command,desc in pairs(UGM_consoleCommands) do
    Ext.RegisterConsoleCommand(command, UGM_consoleCmd)
end