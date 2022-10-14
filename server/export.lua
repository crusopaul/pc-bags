local QBCore = exports['qb-core']:GetCoreObject()

-- An internal function for printing non-zero counts
local function AddToResults(count, desc)
    if Config.Server.Verbose then
        if tonumber(count) ~= 0 then
            print(string.format(desc, count))
        end
    end
end

-- Manually expire and perform orphan deletion.
function ExpireAndDelete()
    for k,_ in pairs(QBCore.Functions.GetQBPlayers()) do
        QBCore.Player.Save(k)
    end

    AddToResults(DeleteExpiredInventoryItems(), '%d bags were expired in player inventories.')
    AddToResults(DeleteSelfContainedStashes(), '%d self-contained bags were expired from stashes.')
    AddToResults(DeleteExpiredItems(Config.Server.GloveboxTable), '%d bags were expired in vehicle gloveboxes.')
    AddToResults(DeleteExpiredItems(Config.Server.StashTable), '%d bags were expired in stashes.')
    AddToResults(DeleteExpiredItems(Config.Server.TrunkTable), '%d bags were expired in vehicle trunks.')

    local orphanCount

    repeat
        orphanCount = tonumber(DeleteOrphanedItems())
        AddToResults(orphanCount, '%d orphaned bags were deleted.')
        Wait(0)
    until orphanCount == 0
end

exports('ExpireAndDelete', ExpireAndDelete)

-- An internal function for updating a table that represents an inventory
local function SoilItemInternal(items, slot)
    for _,v in pairs(items) do
        if v.slot == slot then
            v.info.id = 'soiled'
            break
        end
    end
end

-- Soil an item in an inventory.
function SoilItem(citizenid, inventory, slot)
    local invTable = json.decode(inventory)

    SoilItemInternal(invTable, slot)
    MySQL.prepare.await(Config.Server.SQL.DeleteExpiredInventoryItems, { json.encode(invTable), citizenid })
end

exports('SoilItem', SoilItem)

-- Soil an item in a glovebox.
function SoilGloveboxItem(plate, items, slot)
    local invTable = json.decode(items)

    SoilItemInternal(invTable, slot)
    MySQL.prepare.await(Config.Server.SQL.DeleteExpiredGloveboxItems, { json.encode(invTable), plate })
end

exports('SoilGloveboxItem', SoilGloveboxItem)

-- Soil an item in a stash.
function SoilStashItem(stash, items, slot)
    local invTable = json.decode(items)

    SoilItemInternal(invTable, slot)
    MySQL.prepare.await(Config.Server.SQL.DeleteExpiredStashItems, { json.encode(invTable), stash })
end

exports('SoilStashItem', SoilStashItem)

-- Soil an item in a trunk.
function SoilTrunkItem(plate, items, slot)
    local invTable = json.decode(items)

    SoilItemInternal(invTable, slot)
    MySQL.prepare.await(Config.Server.SQL.DeleteExpiredTrunkItems, { json.encode(invTable), plate })
end

exports('SoilTrunkItem', SoilTrunkItem)

-- Stash existence check (works for any stash, not just the bag's defined by this resource).
function DoesStashExist(stashName)
    return MySQL.prepare.await(Config.Server.SQL.StashExistenceCheck, { stashName })
end

exports('DoesStashExist', DoesStashExist)

-- Local for getting an available stash name.
local function GetNewStashName(bagType)
    local stashNamePrefix = bagType..'_'
    local stashName

    repeat
        stashName = stashNamePrefix..string.format('%07d', tostring(math.random(1, 1000000)))
        Wait(0)
    until not DoesStashExist(stashName)

    MySQL.prepare.await(Config.Server.SQL.InsertStash, { stashName })

    return stashName
end

-- Create a bag's stash and start its countdown to expiration if applicable.
function CreateStash(citizenid, item)
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    local itemSlot = item.slot
    local itemInfo = item.info
    local itemName = item.name

    if player then
        itemInfo.id = GetNewStashName(itemName)
        itemInfo.created = os.date('%Y-%m-%d %H:%M:%S')
        player.PlayerData.items[itemSlot].info = itemInfo
        player.Functions.SetInventory(player.PlayerData.items, true)
    else
        local inventory = PlayerData.items

        for _,q in pairs(inventory) do
            if q.slot == itemSlot then
                q.info = q.info or {}
                q.info.id = GetNewStashName(itemName)
                q.info.created = os.date('%Y-%m-%d %H:%M:%S')
                break
            end
        end

        MySQL.prepare.await(Config.Server.SQL.InstantiateBag, { json.encode(inventory), citizenid })
    end
end

exports('CreateStash', CreateStash)
