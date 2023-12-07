#!/bin/bash

SUCCESS=0
FAIL=0
COUNTER=0

tests="VAR test_case_cat.txt"

extra=(
"-s test_1_cat.txt"
"-b -e -n -s -t test_1_cat.txt"
"-t test_3_cat.txt"
"-n test_2_cat.txt"
"-n -b test_1_cat.txt"
"-s -n -e test_4_cat.txt"
"-n test_1_cat.txt"
"-n test_1_cat.txt"
"-n test_1_cat.txt test_2_cat.txt"
)

options=(
    "b"
    "e"
    "n"
    "s"
    "t"
)

testing()
{
    t=$(echo $@ | sed "s/VAR/$var/")
    s21_cat=$(./../s21_cat $t)
    linux_cat=$(cat $t)
    (( COUNTER++ ))
    if [ "$s21_cat" == "$linux_cat" ]
    then
      (( SUCCESS++ ))
        echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[32msuccess\033[0m cat $t"
    else
      (( FAIL++ ))
        echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[31mfail\033[0m cat $t"
    fi
}

for i in "${extra[@]}"
do
    var="-"
    testing $i
done

for var1 in "${options[@]}"
do
    var="-$var1"
    testing $tests
done

for var1 in "${options[@]}"
do
    for var2 in "${options[@]}"
    do
        if [ $var1 != $var2 ]
        then
            var="-$var1 -$var2"
            testing $tests
        fi
    done
done

for var1 in "${options[@]}"
do
    for var2 in "${options[@]}"
    do
        for var3 in "${options[@]}"
        do
            if [ $var1 != $var2 ] && [ $var2 != $var3 ] && [ $var1 != $var3 ]
            then
                var="-$var1 -$var2 -$var3"
                testing $tests
            fi
        done
    done
done

for var1 in "${options[@]}"
do
    for var2 in "${options[@]}"
    do
        for var3 in "${options[@]}"
        do
            for var4 in "${options[@]}"
            do
                if [ $var1 != $var2 ] && [ $var2 != $var3 ] \
                && [ $var1 != $var3 ] && [ $var1 != $var4 ] \
                && [ $var2 != $var4 ] && [ $var3 != $var4 ]
                then
                    var="-$var1 -$var2 -$var3 -$var4"
                    testing $tests
                fi
            done
        done
    done
done

echo -e "\033[31mFAIL: $FAIL\033[0m"
echo -e "\033[32mSUCCESS: $SUCCESS\033[0m"
echo -e "ALL: $COUNTER"
