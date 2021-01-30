local function ClearFromOsiUI()
    ClearSelectionAndTarget()
end

Ext.RegisterNetListener("UGM_Hotbar_UnselectAll", ClearFromOsiUI)

local function ManageLockUI()
    if PersistentVars.lock then 
        PersistentVars.lock = false
        print("Lock disabled")
    else 
        PersistentVars.lock = true
        print("Lock enabled")
    end
end

Ext.RegisterNetListener("UGM_Hotbar_SelectionLock", ManageLockUI)

local function ToggleAnimOnClickUI()
    if animOnClick then
        animOnClick = false
    else
        animOnClick = true
    end
end

Ext.RegisterNetListener("UGM_Hotbar_ToggleBark", ToggleAnimOnClickUI)

local function StartFollowingUI()
    FollowTarget(nil, "GM_Start_Follow")
end

Ext.RegisterNetListener("UGM_Hotbar_StartFollow", StartFollowingUI)

local function StoryFreezeUI()
    if GetTableSize(selected) < 1 then
        local players = Osi.DB_IsPlayer:Get(nil)
        
        for i,player in pairs(players) do
            player = player[1]
            if HasActiveStatus(player, "GM_STORYFREEZE") == 0 then
                CharacterFreeze(player)
                ApplyStatus(player, "GM_STORYFREEZE", -1.0)
            else
                CharacterUnfreeze(player)
                RemoveStatus(player, "GM_STORYFREEZE")
            end
        end
    else
        for char,x in pairs(selected) do
            if HasActiveStatus(char, "GM_STORYFREEZE") == 0 then
                CharacterFreeze(char)
                ApplyStatus(char, "GM_STORYFREEZE", -1.0)
            else
                CharacterUnfreeze(char)
                RemoveStatus(char, "GM_STORYFREEZE")
            end
        end
    end
end

Ext.RegisterNetListener("UGM_Hotbar_StoryFreeze", StoryFreezeUI)