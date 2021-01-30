local talkAnims = {
    angry = "emotion_angry_looping",
    ignore = "emotion_ignore_dismiss_looping",
    normal = "emotion_normal_looping",
    sad = "emotion_sad_looping",
    thankful = "emotion_thankful_looping",
    none = ""
}

animOnClick = false

function AddToAttribute(attribute, value)
    for char,x in pairs(selected) do
        CharacterAddAttribute(char, attribute, value)
    end
end

function AddSkill(skill)
    for char,x in pairs(selected) do
        CharacterAddSkill(char, skill, 1)
    end
end

function RemoveSkill(skill)
    for char,x in pairs(selected) do
        CharacterRemoveSkill(char, skill)
    end
end

-- Click to Anim feature
function ToggleBark()
    if not animOnClick then
        animOnClick = true
        print("AnimOnClick on")
    else
        animOnClick = false
        print("AnimOnClick off")
    end
end

function SetBarkType(type)
    PersistentVars.talkType = type
    print("AnimOnClick type set to "..type)
end

local function BarkOnClick(call, netID)
    local char = Ext.GetCharacter(tonumber(netID))
    if not animOnClick then return end
    if HasActiveStatus(char.MyGuid, "DEACTIVATED") == 1 then return end
    local randInt = math.random(1, 3)
    CharacterFlushQueue(char.MyGuid)
    PlayAnimation(char.MyGuid, talkAnims[PersistentVars.talkType]..randInt)
end

Ext.RegisterNetListener("UGM_QuickSelection", BarkOnClick)

-- Anim feature
local function StartAnimations(char, animations)
    SetVarString(char, "UGM_Animations", Ext.JsonStringify(animations))
    SetVarString(char, "UGM_AnimType", "Normal")
    PersistentVars[currentLevel].anims[char] = animations
    ApplyStatus(char, "GM_ANIMATED", -1.0, 1)
    TimerLaunch("UGM_Timer_Anim_"..char, math.random(5, 10)*1000)
end

local function StartAnimLoop(char, animation)
    SetVarString(char, "UGM_Animations", Ext.JsonStringify({animation}))
    SetVarString(char, "UGM_AnimType", "Loop")
    PersistentVars[currentLevel].animLoop[char] = animation
    ApplyStatus(char, "GM_ANIMATED", -1.0, 1)
    CharacterSetAnimationOverride(char, animation)
end

function StartCharacterAnimation(animations)
    for char,x in pairs(selected) do
        StartAnimations(char, animations)
    end
end

function StartCharacterAnimationLoop(animation)
    for char,x in pairs(selected) do
        StartAnimLoop(char, animation)
    end
end

function StartTalkingAnimationLoop(type)
    local anims = {}
    for i=1,3,1 do
        anims[i] = talkAnims[type]..i
    end
    StartCharacterAnimation(anims)
end

local function LoopAnimation(timerEvent)
    if not string.startswith(timerEvent, "UGM_Timer_Anim_") then return end
    local char = string.gsub(timerEvent, "UGM_Timer_Anim_", "")
    if HasActiveStatus(char, "DEACTIVATED") == 1 or HasActiveStatus(char, "GM_ANIMATED") == 0 then return end
    local anims = Ext.JsonParse(GetVarString(char, "UGM_Animations"))
    local random = math.random(1, GetTableSize(anims))
    CharacterFlushQueue(char)
    PlayAnimation(char, anims[random])
    TimerLaunch("UGM_Timer_Anim_"..char, math.random(3, 8)*1000)
end

Ext.RegisterOsirisListener("TimerFinished", 1, "before", LoopAnimation)

local function InterruptAnimation(char, status, causee)
    if status == "DEACTIVATED" and HasActiveStatus(char, "GM_ANIMATED") == 1 then
        CharacterPurgeQueue(char)
        CharacterSetAnimationOverride(char, "")
    end
end

Ext.RegisterOsirisListener("CharacterStatusAttempt", 3, "before", InterruptAnimation)

-- local function DeactivateAnimatedChar(timerEvent)
--     if not string.startswith(timerEvent, "UGM_Timer_DeactivationAnim_") then return end
--     local char = string.gsub(timerEvent, "UGM_Timer_DeactivationAnim_", "")
--     ApplyStatus(char, "DEACTIVATED", -1.0, 1)
-- end

-- Ext.RegisterOsirisListener("TimerFinished", 1, "before", DeactivateAnimatedChar)

local function ResumeAnimation(char, status, causee)
    if status == "DEACTIVATED" and HasActiveStatus(char, "GM_ANIMATED") == 1 then
        local animType = GetVarString(char, "UGM_AnimType")
        if animType == "Normal" then
            TimerLaunch("UGM_Timer_Anim_"..char, math.random(5, 10)*1000)
        else
            CharacterSetAnimationOverride(char, Ext.JsonParse(GetVarString(char, "UGM_Animations"))[1])
        end
    end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", ResumeAnimation)

local function EndAnimation(char, status, causee)
    if status ~= "GM_ANIMATED" then return end
    CharacterPurgeQueue(char)
    CharacterSetAnimationOverride(char, "")
    if GetVarString(char, "UGM_AnimType") == "Normal" then
        PersistentVars[currentLevel].anims[char] = nil
    else
        PersistentVars[currentLevel].animLoop[char] = nil
    end
    SetVarString(char, "UGM_Animations", "")
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", EndAnimation)

function StopAnimationLoop()
    for char,x in pairs(selected) do
        SetVarString(char, "UGM_Animations", "")
        RemoveStatus(char, "GM_ANIMATED")
    end
end