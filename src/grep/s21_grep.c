#include "s21_grep.h"

int main(int argc, char** argv) {
  if (argc > 2) {
    opt options = {0};
    parser(argc, argv, &options);

    // printf("[DEBUG] Pattern: %s\n", options.pattern);
    // exit(1);

    grep(argc, argv, options);
  } else {
    fprintf(stderr, "Usage: [-eivclnhsfo][FILE]\n");
  }
  return 0;
}

void printer_for_n(int match, opt options, char* filename, int size,
                   int linecount, char* str) {
  if (match) {
    if (!options.l && !options.c) {
      if (size > 1 && !options.h) {
        printf("%s:", filename);
      }
      if (options.n) {
        printf("%d:", linecount);
      }
      printf("%s", str);
    }
  }
}

void printer(opt options, char* filename, int overlapcount, int size) {
  if (options.l && overlapcount != 0) overlapcount = 1;
  if (options.c) {
    if (size > 1 && !options.h) {
      printf("%s:%d\n", filename, overlapcount);
    } else {
      printf("%d\n", overlapcount);
    }
  }
  if (options.l && overlapcount) {
    printf("%s\n", filename);
  }
}

void parser(const int argc, char** argv, opt* options) {
  int opt;
  const struct option long_options[] = {{NULL, 0, NULL, 0}};
  while ((opt = getopt_long(argc, argv, "e:ivclnhsf:o", long_options, NULL)) !=
         -1) {
    if (opt == 'e') {
      if (!options->e && !options->f) {
        strcpy(options->pattern, optarg);
      } else {
        strcat(options->pattern, "|");
        strcat(options->pattern, optarg);
      }
      options->e = 1;
    } else if (opt == 'i')
      options->i = 1;
    else if (opt == 'v')
      options->v = 1;
    else if (opt == 'c')
      options->c = 1;
    else if (opt == 'l')
      options->l = 1;
    else if (opt == 'n')
      options->n = 1;
    else if (opt == 'h')
      options->h = 1;
    else if (opt == 's')
      options->s = 1;
    else if (opt == 'o')
      options->o = 1;
    else if (opt == 'f') {
      options->f = 1;
      strncpy(options->file_pattern, optarg, 255);
      addPatternFromFile(options);
    } else {
      fprintf(stderr, "Usage: [-eivclnhsfo][FILE]\n");
      exit(1);
    }
  }
}

void addPatternFromFile(opt* options) {
  FILE* file = fopen(options->file_pattern, "r");
  int pos = strlen(options->pattern);
  if (options->e && options->pattern[pos] != '|') {
    options->pattern[pos++] = '|';
  }
  char prev = 0;
  if (file != NULL) {
    char ch;
    while ((ch = fgetc(file)) != EOF) {
      if (ch == '\n' && prev != '\n') {
        options->pattern[pos++] = '|';
      } else if (ch != '\n') {
        options->pattern[pos++] = ch;
      }
      prev = ch;
    }

    if (options->pattern[pos - 1] == '|') {
      options->pattern[pos - 1] = '\0';
    }
    fclose(file);
  } else {
    if (!options->s) printf("Error, %s doesn't exist\n", options->file_pattern);
  }
}

void grep(int argc, char** argv, opt options) {
  regex_t regex;
  options.reg_flags = options.i ? REG_ICASE | REG_EXTENDED : REG_EXTENDED;
  int temp = 0;
  if (options.e || options.f) {
    temp = regcomp(&regex, options.pattern, options.reg_flags);
  } else {
    temp = regcomp(&regex, argv[optind], options.reg_flags);
  }
  if (temp) {
    printf("Error\n");
    exit(1);
  }
  char str[2048];
  int linecount;
  int overlapcount;
  int size = fileCounter(argc, options);
  for (int i = 0; i < size; i++) {
    linecount = 0;
    overlapcount = 0;
    FILE* file = fopen(argv[optind + i + 1], "r");
    if (file != NULL) {
      while (fgets(str, 2048, file) != NULL) {
        linecount++;
        int match = !regexec(&regex, str, 0, NULL, 0);
        flags_processing(&match, &options, &overlapcount);
        if (options.o && match) {
          optionO(size, options, argv[optind + i + 1], str, linecount, &regex);
        } else {
          printer_for_n(match, options, argv[optind + i + 1], size, linecount,
                        str);
        }
      }
      printer(options, argv[optind + i + 1], overlapcount, size);
      fclose(file);
    } else {
      if (!options.s)
        printf("Error, file \"%s\" doesn't exist\n", argv[optind + i + 1]);
    }
  }
  regfree(&regex);
}

int fileCounter(int argc, opt options) {
  int size = 0;
  if (options.e || options.f) optind--;
  for (int i = optind + 1; i < argc; i++) {
    size++;
  }
  return size;
}

void flags_processing(int* match, opt* options, int* overlapcount) {
  if (options->v) {
    *match = !*match;
    options->o = 0;
  }

  if (options->c) {
    options->o = options->n = 0;
  }
  if (options->l) options->o = 0;

  if (*match) {
    *overlapcount = *overlapcount + 1;
  }
}

void optionO(int size, opt options, char* filename, char str[], int linecount,
             regex_t* regex) {
  regmatch_t reegm = {0};
  int flag_for_print_o = 0;
  if (size > 1 && !options.h) {
    printf("%s:", filename);
  }
  char* ptr = str;
  while (!regexec(regex, ptr, 1, &reegm, 0)) {
    if (options.n && !flag_for_print_o) {
      printf("%d:", linecount);
      flag_for_print_o = 1;
    }
    for (int j = reegm.rm_so; j < reegm.rm_eo; ++j) {
      putchar(ptr[j]);
    }
    ptr += reegm.rm_eo;
    putchar('\n');
  }
}