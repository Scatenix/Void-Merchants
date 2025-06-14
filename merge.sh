#!/bin/bash

# seems to be broken, does not finish execution.

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

time(
echo "merging ./games into $1"

#steps:
#get list of ordered files by number at __lua__<number>
#write them in one big file --> name = script argument 1

# use nullglob in case there are no matching files
shopt -s nullglob

# create an array with all the filer/dir inside ~/myDir
files=(./game/*.p8)

ordered_files=()
ordered_files+=('./game/pico8.info')
counter=1

# order list with __lua__number
while [ ! ${#ordered_files[@]} -gt ${#files[@]} ]; do
for ((i=0; i<${#files[@]}; i++)); do
first_line=$(head -n 1 ${files[$i]})
number=${first_line:7:${#first_line}}
if [[ ${first_line:7:${#first_line}} == $counter ]]; then
ordered_files+=(${files[$i]})
((counter++))
fi
done
done

rm $1

cat ${ordered_files[0]} >> $1

for ((i=1; i<${#ordered_files[@]}; i++)); do
    echo ${ordered_files[$i]}
    tail -n +2 "${ordered_files[$i]}" > "${ordered_files[$i]}.tmp"
    cat "${ordered_files[$i]}.tmp" >> "$1"
    rm ${ordered_files[$i]}.tmp
done
)#!/bin/bash

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

time(
echo "merging ./games into $1"

#steps:
#get list of ordered files by number at __lua__<number>
#write them in one big file --> name = script argument 1

# use nullglob in case there are no matching files
shopt -s nullglob

# create an array with all the filer/dir inside ~/myDir
files=(./game/*.p8)

ordered_files=()
ordered_files+=('./game/pico8.info')
counter=1

# order list with __lua__number
while [ ! ${#ordered_files[@]} -gt ${#files[@]} ]; do
for ((i=0; i<${#files[@]}; i++)); do
first_line=$(head -n 1 ${files[$i]})
number=${first_line:7:${#first_line}}
if [[ ${first_line:7:${#first_line}} == $counter ]]; then
ordered_files+=(${files[$i]})
((counter++))
fi
done
done

rm $1

cat ${ordered_files[0]} >> $1

for ((i=1; i<${#ordered_files[@]}; i++)); do
    echo ${ordered_files[$i]}
    tail -n +2 "${ordered_files[$i]}" > "${ordered_files[$i]}.tmp"
    cat "${ordered_files[$i]}.tmp" >> "$1"
    rm ${ordered_files[$i]}.tmp
done
)