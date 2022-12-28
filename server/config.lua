Config = {
    Server = {
        -- How long in minutes you want the stash expiration & orphan deletion to occur.
        PollTime = 10,

        -- Whether or not to print expiration & orphan deletion breakdown.
        Verbose = true,

        -- Which tables correspond to the stash-like tables that your inventory / environment uses.
        GloveboxTable = 'gloveboxitems',
        StashTable = 'stashitems',
        TrunkTable = 'trunkitems',

        -- The bag properties of the custom bag types:
        --     OpenAnim is the name, variant, and duration of the rpemotes emote to play when opened
        --     StashWeight is the weight capacity of the bag.
        --     Slots is the number of slots of the bag.
        --     Expires is the number of minutes it takes for a bag to expire (0 to never expire.)
        BagTypes = {
            ['backpack'] = {
                OpenAnim = { Emote = 'backpack' , Variant = nil, Time = 5000 },
                StashWeight = 60000,
                Slots = 20,
                Expires = 0
            },
            ['box'] = {
                OpenAnim = { Emote = 'box' , Variant = nil, Time = 5000 },
                StashWeight = 50000,
                Slots = 40,
                Expires = 240
            },
            ['burgershotbag'] = {
                OpenAnim = { Emote = 'carryfoodbag' , Variant = nil, Time = 5000 },
                StashWeight = 5000,
                Slots = 10,
                Expires = 60
            },
            ['dufflebag'] = {
                OpenAnim = { Emote = 'dufbag' , Variant = nil, Time = 5000 },
                StashWeight = 40000,
                Slots = 10,
                Expires = 0
            },
        },
    }
}
