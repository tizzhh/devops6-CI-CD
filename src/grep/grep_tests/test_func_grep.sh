#!/bin/bash

SUCCESS=0
FAIL=0
COUNTER=0

tests=(
"s test_0_grep.txt VAR"
)

options=(
    "v"
    "c"
    "l"
    "n"
    "h"
    "o"
)

extra=(
"-n for test_1_grep.txt test_2_grep.txt"
"-n for test_1_grep.txt"
"-n -e ^\} test_1_grep.txt"
"-ce ^int test_1_grep.txt test_2_grep.txt"
"-e ^int test_1_grep.txt"
"-nivh = test_1_grep.txt test_2_grep.txt"
"-e"
"-ie INT test_5_grep.txt"
"-echar test_1_grep.txt test_2_grep.txt"
"-ne = -e out test_5_grep.txt"
"-iv int test_5_grep.txt"
"-in int test_5_grep.txt"
"-c -l aboba test_1_grep.txt test_5_grep.txt"
"-v test_1_grep.txt -e ank"
"-ne ) test_5_grep.txt"
"-l for test_1_grep.txt test_2_grep.txt"
"-e int test_4_grep.txt"
"-e = -e out test_5_grep.txt"
"-ne ing -e as -e the -e not -e is test_6_grep.txt"
"-e ing -e as -e the -e not -e is test_6_grep.txt"
)

testing()
{
    t=$(echo $@ | sed "s/VAR/$var/")
    s21_grep=$(./../s21_grep $t)
    linux_grep=$(grep $t)
    (( COUNTER++ ))
    if [ "$s21_grep" == "$linux_grep" ]
    then
      (( SUCCESS++ ))
      echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[32msuccess\033[0m grep $t"
    else
      (( FAIL++ ))
      echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[31mfail\033[0m grep $t"
    fi
}

# специфические тесты
for i in "${extra[@]}"
do
    var="-"
    testing $i
done

# 1 параметр
for var1 in "${options[@]}"
do
    for i in "${tests[@]}"
    do
        var="-$var1"
        testing $i
    done
done

# 2 параметра
for var1 in "${options[@]}"
do
    for var2 in "${options[@]}"
    do
        if [ $var1 != $var2 ]
        then
            for i in "${tests[@]}"
            do
                var="-$var1 -$var2"
                testing $i
            done
        fi
    done
done

# 3 параметра
for var1 in "${options[@]}"
do
    for var2 in "${options[@]}"
    do
        for var3 in "${options[@]}"
        do
            if [ $var1 != $var2 ] && [ $var2 != $var3 ] && [ $var1 != $var3 ]
            then
                for i in "${tests[@]}"
                do
                    var="-$var1 -$var2 -$var3"
                    testing $i
                done
            fi
        done
    done
done

# 2 сдвоенных параметра
for var1 in "${options[@]}"
do
    for var2 in "${options[@]}"
    do
        if [ $var1 != $var2 ]
        then
            for i in "${tests[@]}"
            do
                var="-$var1$var2"
                testing $i
            done
        fi
    done
done

# 3 строенных параметра
for var1 in "${options[@]}"
do
    for var2 in "${options[@]}"
    do
        for var3 in "${options[@]}"
        do
            if [ $var1 != $var2 ] && [ $var2 != $var3 ] && [ $var1 != $var3 ]
            then
                for i in "${tests[@]}"
                do
                    var="-$var1$var2$var3"
                    testing $i
                done
            fi
        done
    done
done

echo -e "\033[31mFAIL: $FAIL\033[0m"
echo -e "\033[32mSUCCESS: $SUCCESS\033[0m"
echo "ALL: $COUNTER"
