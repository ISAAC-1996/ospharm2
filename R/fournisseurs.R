#' -------- Fonction fournisseurs() --------
#'
#' Cette fonction récupère la liste des fournisseurs référencés dans la base.
#'
#' ##Usage
#'
#' fournisseurs()
#'
#' ## Résultat
#'
#' Un data.frame (tibble) avec les colonnes suivantes :
#' - `n_auto_adhfour` : identifiant unique du fournisseur
#' - `nom_adhfour`    : nom du fournisseur
#' - `cp_adhfour`     : code postal
#' - `ville_adhfour`  : ville
#'
#' ## Exemple
#'
#' fournisseurs()
#'
#' @export
fournisseurs <- function() {
  query <- "SELECT n_auto_adhfour, nom_adhfour, cp_adhfour, ville_adhfour FROM os_adhfour"

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  res
}
