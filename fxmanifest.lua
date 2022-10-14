name "pc-bags"
description ''
version '0.0.1'
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
