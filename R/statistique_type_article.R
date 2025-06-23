#' -------- Fonction statistique_type_article() --------
#'
#' Cette fonction retourne les statistiques des ventes par type d'article
#' (ex : Princeps, Générique, Biosimilaire...) et selon leur caractère
#' substituable ou non, sur une période donnée.
#'
#' ##Usage
#'
#' statistique_type_article(date_debut, date_fin)
#'
#' ## Résultat
#'
#' Un data.frame (tibble) avec les colonnes suivantes :
#' - `periode`      : période au format AAAAMM
#' - `type_artic`   : type de l'article (Princeps, Biosimilaire, etc.)
#' - `Subtitution`  : "Substituable" ou "Non substituable"
#' - `CA_HT`        : chiffre d'affaires HT (arrondi 2 décimales)
#' - `qte_vendu`    : quantité totale vendue
#'
#' ## Exemple
#'
#' statistique_type_article(202306, 202505)
#'
#' @export
#' @importFrom utils View
statistique_type_article <- function(date_debut, date_fin) {
  if (missing(date_debut) || missing(date_fin)) {
    stop("Les arguments `date_debut` et `date_fin` sont requis (format AAAAMM).")
  }

  query <- sprintf(
    "SELECT periode, type_artic,\n            CASE WHEN substitution = 0 THEN 'Non substituable' ELSE 'Substituable' END AS Subtitution,\n            ROUND(SUM(ca_ht_artic), 2) AS CA_HT,\n            SUM(qt_vendu_artic) AS qte_vendu\n     FROM os_labogener_artic\n     LEFT JOIN os_stat_artic ON n_auto_artic = n_auto_artic_artic\n     LEFT JOIN dbo.os_gener a ON n_auto_artic = n_auto_artic_gener\n     LEFT JOIN os_grpgener_artic b ON a.groupe_gener = b.groupe_gener\n     WHERE periode BETWEEN %d AND %d\n       AND n_auto_adhpha_artic NOT IN (\n         SELECT n_auto_adhpha\n         FROM dbo.os_completudepha\n         WHERE moisok_completudepha IN (0, 8)\n           AND periode_completudepha BETWEEN %d AND %d)\n     GROUP BY periode, type_artic, substitution",
    date_debut, date_fin, date_debut, date_fin
  )

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  utils::View(res)
  res
}
