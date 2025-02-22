fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author "Stevo Scripts | Kayne"
description 'Community Service System.'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'resource/client.lua',
}

server_scripts {
    'resource/server.lua',
    '@oxmysql/lib/MySQL.lua'
}

files {
    'config.lua',
    'locales/*.json'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'stevo_lib'
}