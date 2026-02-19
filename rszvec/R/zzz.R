.onLoad <- function(libname, pkgname) {
  python_bin <- file.path(
    tools::R_user_dir("rzvec", "cache"), "rzvec-venv", "bin", "python"
  )
  if (file.exists(python_bin)) {
    Sys.setenv(RETICULATE_PYTHON = python_bin)
  }
}

#' Install Python dependencies for rszvec
#'
#' A convenience wrapper around [rzvec::rzvec_install()]. Creates a virtualenv
#' and installs the `zvec` Python package. Only needed once per machine.
#'
#' @param ... Arguments passed to [rzvec::rzvec_install()].
#'
#' @return Invisibly `NULL`.
#' @export
rszvec_install <- function(...) {
  rzvec::rzvec_install(...)
}
