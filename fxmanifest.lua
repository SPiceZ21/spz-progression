fx_version 'cerulean'
game 'gta5'

name 'spz-progression'
description 'SPiceZ-Core — XP, SR, iRating, ranks, license promotion'
version '1.0.0'
author 'SPiceZ-Core'

shared_scripts {
  '@spz-lib/shared/main.lua',
  '@spz-lib/shared/callbacks.lua',
  '@spz-lib/shared/notify.lua',
  '@spz-lib/shared/timer.lua',
  '@spz-lib/shared/logger.lua',
  '@spz-lib/shared/math.lua',
  '@spz-lib/shared/table.lua',
  '@spz-lib/shared/string.lua',
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
