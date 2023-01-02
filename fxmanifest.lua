name "pc-bags"
description 'A self-cleaning, generic bag resource for qb-core.'
version '0.0.3'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/config.lua',
    'server/sql.lua',
    'server/export.lua',
    'server/function.lua',
    'server/thread.lua',
}

client_script 'client/main.lua'

dependency 'oxmysql'
