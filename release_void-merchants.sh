#!/bin/bash

# Not tested, but should also work on Linux. Don't forget to adjust PICO8_EXT and _7Z_EXE

PICO8_EXE="/c/Program Files (x86)/PICO-8/pico8.exe"
_7Z_EXE="/c/Program Files/7-Zip/7z.exe"
VERSION=$(cat ./VERSION)

if [[ -n $(git status --porcelain | grep -v 'M VERSION') ]]; then
  echo "There are pending changes in the repository besides ther VERSION file. Commit or revert them first."
  exit
fi

echo "Starting to prepare release of $VERSION for void-merchants..."

echo "Switching to main branch for the release..."
git switch main

if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "Git tag $VERSION already exists. Change the version in <project_root>/VERSION"
  exit
fi

echo "Writing $VERSION to void_merchants.p8 and the manual.txt..."
sed -i 's/^\(GAME_VERSION[[:space:]]*=[[:space:]]*"\)[^"]*\(".*\)/\1'"$VERSION"'\2/' ./void_merchants.p8
sed -i 's/\(Manual for version \)[^ ]\+/\1'"$VERSION"'/' ./resources/cart/manual.txt

echo "Writing the current year to all license places..."
sed -i "s/\(Copyright (c) \)[0-9]\{4\}/\1$(date +%Y)/" LICENSE.txt
sed -i "s/\(Copyright (c) \)[0-9]\{4\}/\1$(date +%Y)/" README.md
sed -i "s/\(copyright (c) \)[0-9]\{4\}/\1$(date +%Y)/" void_merchants.p8

echo "Splitting files from void_merchants.p8..."
./split.sh void_merchants.p8

# Check if 7z is working. Exit if test fails. very important for the LICENSE.txt
if ! "$_7Z_EXE" > /dev/null 2>&1; then
    echo "7z appears to no work. Exit script"
    exit
fi

# pico-8 -export seems to not always overwrite these exported files
rm ./resources/cart/void-merchants.p8.png
rm ./docs/index.html
rm ./docs/index.js
rm -rf ./resources/cart/void-merchants.bin/

# generate html+js files and the .p8.png cartridge
"$PICO8_EXE" void_merchants.p8 -export ./resources/cart/void-merchants.p8.png
"$PICO8_EXE" void_merchants.p8 -export ./docs/index.html
"$PICO8_EXE" void_merchants.p8 -export "-i 232 -s 2 -c 15  -e ./resources/cart/manual.txt ./resources/cart/void-merchants.bin"

# Not using * wildcard just to be safe and to not delete something important
echo "remove unnecessarily created non-zipped binary files..."
rm -r ./resources/cart/void-merchants.bin/linux/
rm -r ./resources/cart/void-merchants.bin/raspi/
rm -r ./resources/cart/void-merchants.bin/void-merchants.app/
rm -r ./resources/cart/void-merchants.bin/windows/

# Add the LICENSE.txt to the ZIP files
for file in ./resources/cart/void-merchants.bin/void-merchants_*.zip; do
  "$_7Z_EXE" a -tzip "$file" ./LICENSE.TXT
done

git add --all
git commit -m "$VERSION: prepare release"
git tag "$VERSION"
git push origin "$VERSION"

printf "\nRelease done."
