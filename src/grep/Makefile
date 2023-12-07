CFLAGS=-Wall -Werror -Wextra -pedantic -std=c11

all: s21_grep

s21_grep: s21_grep.c
	gcc $(CFLAGS) $^ -o s21_grep

style_check:
	cp ./../../materials/linters/.clang-format .clang-format
	clang-format -n --Werror s21_grep.*

clean:
	rm -rf s21_grep

rebuild: clean all