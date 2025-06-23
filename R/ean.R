#' -------- Fonction ean() --------
#'
#' Cette fonction récupère les codes EAN associés aux articles.
#'
#' ##Usage
#'
#' ean()
#'
#' ## Résultat
#'
#' Un data.frame (tibble) avec les colonnes suivantes :
#' - `n_auto_artic` : identifiant de l'article
#' - `code_ean`     : code EAN correspondant
#'
#' ## Exemple
#'
#' ean()
#'
#' @export
#' @importFrom utils View
ean <- function() {
  query <- "SELECT n_auto_artic_ean AS n_auto_artic, code_ean FROM os_ean"

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  utils::View(res)
  res
}
