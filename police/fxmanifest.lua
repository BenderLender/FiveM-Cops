fx_version 'bodacious'
game 'gta5'
version '1.5.1'

ui_page('client/html/index.html')

files({
    'client/html/index.html',
    'client/html/js/script.js',
    'client/html/css/style.css',
    'client/html/img/background.png',
    'client/html/img/arrows_upanddown.jpg',
    'client/html/fonts/SignPainter-HouseScript.ttf',
    'client/html/sounds/panic.ogg'
})

client_scripts {
  'client/i18n.lua',
  'locales/en.lua',
  'locales/fr.lua',
  'locales/de.lua',
  'config/cloackroom.lua',
  'config/config.lua',
  'config/objects.lua',
  'config/vehicles.lua',
  'config/weapons.lua',
  'client/client.lua',
  'client/cloackroom.lua',
  'client/menu.lua',
  'client/garage.lua',
  'client/armory.lua',
  'client/panic_c.lua'
}

server_scripts {
  'client/i18n.lua',
  'locales/en.lua',
  'locales/fr.lua',
  'locales/de.lua',  
  'config/config.lua',
  'server/server.lua',
  'server/panic_s.lua'
}

dependency 'NativeUI'
client_script "@NativeUI/NativeUI.lua"

client_script 'client/bcpcl.lua'
server_script 'server/bcpsv.lua'
