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
#' On Linux x86_64, the pre-built wheel requires AVX-512. Installation will
#' fail with a clear error on CPUs that lack it (AMD, older Intel). See
#' <https://github.com/alibaba/zvec/issues/128>.
#'
#' @param envname Name of the virtualenv to create. Defaults to `"rzvec-venv"`.
#' @param ... Additional arguments passed to [reticulate::py_install()].
#'
#' @return Invisibly `NULL`.
#' @export
rzvec_install <- function(envname = "rzvec-venv", ...) {
  # TODO: remove this check once https://github.com/alibaba/zvec/issues/128
  # is fixed and zvec ships a wheel that does not require AVX-512.
  if (.linux_x86_without_avx512()) {
    stop(
      "zvec is not supported on this CPU.\n",
      "The Linux x86_64 wheel requires AVX-512, which is not available here.\n",
      "Supported: Linux x86_64 with AVX-512 (Intel Skylake-SP+), Linux ARM64, macOS ARM64.\n",
      "See: https://github.com/alibaba/zvec/issues/128",
      call. = FALSE
    )
  }

  venv_dir <- file.path(tools::R_user_dir("rzvec", "cache"), envname)
  reticulate::virtualenv_create(venv_dir)
  reticulate::py_install("zvec", envname = venv_dir, method = "virtualenv", ...)
  reticulate::use_virtualenv(venv_dir, required = TRUE)
  invisible(NULL)
}

.linux_x86_without_avx512 <- function() {
  si <- Sys.info()
  if (si[["sysname"]] != "Linux" || si[["machine"]] != "x86_64") return(FALSE)
  cpuinfo <- tryCatch(readLines("/proc/cpuinfo"), error = function(e) character(0))
  !any(grepl("avx512f", cpuinfo))
}
