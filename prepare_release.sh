#!/bin/bash

PICO8_EXE="/c/Program Files (x86)/PICO-8/pico8.exe"
_7Z_EXE="/c/Program Files/7-Zip/7z.exe"

# Check if 7z is working. Exit if test fails. very important for the LICENSE.txt
if ! "$_7Z_EXE" > /dev/null 2>&1; then
    echo "7z appears to no work. Exit script"
    exit
fi

# pico-8 -export seems to not always truly overwrite
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
