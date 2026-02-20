# --- rszvec_open ---------------------------------------------------------------

test_that("rszvec_open() creates a new collection when path absent", {
  skip_if_no_zvec()
  dir <- zvec_tempdir()
  col <- rszvec_open(dir, dim = 4)
  expect_s3_class(col, "python.builtin.object")
  expect_true(dir.exists(dir))
})

test_that("rszvec_open() reopens an existing collection", {
  skip_if_no_zvec()
  dir <- zvec_tempdir()
  col1 <- rszvec_open(dir, dim = 4)
  rm(col1); gc()
  reticulate::py_run_string("import gc; gc.collect()")

  col2 <- rszvec_open(dir)
  expect_s3_class(col2, "python.builtin.object")
})

test_that("rszvec_open() errors when dim missing and path absent", {
  skip_if_no_zvec()
  dir <- zvec_tempdir()
  expect_error(rszvec_open(dir), "`dim` is required")
})

# --- rszvec_add / rszvec_search round-trip ------------------------------------

test_that("rszvec_add() and rszvec_search() round-trip", {
  skip_if_no_zvec()
  col <- new_temp_col()
  rszvec_add(col, "a", VEC_A)
  res <- rszvec_search(col, VEC_A, n = 5)
  expect_true("a" %in% res$id)
})

test_that("rszvec_search() returns a data.frame with id and score columns", {
  skip_if_no_zvec()
  col <- new_temp_col()
  rszvec_add(col, "x", VEC_A)
  res <- rszvec_search(col, VEC_A, n = 5)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("id", "score"))
  expect_type(res$id, "character")
  expect_type(res$score, "double")
})

test_that("rszvec_search() returns results in descending score order", {
  skip_if_no_zvec()
  col <- new_temp_col()
  rszvec_add(col, "near", VEC_A)   # dot(VEC_A, VEC_A) = 1
  rszvec_add(col, "far",  VEC_B)   # dot(VEC_B, VEC_A) = 0
  res <- rszvec_search(col, VEC_A, n = 10)
  expect_equal(res$id[[1]], "near")
  expect_gte(res$score[[1]], res$score[[2]])
})

test_that("rszvec_search() respects n", {
  skip_if_no_zvec()
  col <- new_temp_col()
  rszvec_add(col, "a", VEC_A)
  rszvec_add(col, "b", VEC_B)
  rszvec_add(col, "c", VEC_C)
  rszvec_add(col, "d", VEC_D)
  res <- rszvec_search(col, VEC_A, n = 2)
  expect_lte(nrow(res), 2L)
})

test_that("rszvec_search() returns empty data.frame when no results", {
  skip_if_no_zvec()
  col <- new_temp_col()
  res <- rszvec_search(col, VEC_A, n = 5)
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0L)
  expect_named(res, c("id", "score"))
})

# --- rszvec_add_many ----------------------------------------------------------

test_that("rszvec_add_many() works with a list of vectors", {
  skip_if_no_zvec()
  col <- new_temp_col()
  rszvec_add_many(col,
    ids     = c("a", "b"),
    vectors = list(VEC_A, VEC_B)
  )
  res <- rszvec_search(col, VEC_A, n = 10)
  expect_true("a" %in% res$id)
  expect_true("b" %in% res$id)
})

test_that("rszvec_add_many() works with a matrix (one row per doc)", {
  skip_if_no_zvec()
  col <- new_temp_col()
  mat <- rbind(VEC_A, VEC_B, VEC_C)
  rszvec_add_many(col, ids = c("a", "b", "c"), vectors = mat)
  res <- rszvec_search(col, VEC_A, n = 10)
  expect_true("a" %in% res$id)
  expect_true("b" %in% res$id)
  expect_true("c" %in% res$id)
})

test_that("rszvec_add_many() inserts all docs across a batch boundary (n > 1000)", {
  skip_if_no_zvec()
  n   <- 1001L
  col <- new_temp_col(dim = 4L)
  ids <- paste0("doc", seq_len(n))
  mat <- matrix(runif(n * 4L), nrow = n)
  rszvec_add_many(col, ids, mat)
  res <- rszvec_search(col, mat[1L, ], n = n)
  expect_equal(nrow(res), n)
})

test_that("rszvec_add_many() respects a custom batch_size", {
  skip_if_no_zvec()
  col <- new_temp_col(dim = 4L)
  rszvec_add_many(col,
    ids       = c("a", "b", "c"),
    vectors   = list(VEC_A, VEC_B, VEC_C),
    batch_size = 1L   # force one doc per insert call
  )
  res <- rszvec_search(col, VEC_A, n = 10)
  expect_setequal(res$id, c("a", "b", "c"))
})

test_that("rszvec_add_many() default batch_size is 1000", {
  expect_equal(formals(rszvec_add_many)$batch_size, 1000L)
})

# --- rszvec_delete ------------------------------------------------------------

test_that("rszvec_delete() removes doc from search results", {
  skip_if_no_zvec()
  col <- new_temp_col()
  rszvec_add(col, "keep",   VEC_A)
  rszvec_add(col, "remove", VEC_B)
  rszvec_delete(col, "remove")
  res <- rszvec_search(col, VEC_B, n = 10)
  expect_false("remove" %in% res$id)
})
