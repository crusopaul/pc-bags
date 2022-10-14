local bagTypeAndExpirationCheckSQL = ''
local bagTypeCheckSQL = ''

for k,v in pairs(Config.Server.BagTypes) do
    bagTypeAndExpirationCheckSQL = '( b.name = "'..k..'" and '..v.Expires..' != 0 and now() > date_add(b.created, interval '..v.Expires..' minute) ) or '
    bagTypeCheckSQL = '( a.stash like "'..k..'_%" ) or '
end

bagTypeAndExpirationCheckSQL = string.sub(bagTypeAndExpirationCheckSQL, 1, string.len(bagTypeAndExpirationCheckSQL) - 4)
bagTypeCheckSQL = string.sub(bagTypeCheckSQL, 1, string.len(bagTypeCheckSQL) - 4)

Config.Server.SQL = {
    DeleteExpiredGloveboxItems = [[UPDATE ]]..Config.Server.GloveboxTable..[[ a
set items = ?
where
    a.plate = ?;
    ]],

    DeleteExpiredInventoryItems = [[UPDATE players a
set inventory = ?
where
    a.citizenid = ?;
    ]],

    DeleteExpiredStashItems = [[UPDATE ]]..Config.Server.StashTable..[[ a
set items = ?
where
    a.stash = ?;
    ]],

    DeleteExpiredTrunkItems = [[UPDATE ]]..Config.Server.TrunkTable..[[ a
set items = ?
where
    a.plate = ?;
    ]],

    DeleteOrphanedItems = [[DELETE a from ]]..Config.Server.StashTable..[[ a
left join (
    select bb.id
    from ]]..Config.Server.GloveboxTable..[[ aa
    join json_table(
        aa.items,
        '$[*]' columns (
            nested path '$.info' columns (
                id varchar(200) path '$.id'
            )
        )
    ) bb
) b
on
    b.id = a.stash
left join (
    select bb.id
    from ]]..Config.Server.StashTable..[[ aa
    join json_table(
        aa.items,
        '$[*]' columns (
            nested path '$.info' columns (
                id varchar(200) path '$.id'
            )
        )
    ) bb
) c
on
    c.id = a.stash
left join (
    select bb.id
    from ]]..Config.Server.TrunkTable..[[ aa
    join json_table(
        aa.items,
        '$[*]' columns (
            nested path '$.info' columns (
                id varchar(200) path '$.id'
            )
        )
    ) bb
) d
on
    d.id = a.stash
left join (
    select bb.id
    from players aa
    join json_table(
        aa.inventory,
        '$[*]' columns (
            nested path '$.info' columns (
                id varchar(200) path '$.id'
            )
        )
    ) bb
) e
on
    e.id = a.stash
where
    b.id is null
    and c.id is null
    and d.id is null
    and e.id is null
    and (
        ]]..bagTypeCheckSQL..[[
    )
    ]],

    FindExpiredGloveboxItems = [[SELECT a.plate, a.items, b.slot
from ]]..Config.Server.GloveboxTable..[[ a
join json_table(
    a.items,
    '$[*]' columns (
        name varchar(200) path '$.name',
        slot int path '$.slot',
        nested path '$.info' columns (
            id varchar(200) path '$.id',
            created datetime path '$.created'
        )
    )
) b
where
    (
        ]]..bagTypeAndExpirationCheckSQL..[[
    )
    and b.id != 'soiled';
    ]],

    FindExpiredInventoryItems = [[SELECT a.citizenid, a.inventory, b.name, b.slot, b.id
from players a
join json_table(
    a.inventory,
    '$[*]' columns (
        name varchar(200) path '$.name',
        slot int path '$.slot',
        nested path '$.info' columns (
            id varchar(200) path '$.id',
            created datetime path '$.created'
        )
    )
) b
where
    (
        ]]..bagTypeAndExpirationCheckSQL..[[
    )
    and b.id != 'soiled';
    ]],

    FindExpiredStashItems = [[SELECT a.stash, a.items, b.slot
from ]]..Config.Server.StashTable..[[ a
join json_table(
    a.items,
    '$[*]' columns (
        name varchar(200) path '$.name',
        slot int path '$.slot',
        nested path '$.info' columns (
            id varchar(200) path '$.id',
            created datetime path '$.created'
        )
    )
) b
where
    (
        ]]..bagTypeAndExpirationCheckSQL..[[
    )
    and b.id != 'soiled';
    ]],

    FindExpiredTrunkItems = [[SELECT a.plate, a.items, b.slot
from ]]..Config.Server.TrunkTable..[[ a
join json_table(
    a.items,
    '$[*]' columns (
        name varchar(200) path '$.name',
        slot int path '$.slot',
        nested path '$.info' columns (
            id varchar(200) path '$.id',
            created datetime path '$.created'
        )
    )
) b
where
    (
        ]]..bagTypeAndExpirationCheckSQL..[[
    )
    and b.id != 'soiled';
    ]],

    FindSelfContainedStashItems = [[SELECT a.stash, a.items, b.slot
from ]]..Config.Server.StashTable..[[ a
join json_table(
    a.items,
    '$[*]' columns (
        name varchar(200) path '$.name',
        slot int path '$.slot',
        nested path '$.info' columns (
            id varchar(200) path '$.id',
            created datetime path '$.created'
        )
    )
) b
where (
        ]]..bagTypeCheckSQL..[[
    )
    and a.stash = b.id;
    ]],

    InsertStash = 'INSERT into '..Config.Server.StashTable.." ( stash, items ) values ( ?, '[]' );",

    StashExistenceCheck = 'SELECT 1 from '..Config.Server.StashTable..' where stash = ?;',
}

Config.Server.SQL.InstantiateBag = Config.Server.SQL.DeleteExpiredInventoryItems
