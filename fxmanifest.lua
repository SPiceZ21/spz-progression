fx_version 'cerulean'
game 'gta5'

name 'spz-progression'
description 'SPiceZ-Core — XP, SR, iRating and Rank Points (ranking v3)'
version '1.1.0'
author 'SPiceZ-Core'

shared_scripts {
  '@ox_lib/init.lua',   -- lib.callback for the leaderboard's Rivals tab
  '@spz-core/shared/events.lua',
  'shared/init.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  -- pure domain code (no natives / exports / DB) — also run by tests/run.lua
  'domain/rank.lua',
  'domain/rp.lua',
  'domain/irating.lua',
  'domain/sr.lua',
  'server/xp.lua',
  'server/main.lua',
  'server/bonus.lua',
  'server/rank_admin.lua',
  'server/rivals.lua',
}

client_scripts {
  'client/main.lua',
}

dependencies {
  'ox_lib',
  'spz-core',
  'spz-identity',
  'spz-races',
}
