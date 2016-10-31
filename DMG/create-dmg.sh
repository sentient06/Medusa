#! /bin/bash

mkdir -p ~/Development/Cocoa/Medusa/DMG_TEMP/
cp -R ~/Development/Cocoa/Medusa/DerivedData/Build/Products/Release/Medusa.app ~/Development/Cocoa/Medusa/DMG_TEMP/ ;
~/Development/Bash/create-dmg/create-dmg \
--volname "Medusa 1.2RC5" \
--volicon ~/Development/Cocoa/Medusa/DMG/medusa_dmg/dmg.icns \
--background ~/Development/Cocoa/Medusa/DMG/medusa_dmg/dmg5.png \
--window-pos 200 200 \
--window-size 600 360 \
--text-size 10 \
--text-position right \
--icon-size 128 \
--icon Medusa.app 142 114 \
--hide-extension Medusa.app \
--app-drop-link 416 186 \
~/Desktop/Medusa.1.2rc5.dmg \
~/Development/Cocoa/Medusa/DMG_TEMP ;
rm -rf ~/Development/Cocoa/Medusa/DMG_TEMP/
