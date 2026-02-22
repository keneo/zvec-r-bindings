# R deps already in image — just install local packages (fast, no dep download)
cat("Installing rzvec and rszvec from /repo...\n")
remotes::install_local("/repo/rzvec",  quick = TRUE, upgrade = "never", quiet = TRUE)
remotes::install_local("/repo/rszvec", quick = TRUE, upgrade = "never", quiet = TRUE)

# Python venv pre-built in image — rszvec_install() detects it and skips
library(rszvec)
rszvec_install()

cat("\n=== rzvec (", as.character(packageVersion("rzvec")), ") ===\n", sep = "")
rzvec_res <- testthat::test_dir("/repo/rzvec/tests/testthat",  reporter = "progress")

cat("\n=== rszvec (", as.character(packageVersion("rszvec")), ") ===\n", sep = "")
rszvec_res <- testthat::test_dir("/repo/rszvec/tests/testthat", reporter = "progress")

failed <- sum(as.data.frame(rzvec_res)$failed) + sum(as.data.frame(rszvec_res)$failed)
if (failed > 0) quit(status = 1)
