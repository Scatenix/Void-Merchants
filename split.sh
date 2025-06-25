#!/bin/bash

# does currently not split correctly

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
if [ ! -d game ]
then
    mkdir game
fi

csplit --digits=7 -z -s --prefix=./game/pico8_info void_merchants.p8 "/__lua__/+1"

cd game
mv pico8_info*0 pico8.info

csplit --digits=4 -z -s --prefix=temp_p8_splitted pico8_info*1 "/-->8/+1" "{*}"

rm pico8_info*1
number=0
for i in temp_p8_splitted*; do
    [ -f "$i" ] || break
    ((number++))
    first_line=$(head -n 1 $i)
    file_name_space=${first_line:2:${#first_line}}
    file_name_trim=$(echo $file_name_space)
    file_name_us=${file_name_trim// /_}
    sed '1 s/^/__lua__'$number'\n/' $i > "$file_name_us.p8"
    rm $i
    echo "$i --> $file_name_us"
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
if [ ! -d game ]
then
    mkdir game
fi

csplit --digits=7 -z -s --prefix=./game/pico8_info void_merchants.p8 "/__lua__/+1"

cd game
mv pico8_info*0 pico8.info

csplit --digits=4 -z -s --prefix=temp_p8_splitted pico8_info*1 "/-->8/+1" "{*}"

rm pico8_info*1
number=0
for i in temp_p8_splitted*; do
    [ -f "$i" ] || break
    ((number++))
    first_line=$(head -n 1 $i)
    file_name_space=${first_line:2:${#first_line}}
    file_name_trim=$(echo $file_name_space)
    file_name_us=${file_name_trim// /_}
    sed '1 s/^/__lua__'$number'\n/' $i > "$file_name_us.p8"
    rm $i
    echo "$i --> $file_name_us"
done
)