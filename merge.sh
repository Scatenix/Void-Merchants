#!/bin/bash

# Very slow execution speed (~ 4 seconds on my machine, Git Bash for Windows)
# Consider a rewrite (maybe in Go)

if [ $# -ne 1 ]; then
    echo "False usage of Script:"
    echo "args: [file.p8]"
    echo ""
    exit
fi
if [ ! -f "$1" ]; then
    echo "'$1' does not exists. Creating..."
    touch "$1"
fi
if [[ ! $1 = *.p8 ]]; then
    echo "File must be a .p8 file. Renaming..."
    mv "$1" "$1.p8"
    set -- "$1.p8"
fi

time(
    echo "merging ./games into $1"

    # Steps:
    #   - get list of ordered files by number at __lua__<number>
    #   - Add pico8.meta at the first position
    #   - Add pico8_binary.resources at the last position
    #   - write them in one big file --> name = script argument 1

    # Use nullglob in case there are no matching files
    shopt -s nullglob

    # create an array with all the filer/dir inside ~/myDir
    files=(./game/*.p8)

    # Create ordered list of files and place the meta file on top
    ordered_files=()
    ordered_files+=('./game/pico8.meta')
    counter=1

    # Order list with __lua__number
    while [ ! ${#ordered_files[@]} -gt ${#files[@]} ]; do
        for ((i=0; i<${#files[@]}; i++)); do
            first_line=$(head -n 1 "${files[$i]}")
            #number=${first_line:7:${#first_line}}
            if [[ ${first_line:7:${#first_line}} == "$counter" ]]; then
                ordered_files+=("${files[$i]}")
                ((counter++))
            fi
        done
    done

    # Place the resources file at the bottom of all files
    ordered_files+=('./game/pico8_binary.resources')

    # Delete pico-8 cartrige to be newely created in the following for loop
    rm "$1"

    # Write all ordered files into the final pico8 cartrige
    for ((i=0; i<${#ordered_files[@]}; i++)); do
        echo "${ordered_files[$i]}"
        tail -n +2 "${ordered_files[$i]}" > "${ordered_files[$i]}.tmp"
        cat "${ordered_files[$i]}.tmp" >> "$1"
        rm "${ordered_files[$i]}.tmp"
    done
)