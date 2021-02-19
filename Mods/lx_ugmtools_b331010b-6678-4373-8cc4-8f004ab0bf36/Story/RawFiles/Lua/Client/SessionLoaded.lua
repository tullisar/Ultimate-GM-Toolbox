Ext.Print("Restoring scalings...")

local function ClientRestoreScalings()
    if Ext.GetGameState() == "Running" then
        Ext.PostMessageToServer("UGM_ClientLoaded", "RestoreScalings")
    end
end

Ext.RegisterListener("GameStateChanged", ClientRestoreScalings)