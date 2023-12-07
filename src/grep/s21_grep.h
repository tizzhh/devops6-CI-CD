#include <getopt.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct options {
  int e;
  int i;
  int v;
  int c;
  int l;
  int n;
  int h;
  int s;
  int f;
  int o;
  int reg_flags;
  char pattern[10000];
  char file_pattern[256];
} opt;

int fileCounter(int argc, opt options);
void addPatternFromFile(opt* options);
void parser(int argc, char** argv, opt* options);
char* readStringFromFile(FILE* file, int* ifEOF);
void grep(int argc, char** argv, opt options);
void rungrep(int argc, char** argv);
void flags_processing(int* match, opt* options, int* overlapcount);
void optionO(int size, opt options, char* filename, char str[], int linecount,
             regex_t* regex);
void printer_for_n(int match, opt options, char* filename, int size,
                   int linecount, char* str);
void printer(opt options, char* filename, int overlapcount, int size);