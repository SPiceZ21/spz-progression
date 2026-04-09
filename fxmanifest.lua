fx_version 'cerulean'
game 'gta5'

description 'spz-progression — XP, iRating, SR & Season logic'
version '1.0.0'

shared_scripts {
    '@spz-lib/shared/main.lua',
    '@spz-lib/shared/logger.lua',
    'config.lua',
    'shared/points.lua',
    'shared/ranks.lua',
    'shared/licenses.lua'
}

server_scripts {
    'server/main.lua',
    'server/xp.lua',
    'server/points.lua',
    'server/sr.lua',
    'server/irating.lua',
    'server/ranks.lua',
    'server/promotion.lua',
    'server/season.lua'
}

client_scripts {
    'client/main.lua'
}

lua54 'yes'
