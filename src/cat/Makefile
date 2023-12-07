CFLAGS=-Wall -Werror -Wextra -pedantic -std=c11

all: s21_cat

s21_cat: s21_cat.c
	gcc $(CFLAGS) $^ -o s21_cat

clean:
	rm -rf s21_cat

rebuild: clean all