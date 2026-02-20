#!/bin/bash
set -e
cd "$(dirname "$0")"

Rscript -e "
  cat('=== rzvec (', as.character(packageVersion('rzvec')), ') ===\n', sep = '')
  rzvec_res <- testthat::test_dir('rzvec/tests/testthat', reporter = 'progress')

  cat('\n=== rszvec (', as.character(packageVersion('rszvec')), ') ===\n', sep = '')
  rszvec_res <- testthat::test_dir('rszvec/tests/testthat', reporter = 'progress')

  failed <- sum(as.data.frame(rzvec_res)\$failed) + sum(as.data.frame(rszvec_res)\$failed)
  if (failed > 0) quit(status = 1)
"
