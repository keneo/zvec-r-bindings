library(rszvec)
rszvec_install()

col <- rszvec_open("/tmp/test_col", dim = 4)
rszvec_add(col, "a", c(1, 0, 0, 0))
rszvec_add(col, "b", c(0, 1, 0, 0))

res <- rszvec_search(col, c(1, 0, 0, 0), n = 5)
print(res)
stopifnot(res$id[1] == "a", nrow(res) == 2)

rszvec_delete(col, "b")
res2 <- rszvec_search(col, c(1, 0, 0, 0), n = 5)
stopifnot(!"b" %in% res2$id)

cat("PASS\n")
