#!/bin/bash
# Compiles String Catalog + asset catalog into Bundle.module-ready products.
# SwiftPM (swift build / swift test) does not process .xcstrings or
# .xcassets itself, so these generated files must be regenerated and kept
# in sync whenever the sources change:
#
#   Localizable.xcstrings            -> {en,zh-Hans,zh-Hant}.lproj/Localizable.strings
#   Assets.xcassets                  -> Assets.car (iphoneos)
#   Assets.xcassets                  -> Flags/{code}.png (loose 3x PNGs; AppKit
#                                       cannot read an iOS-compiled Assets.car,
#                                       and the catalogs only fill the 3x slot)
set -euo pipefail
cd "$(dirname "$0")/.."

RESOURCES="Sources/iso3166/Resources"

xcrun xcstringstool compile "$RESOURCES/Localizable.xcstrings" --output-directory "$RESOURCES"

xcrun actool "$RESOURCES/Assets.xcassets" \
    --compile "$RESOURCES" \
    --platform iphoneos \
    --minimum-deployment-target 14.0 \
    --output-partial-info-plist "$(mktemp -t partial-actool).plist"

rm -rf "$RESOURCES/Flags"
mkdir -p "$RESOURCES/Flags"
for dir in "$RESOURCES/Assets.xcassets"/*.imageset; do
    code="$(basename "${dir%.imageset}")"
    png="$(find "$dir" -maxdepth 1 -name '*.png' | head -1)"
    [ -n "$png" ] && cp "$png" "$RESOURCES/Flags/$code.png"
done

echo "Compiled $(find "$RESOURCES" -name 'Localizable.strings' | wc -l | tr -d ' ') localization(s) + Assets.car"
