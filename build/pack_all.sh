#!/bin/bash

ITCH_USER="cranberryninja"
ITCH_PAGE="scribble-wizards"
GAMENAME="scribble_wizards"

# Clean up old
rm ./linux/*
rm ./windows/*
rm ./html/*
rm ./*.zip


# Build new files
cd ..
godot --headless --export-debug "Linux/X11" ./build/linux/$GAMENAME.x86-64
godot --headless --export-debug "Windows Desktop" ./build/windows/$GAMENAME.exe
godot --headless --export-debug "Web" ./build/html/index.html
cd build


# Zip up new files
cd linux
zip -r ../${GAMENAME}_linux.zip ./*
cd ../windows
zip -r ../${GAMENAME}_windows.zip ./*
cd ../html
zip -r ../${GAMENAME}_html.zip ./*
cd ..

# Push files to itch
butler push ${GAMENAME}_html.zip ${ITCH_USER}/${ITCH_PAGE}:html5
butler push ${GAMENAME}_linux.zip ${ITCH_USER}/${ITCH_PAGE}:linux
butler push ${GAMENAME}_windows.zip ${ITCH_USER}/${ITCH_PAGE}:win
