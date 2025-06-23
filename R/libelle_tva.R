#' Libellés des taux de TVA
#'
#' Cette fonction retourne la liste des taux de TVA disponibles dans la base.
#'
#' @param syndic_only Si `TRUE` (par défaut), on ne garde que les lignes actives.
#'
#' @return Un tableau (tibble) avec les colonnes : `code_tva`, `lib_tva`, `taux_tva`.
#'
#' @examples
#' libelle_tva()          # taux actifs uniquement
#' libelle_tva(FALSE)     # tous les taux
#'
#' @export
#' @importFrom dplyr filter select
libelle_tva <- function(syndic_only = TRUE) {
  query <- "SELECT * FROM hfl_os_tva"
  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  if (syndic_only) {
    res <- res |>
      dplyr::filter(.data$syndic == 1) |>
      dplyr::select(-"syndic")
  }

  res
}

