#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
APP="${PWD}/Мастерская Fusion.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/Course"
swiftc Sources/App.swift -o "$APP/Contents/MacOS/FusionWorkshop" -framework Cocoa -framework WebKit -O
cp Resources/*.html Resources/*.css Resources/*.js Resources/*.png "$APP/Contents/Resources/Course/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/WorkshopIcon.icns"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleName</key><string>Мастерская Fusion</string><key>CFBundleDisplayName</key><string>Мастерская Fusion</string><key>CFBundleIdentifier</key><string>local.roman.fusionworkshop</string><key>CFBundleExecutable</key><string>FusionWorkshop</string><key>CFBundleIconFile</key><string>WorkshopIcon.icns</string><key>CFBundlePackageType</key><string>APPL</string><key>CFBundleShortVersionString</key><string>1.2</string><key>CFBundleVersion</key><string>4</string><key>LSMinimumSystemVersion</key><string>14.0</string><key>NSHighResolutionCapable</key><true/></dict></plist>
PLIST
codesign --force --deep --sign - "$APP"
