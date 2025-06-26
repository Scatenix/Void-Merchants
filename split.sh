#!/bin/bash

# If true, the ./game directoy will be completely deleted to avoid having old unsued files
ALWAYS_CLEAR_GAME_DIR=true

if [ $# -ne 1 ]; then
    echo "False usage of Script:"
    echo "args: [file.p8]"
    echo ""
    exit
fi
if [ ! -f "$1" ]; then
    echo "'$1' does not exists."
    echo ""
    exit
fi
if [[ ! $1 = *.p8 ]]; then
    echo "Supplied file must be a .p8 file"
    echo ""
    exit
fi

if [ $ALWAYS_CLEAR_GAME_DIR == true ]; then
    echo "Deleting and regernaring the game directory"
    rm -r ./game
fi

if [ ! -d game ]; then
    mkdir game
fi

time(
# Split all the binary resources into the pico8_binary.resources file (sprites, sfx, ...)
    csplit --digits=1 -z -s --prefix=./game/pico8_binary.resources "$1" "/__gfx__/"
    cd game || exit
    mv pico8_binary.resources1 pico8_binary.resources
    sed -i '1s;^;__resources__\n;' pico8_binary.resources

    csplit --digits=1 -z -s --prefix=./pico8_code pico8_binary.resources0 "/__lua__/+1"

    mv pico8_code0 pico8.meta
    sed -i '1s;^;__meta__\n;' pico8.meta

    csplit --digits=4 -z -s --prefix=temp_p8_splitted pico8_code1 "/-->8/+1" "{*}"

    rm pico8_binary.resources0
    rm pico8_code1
    number=0
    for i in temp_p8_splitted*; do
        [ -f "$i" ] || break
        ((number++))
        sed -i '/./,$!d' "$i"
        first_line=$(head -n 1 "$i")
        file_name_space=${first_line:2:${#first_line}}
        file_name_trim=$(echo $file_name_space)
        file_name_us=${file_name_trim// /_}
        sed '1 s/^/__lua__'$number'\n/' "$i" > "$file_name_us.p8"
        rm "$i"
        echo "$i --> $file_name_us"
    done
)