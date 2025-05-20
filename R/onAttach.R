#' Chargement automatique des librairies à l'ouverture du package
#'
#' @noRd
.onAttach <- function(libname, pkgname) {
  required_packages <- c(
    "sf", "leaflet", "leaflet.extras2", "shiny", "shinyjs", "DT",
    "DBI", "odbc", "openxlsx", "networkD3", "htmlwidgets", "htmltools",
    "plotly", "ggplot2", "gganimate", "ggforce", "lubridate", "readxl",
    "reshape2", "gridExtra", "geosphere", "taskscheduleR", "writexl",
    "httr", "mailR", "jsonlite", "tidyverse", "xgboost", "future", "furrr"
  )

  missing <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

  if (length(missing) > 0) {
    packageStartupMessage("Certains packages ne sont pas installés :")
    packageStartupMessage("", paste(missing, collapse = ", "))
    packageStartupMessage("Installez-les avec : install.packages(c(", paste(sprintf('"%s"', missing), collapse = ", "), "))")
  } else {
    invisible(lapply(required_packages, function(pkg) library(pkg, character.only = TRUE, quietly = TRUE)))
    packageStartupMessage("Librairies automatiquement chargées : ", paste(required_packages, collapse = ", "))
  }
}
