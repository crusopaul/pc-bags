local QBCore = exports['qb-core']:GetCoreObject()

-- Create usable item callbacks.
CreateThread(function()
    for k,v in pairs(Config.Server.BagTypes) do
        QBCore.Functions.CreateUseableItem(k, function(source, item)
            TriggerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.4)

            local src = source
            local player = QBCore.Functions.GetPlayer(src)
            local playerData = player.PlayerData
            local items = playerData.items
            local itemSlot = item.slot
            local citizenid = playerData.citizenid

            if items[itemSlot] then
                local itemInfo = item.info or {}

                if not itemInfo.id then
                    CreateStash(citizenid, item)
                end

                local stashId = itemInfo.id

                if stashId ~= 'soiled' then
                    TriggerClientEvent('pc-bags:client:StashPreparation', src, stashId, v.StashWeight, v.Slots, (v.OpenAnim or {}).Emote, (v.OpenAnim or {}).Variant, (v.OpenAnim or {}).Time)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Stash is soiled')
                end
            end
        end)
    end
end)

-- Poll for expiration and delete orphaned stashes.
CreateThread(function()
    while true do
        if Config.Server.Verbose then
            print('Beginning expiration and deletion of bags...')
        end

        ExpireAndDelete()

        if Config.Server.Verbose then
            print('Finished expiration and deletion of bags.')
        end

        Wait(Config.Server.PollTime * 60000)
    end
end)
