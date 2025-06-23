#' -------- Fonction libelle_article() --------
#'
#' Cette fonction retourne les informations principales d'un article :
#' identifiant, famille, marque, type, taux de TVA, nom, et fournisseur.
#'
#' ##Usage
#'
#' libelle_article()
#'
#' ## Résultat
#'
#' Un data.frame (tibble) avec les colonnes suivantes :
#' - `n_auto_artic`   : identifiant article
#' - `n_auto_famille` : identifiant de la famille
#' - `lib_famille`    : nom de la famille
#' - `marque`         : marque du produit
#' - `type_artic`     : type d'article
#' - `tva_artic`      : taux de TVA lié au produit
#' - `nom_artic`      : nom de l'article
#' - `adhfour`        : code fournisseur
#'
#' ## Exemple
#'
#' libelle_article()
#'
#' @export
#' @importFrom utils View
libelle_article <- function() {
  query <- "SELECT a.n_auto_artic, n_auto_famille, lib_famille, marque, c.type_artic, b.tva_artic, nom_artic, adhfour\n            FROM os_classif a\n            LEFT JOIN os_artic b ON a.n_auto_artic = b.n_auto_artic\n            LEFT JOIN os_labogener_artic c ON a.n_auto_artic = c.n_auto_artic"

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  utils::View(res)
  res
}
