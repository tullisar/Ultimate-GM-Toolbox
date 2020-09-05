Ext.Require("UGM_Helpers.lua")
Ext.Require("UGM_Selection.lua")
Ext.Require("UGM_Patrol.lua")

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
    UGM_ShroudManager_Regenerate = {1, "", "Regenerate entirely the level shroud. NOTE: only works in levels where shroud is activated."},
    UGM_Selection_Type_Switch = {2, "", "Switch the selection type. In normal mode, you'll see an 'S' on the top of selected characters. In discreet mode, it's only shown in the console."},
    Help = {3, "", "Display this help."},
    Wipe = {4, "", "Wipe persistent vars table."},
    PrintVars = {5, "", "Print persistent vars table"},
    GetGameState = {6, "", "Get Current Game State"},
    UGM_SetScale = {7, "<float>", "Set the character scale to the float value. Normal scale is 1.0, but it can vary."}
}

local function UGM_DisplayHelp()
    print("-------------- Ultimate GM Toolbox console help --------------")
    print("Note : commands with descriptions starting with '*' mean that it require at least one selected character")
    local sorted = {}
    for command,desc in pairs(UGM_consoleCommands) do
        sorted[desc[1]] = command
    end
    for i,command in pairs(sorted) do
        local desc = UGM_consoleCommands[sorted[i]]
        print(" - "..command.." "..desc[2])
        print("         "..desc[3])
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
end

-- Create console commands
for command,desc in pairs(UGM_consoleCommands) do
    Ext.RegisterConsoleCommand(command, UGM_consoleCmd)
end