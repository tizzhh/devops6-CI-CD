#!/bin/bash

TARGET_USER="hewettja2"
TARGET_HOST="10.0.2.4"

scp src/cat/s21_cat $TARGET_USER@$TARGET_HOST:~/
scp src/grep/s21_grep $TARGET_USER@$TARGET_HOST:~/
ssh $TARGET_USER@$TARGET_HOST "echo "1234" | sudo -S mv s21_cat s21_grep /usr/local/bin"