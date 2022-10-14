function DeleteExpiredInventoryItems()
    local expiredItems = MySQL.query.await(Config.Server.SQL.FindExpiredInventoryItems, {})

    for _,v in ipairs(expiredItems) do
        SoilItem(v.citizenid, v.inventory, v.slot)
    end

    return #expiredItems
end

function DeleteExpiredItems(tableName)
    local expiredItems

    if tableName == Config.Server.GloveboxTable then
        expiredItems = MySQL.query.await(Config.Server.SQL.FindExpiredGloveboxItems, {})

        for _,v in ipairs(expiredItems) do
            SoilGloveboxItem(v.plate, v.items, v.slot)
        end
    elseif tableName == Config.Server.StashTable then
        expiredItems = MySQL.query.await(Config.Server.SQL.FindExpiredStashItems, {})

        for _,v in ipairs(expiredItems) do
            SoilStashItem(v.stash, v.items, v.slot)
        end
    elseif tableName == Config.Server.TrunkTable then
        expiredItems = MySQL.query.await(Config.Server.SQL.FindExpiredTrunkItems, {})

        for _,v in ipairs(expiredItems) do
            SoilTrunkItem(v.plate, v.items, v.slot)
        end
    end

    return #expiredItems
end

function DeleteSelfContainedStashes()
    local scItems = MySQL.query.await(Config.Server.SQL.FindSelfContainedStashItems, {})

    for _,v in ipairs(scItems) do
        SoilStashItem(v.stash, v.items, v.slot)
    end

    return #scItems
end

function DeleteOrphanedItems()
    return MySQL.update.await(Config.Server.SQL.DeleteOrphanedItems, {})
end
