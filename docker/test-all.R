cat("Installing testthat, rzvec and rszvec from /repo...\n")
install.packages("testthat", repos = "https://cloud.r-project.org", quiet = TRUE)
remotes::install_local("/repo/rzvec",  quiet = TRUE, upgrade = "never")
remotes::install_local("/repo/rszvec", quiet = TRUE, upgrade = "never")

library(rszvec)
rszvec_install()

cat("\n=== rzvec (", as.character(packageVersion("rzvec")), ") ===\n", sep = "")
rzvec_res <- testthat::test_dir("/repo/rzvec/tests/testthat",  reporter = "progress")

cat("\n=== rszvec (", as.character(packageVersion("rszvec")), ") ===\n", sep = "")
rszvec_res <- testthat::test_dir("/repo/rszvec/tests/testthat", reporter = "progress")

failed <- sum(as.data.frame(rzvec_res)$failed) + sum(as.data.frame(rszvec_res)$failed)
if (failed > 0) quit(status = 1)
