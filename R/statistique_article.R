#' Obtenir les statistiques d'articles sur une période définie
#'
#' La fonction `statistique_article()` permet de récupérer les chiffres de vente
#' (CA HT, prix d'achat cumulé, quantité vendue) d'un ou plusieurs articles,
#' sur une période définie, en excluant les pharmacies incomplètes.
#'
#' @param articles Vecteur d'identifiants article (entiers).
#' @param date_debut Entier. Date de début au format AAAAMM (ex : 202306).
#' @param date_fin Entier. Date de fin au format AAAAMM (ex : 202505).
#'
#' @return Un data.frame avec une ligne par combinaison article/pharmacie/période,
#'         contenant les colonnes :
#'         - `periode`
#'         - `n_auto_adhpha_artic`
#'         - `n_auto_artic_artic`
#'         - `CA_HT`
#'         - `px_achat`
#'         - `qte_vendu`
#'
#' @examples
#' statistique_article(c(344734), 202306, 202505)
#'
#' @export
statistique_article <- function(articles, date_debut, date_fin) {
  # Validation minimale des arguments
  if (missing(articles) || length(articles) == 0) {
    stop("Argument `articles` manquant ou vide.")
  }
  if (missing(date_debut) || missing(date_fin)) {
    stop("`date_debut` et `date_fin` doivent être fournis (format AAAAMM).")
  }

  # Préparer la liste des articles pour SQL
  articles_sql <- paste(articles, collapse = ",")

  # Construction de la requête
  query <- sprintf(
    "SELECT periode, n_auto_adhpha_artic, n_auto_artic_artic,\n            ROUND(SUM(ca_ht_artic),2)  AS CA_HT,\n            ROUND(SUM(px_achat_artic),2) AS px_achat,\n            SUM(qt_vendu_artic)         AS qte_vendu\n     FROM os_stat_artic\n     WHERE periode BETWEEN %d AND %d\n       AND n_auto_artic_artic IN (%s)\n       AND n_auto_adhpha_artic NOT IN (\n             SELECT n_auto_adhpha\n             FROM dbo.os_completudepha\n             WHERE moisok_completudepha IN (0,8)\n               AND periode_completudepha BETWEEN %d AND %d)\n     GROUP BY periode, n_auto_adhpha_artic, n_auto_artic_artic",
    date_debut, date_fin, articles_sql, date_debut, date_fin)

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  res
}

getNamespaceExports("ospharm2")
