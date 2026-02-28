.pkg_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  .pkg_env$zvec <- reticulate::import("zvec", delay_load = TRUE)
}

.zv <- function() .pkg_env$zvec

#' Install zvec Python package
#'
#' Creates a virtualenv in the user cache directory and installs the `zvec`
#' Python package into it, then activates it for the current session.
#'
#' On Linux x86_64 without AVX-512, the AVX2-only beta (`zvec==0.2.1b0`) is
#' installed automatically. See
#' <https://github.com/alibaba/zvec/issues/185>.
#'
#' @param envname Name of the virtualenv to create. Defaults to `"rzvec-venv"`.
#' @param ... Additional arguments passed to [reticulate::py_install()].
#'
#' @return Invisibly `NULL`.
#' @export
rzvec_install <- function(envname = "rzvec-venv", ...) {
  pkg <- if (.linux_x86_without_avx512()) "zvec==0.2.1b0" else "zvec"

  venv_dir <- file.path(tools::R_user_dir("rzvec", "cache"), envname)
  reticulate::virtualenv_create(venv_dir)
  reticulate::py_install(pkg, envname = venv_dir, method = "virtualenv", ...)
  reticulate::use_virtualenv(venv_dir, required = TRUE)
  invisible(NULL)
}

.linux_x86_without_avx512 <- function() {
  si <- Sys.info()
  if (si[["sysname"]] != "Linux" || si[["machine"]] != "x86_64") return(FALSE)
  cpuinfo <- tryCatch(readLines("/proc/cpuinfo"), error = function(e) character(0))
  !any(grepl("avx512f", cpuinfo))
}
