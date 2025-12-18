fx_version 'cerulean'
game 'gta5'

author 's6la'
description 'One-Handed Weapon Running Animation'
version '1.0.0'

shared_script '@WaveShield/resource/include.lua'
shared_script '@WaveShield/resource/waveshield.js'
shared_scripts {
    '@s6la_bridge/shared/config.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

dependency 's6la_bridge'
dependency 'ox_lib'

