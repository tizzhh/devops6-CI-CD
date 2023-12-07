#!/bin/bash

CHARACTERS=("b" "e" "n" "s" "t" "v")
SEQUENCES=("${CHARACTERS[@]}")

FUNCTIONAL_TESTS_SUCCESS=0
FUNCTIONAL_TESTS_FAILED=0
FUNCTIONAL_TESTS_TOTAL=0
FUNCTIONAL_FILES_TOTAL=0

MEMORY_TESTS_SUCCESS=0
MEMORY_TESTS_FAILED=0
MEMORY_TESTS_TOTAL=0
MEMORY_FILES_TOTAL=0

MEMORY_CHECKER_APP="not found"
MEMORY_CHECKER_APP_ARGS="not setted"

CAT_BIN="cat"
S21_CAT_BIN="../s21_cat"
ASSETS_FOLDER="*.txt"

log() {
  echo -e "[$(date '+%H:%M:%S')] $1"
}

measure_time() {
  start_time=$(ruby -e 'puts Time.now.to_f')
  "$@"
  end_time=$(ruby -e 'puts Time.now.to_f')
  elapsed_time=$(echo "$end_time - $start_time" | bc)

  log "***********************"
  log "Elapsed: $elapsed_time sec"
  log "***********************"
  log ""
}

generate_sequences() {
  for ((i = 0; i < ${#CHARACTERS[@]}; i++)); do
    temp_array=()

    for element in "${SEQUENCES[@]}"; do
      for char in "${CHARACTERS[@]}"; do
        if [[ $element == *"$char"* ]]; then
          continue
        fi

        new_element="${element}${char}"
        sorted_element=$(echo "${new_element}" | grep -o . | sort | tr -d '\n')

        if ! [[ " ${temp_array[*]} " =~ ${sorted_element} ]] && ! [[ " ${SEQUENCES[*]} " =~ ${sorted_element} ]]; then
          temp_array+=("${sorted_element}")
        fi
      done
    done

    SEQUENCES+=("${temp_array[@]}")
  done

  log "Generated ${#SEQUENCES[*]} flag sequences: ${SEQUENCES[*]}"
  log ""
}

run_functional_tests() {
  for file in $ASSETS_FOLDER; do
    FUNCTIONAL_FILES_TOTAL=$((FUNCTIONAL_FILES_TOTAL + 1))
    local subtest_counter=1
    log "*** File #$FUNCTIONAL_FILES_TOTAL: $file ***"

    for flags in "${SEQUENCES[@]}"; do
      cat_output=$($CAT_BIN "-$flags" "$file")
      s21_cat_output=$($S21_CAT_BIN "-$flags" "$file")

      if [[ "$cat_output" == "$s21_cat_output" ]]; then
        log "- Test: $FUNCTIONAL_FILES_TOTAL.$subtest_counter\t/ File: $file\t/ Flags: $flags\t/ Status: Success"
        FUNCTIONAL_TESTS_SUCCESS=$((FUNCTIONAL_TESTS_SUCCESS + 1))
      else
        log "- Test: $FUNCTIONAL_FILES_TOTAL.$subtest_counter\t/ File: $file\t/ Flags: $flags\t/ Status: Failed"
        FUNCTIONAL_TESTS_FAILED=$((FUNCTIONAL_TESTS_FAILED + 1))
      fi

      FUNCTIONAL_TESTS_TOTAL=$((FUNCTIONAL_TESTS_TOTAL + 1))
      subtest_counter=$((subtest_counter + 1))
    done

    log ""
  done
}

run_memory_tests() {
  test_counter=1

  if command -v valgrind &>/dev/null; then
    MEMORY_CHECKER_APP="valgrind"
    MEMORY_CHECKER_APP_ARGS="--tool=memcheck --leak-check=yes --error-exitcode=1"
  elif command -v leaks &>/dev/null; then
    MEMORY_CHECKER_APP="leaks"
    MEMORY_CHECKER_APP_ARGS="-atExit --"
  else
    log "ERROR: Memory leak checker not found. Aborting memory tests check."
    return
  fi

  for file in $ASSETS_FOLDER; do
    MEMORY_FILES_TOTAL=$((MEMORY_FILES_TOTAL + 1))
    local subtest_counter=1
    log "MemoryTest: #$test_counter, File: $file"

    for flags in "${SEQUENCES[@]}"; do
      if $MEMORY_CHECKER_APP $MEMORY_CHECKER_APP_ARGS ../s21_cat "$file" $flags >/dev/null 2>&1; then
        log "- Test: $MEMORY_FILES_TOTAL.$subtest_counter\t/ File: $file\t/ Flags: $flags\t/ Status: No memory problems"
        MEMORY_TESTS_SUCCESS=$((MEMORY_TESTS_SUCCESS + 1))
      else
        log "- Test: $MEMORY_FILES_TOTAL.$subtest_counter\t/ File: $file\t/ Flags: $flags\t/ Status: Memory problems detected"
        MEMORY_TESTS_FAILED=$((MEMORY_TESTS_FAILED + 1))
      fi

      subtest_counter=$((subtest_counter + 1))
      MEMORY_TESTS_TOTAL=$((MEMORY_TESTS_TOTAL + 1))
    done

    test_counter=$((test_counter + 1))
    log ""
  done
}

print_summary() {
  log "***********************"
  log "** General:"
  log "Flags:\t${#SEQUENCES[@]}"
  log "Files:\t$FUNCTIONAL_FILES_TOTAL"
  log ""
  log "** Functional Tests:"
  log "S/F/T:\t$FUNCTIONAL_TESTS_SUCCESS/$FUNCTIONAL_TESTS_FAILED/$FUNCTIONAL_TESTS_TOTAL"
  log "Percent:\t$((FUNCTIONAL_TESTS_SUCCESS * 100 / FUNCTIONAL_TESTS_TOTAL))%"
  log ""
  log "** Memory Tests:"
  log "Checker:\t$MEMORY_CHECKER_APP"
  log "Options:\t$MEMORY_CHECKER_APP_ARGS"
  log "S/F/T:\t$MEMORY_TESTS_SUCCESS/$MEMORY_TESTS_FAILED/$MEMORY_TESTS_TOTAL"
  log "Percent:\t$((MEMORY_TESTS_SUCCESS * 100 / MEMORY_TESTS_TOTAL))%"
  log "***********************"
}

main() {
  log "Functional and memory tests for s21_cat by @ireliabe"
  log "Flags: ${CHARACTERS[*]}"
  log ""

  log "Stage #0 // Generating unique sequences of flags"
  measure_time generate_sequences

  log "Stage #1 // Functional tests"
  measure_time run_functional_tests

  log "Stage #2 // Memory tests"
  run_memory_tests

  print_summary
}

measure_time main

exit 0
