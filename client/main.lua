-- An event to bounce a request back to the server to open the bag's stash and set the current stash.
RegisterNetEvent('pc-bags:client:StashPreparation', function(stashId, weight, slots, emote, variant, duration)
    CreateThread(function()
        exports["rpemotes"]:EmoteCommandStart(emote, variant)
        exports["rpemotes"]:CanCancelEmote(false)
        Wait(duration)
        exports["rpemotes"]:EmoteCancel(true)
    end)

    TriggerEvent('inventory:client:SetCurrentStash', stashId)
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', stashId, { maxweight = weight, slots = slots })
end)
