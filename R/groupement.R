#' -------- Fonction groupement() --------
#'
#' Cette fonction retourne la liste des groupements de pharmacies
#' ainsi que les identifiants des pharmacies associées.
#'
#' ##Usage
#'
#' groupement()
#'
#' ## Résultat
#'
#' Un data.frame (tibble) avec les colonnes suivantes :
#' - `n_auto_adhpha` : identifiant de la pharmacie
#' - `n_auto_adhgrp` : identifiant du groupement
#' - `nom_adhgrp`    : nom du groupement
#'
#' ## Exemple
#'
#' groupement()
#'
#' @export
groupement <- function() {
  query <- "SELECT n_auto_adhpha, a.n_auto_adhgrp, b.nom_adhgrp\n            FROM dbo.os_grp_adhpha a\n            LEFT JOIN dbo.os_adhgrp b ON a.n_auto_adhgrp = b.n_auto_adhgrp"

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  res
}
