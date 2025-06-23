#' -------- Fonction statistique_famille() --------
#'
#' Cette fonction retourne les statistiques des ventes par famille de produits
#' (CA HT, quantité vendue) sur une période donnée.
#'
#' ##Usage
#'
#' statistique_famille(date_debut, date_fin)
#'
#' ## Résultat
#'
#' Un data.frame (tibble) avec les colonnes suivantes :
#' - `periode`        : période de référence (AAAAMM)
#' - `n_auto_famille` : identifiant de la famille
#' - `CA_HT`          : chiffre d'affaires HT (arrondi à 2 décimales)
#' - `qte_vendu`      : quantité vendue
#'
#' ## Exemple
#'
#' statistique_famille(202306, 202505)
#'
#' @export
#' @importFrom utils View
statistique_famille <- function(date_debut, date_fin) {
  if (missing(date_debut) || missing(date_fin)) {
    stop("Les arguments `date_debut` et `date_fin` sont requis (format AAAAMM).")
  }

  query <- sprintf(
    "SELECT periode, n_auto_famille,\n            ROUND(SUM(ca_ht_artic), 2) AS CA_HT,\n            SUM(qt_vendu_artic)       AS qte_vendu\n     FROM os_classif\n     LEFT JOIN os_stat_artic ON n_auto_artic = n_auto_artic_artic\n     WHERE periode BETWEEN %d AND %d\n       AND n_auto_adhpha_artic NOT IN (\n         SELECT n_auto_adhpha\n         FROM dbo.os_completudepha\n         WHERE moisok_completudepha IN (0, 8)\n           AND periode_completudepha BETWEEN %d AND %d)\n     GROUP BY periode, n_auto_famille",
    date_debut, date_fin, date_debut, date_fin
  )

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  utils::View(res)
  res
}
