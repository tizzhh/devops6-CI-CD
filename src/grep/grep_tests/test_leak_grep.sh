#!/bin/bash

SUCCESS=0
FAIL=0
COUNTER=0

tests=(
"s test_text_grep.txt VAR"
"for s21_grep.c s21_grep.h Makefile VAR"
"for s21_grep.c VAR"
"-e for -e ^int s21_grep.c s21_grep.h Makefile VAR"
"-e for -e ^int s21_grep.c VAR"
"-e regex -e ^print s21_grep.c VAR -f test_ptrn_grep.txt"
"-e while -e void s21_grep.c Makefile VAR -f test_ptrn_grep.txt"
"VAR no_file.txt"
)

extra=(
"-n for test_1_grep.txt test_2_grep.txt"
"-n for test_1_grep.txt"
"-n -e ^\} test_1_grep.txt"
"-c -e /\ test_1_grep.txt"
"-ce ^int test_1_grep.txt test_2_grep.txt"
"-e ^int test_1_grep.txt"
"-nivh = test_1_grep.txt test_2_grep.txt"
"-e"
"-ie INT test_5_grep.txt"
"-echar test_1_grep.txt test_2_grep.txt"
"-ne = -e out test_5_grep.txt"
"-iv int test_5_grep.txt"
"-in int test_5_grep.txt"
"-c -l aboba test_1.txt test_5_grep.txt"
"-v test_1_grep.txt -e ank"
"-noe ) test_5_grep.txt"
"-l for test_1_grep.txt test_2_grep.txt"
"-o -e int test_4_grep.txt"
"-e = -e out test_5_grep.txt"
"-noe ing -e as -e the -e not -e is test_6_grep.txt"
"-e ing -e as -e the -e not -e is test_6_grep.txt"
"-c -e . test_1_grep.txt -e '.'"
"-l for no_file.txt test_2_grep.txt"
"-f test_3_grep.txt test_5_grep.txt"
)

options=(
    "v"
    "c"
    "l"
    "n"
    "h"
    "o"
)

testing()
{
    t=$(echo $@ | sed "s/VAR/$var/")
    
    valgrind_result=0

    if command -v valgrind >/dev/null
    then
        valgrind --tool=memcheck --leak-check=yes --error-exitcode=1 ./../s21_grep $t >/dev/null 2>&1
        valgrind_result=$?
    elif command -v leaks >/dev/null
    then
       leaks -atExit -- ./../s21_grep $t >/dev/null 2>&1
       valgrind_result=$?
    fi

    if [ $valgrind_result -ne 0 ]
    then
        (( FAIL++ ))
        echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[31mfail\033[0m grep $t"
    else
        (( SUCCESS++ ))
        echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[32msuccess\033[0m grep $t"
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

echo "\033[31mFAIL: $FAIL\033[0m"
echo "\033[32mSUCCESS: $SUCCESS\033[0m"
echo "ALL: $COUNTER"
