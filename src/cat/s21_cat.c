#include "s21_cat.h"

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void parser(int argc, char **argv, opt *options);
void reader(char **argv, opt *options);

int main(int argc, char **argv) {
  if (argc >= 1) {
    opt options = {0};
    parser(argc, argv, &options);
    while (argc > optind) {
      reader(argv, &options);
      optind++;
    }
  } else {
    printf("empty");
  }
  return 0;
}

void parser(int argc, char **argv, opt *options) {
  int opt;

  struct option longOptions[] = {{"number", 0, 0, 'n'},
                                 {"squeeze", 0, 0, 's'},
                                 {"number-nonblank", 0, 0, 'b'},
                                 {0, 0, 0, 0}};
  int options_index;
  while ((opt = getopt_long(argc, argv, "benstvTE", longOptions,
                            &options_index)) != -1) {
    switch (opt) {
      case 'b':
        options->b = 1;
        break;
      case 'e':
        options->e = 1;
        options->v = 1;
        break;
      case 'n':
        options->n = 1;
        break;
      case 's':
        options->s = 1;
        break;
      case 't':
        options->t = 1;
        options->v = 1;
        break;
      case 'E':
        options->e = 1;
        break;
      case 'T':
        options->t = 1;
        break;
      case 'v':
        options->v = 1;
        break;
      default:
        printf("Error");
        exit(1);
    }
    if (options->b && options->n) {
      options->n = 0;
    }
  }
}

void reader(char **argv, opt *options) {
  FILE *f;
  f = fopen(argv[optind], "r");
  if (f != NULL) {
    int str_count = 1;
    int empty_str = 0;
    int symbol = '\n';
    while (!feof(f)) {
      int c = fgetc(f);
      if (c == EOF) break;
      if (options->s) {
        if (c == '\n' && symbol == '\n') {
          empty_str++;
          if (empty_str > 1) continue;
        } else {
          empty_str = 0;
        }
      }
      if (options->n) {
        if (symbol == '\n') printf("%6d\t", str_count++);
      }

      if (options->b) {
        if (symbol == '\n' && c != '\n') printf("%6d\t", str_count++);
      }
      if (options->t && c == '\t') {
        printf("^");
        c = 'I';
      }
      if (options->e && c == '\n') {
        printf("$");
      }
      if (options->v) {
        if ((c >= 0 && c < 9) || (c > 10 && c < 32) || (c > 126 && c <= 160)) {
          printf("^");
          if (c > 126) {
            c -= 64;
          } else {
            c += 64;
          }
        }
      }
      printf("%c", c);
      symbol = c;
    }
    fclose(f);
  } else {
    fprintf(stderr, "%s: No such file or directory\n", argv[optind]);
  }
}