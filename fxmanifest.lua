fx_version 'cerulean'
game 'gta5'

name 'spz-progression'
description 'SPiceZ-Core — XP, SR, iRating, ranks, license promotion'
version '1.0.0'
author 'SPiceZ-Core'

shared_scripts {
  'shared/init.lua',
  'shared/points.lua',
  'shared/ranks.lua',
  'shared/licenses.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server/main.lua',
  'server/xp.lua',
  'server/points.lua',
  'server/sr.lua',
  'server/irating.lua',
  'server/ranks.lua',
  'server/promotion.lua',
  'server/season.lua',
}

client_scripts {
  'client/main.lua',
}

dependencies {
  'spz-lib',
  'spz-core',
  'spz-identity',
  'spz-races',
}
