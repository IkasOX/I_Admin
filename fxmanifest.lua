fx_version 'cerulean'
game 'gta5'
author 'Ika\'s'
description 'Admin menu by Ika\'s'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'config/*.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/*.lua',
    'server/*.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}

