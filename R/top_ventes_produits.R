#' Top des ventes de produits (par pharmacie, région, marque et période)
#'
#' Cette fonction retourne un classement des produits les plus vendus en quantités,
#' avec la possibilité de filtrer par pharmacie, région, marque, et période.
#'
#' @param region Entier (optionnel). Code de région (ex: 1)
#' @param marque Chaîne (optionnelle). Marque produit (ex: "avril")
#' @param n_auto_adhpha_artic Entier (optionnel). Identifiant de la pharmacie
#' @param date_debut Entier. Période de début (format `YYYYMM`, ex: 202401)
#' @param date_fin Entier. Période de fin (format `YYYYMM`, ex: 202412)
#' @param top_n Entier. Nombre de lignes à retourner (défaut = 20)
#'
#' @return Un `data.frame` avec EAN, nom produit, famille, quantité vendue et CA
#'
#' @examples
#' \dontrun{
#' # Classement pour une pharmacie spécifique
#' top_ventes_produits(n_auto_adhpha_artic = 7722, date_debut = 202401, date_fin = 202412)
#'
#' # Top 30 pour la marque "avril" en région 1
#' top_ventes_produits(region = 1, marque = "avril", date_debut = 202401, date_fin = 202412, top_n = 30)
#'
#' # Classement global (toutes régions / toutes pharmacies)
#' top_ventes_produits(date_debut = 202401, date_fin = 202412)
#' }
#'
#' @export
top_ventes_produits <- function(region = NULL, marque = NULL, n_auto_adhpha_artic = NULL,
                                date_debut, date_fin, top_n = 20) {

  # Filtre région
  filtre_region <- if (!is.null(region)) {
    sprintf("AND n_auto_adhpha_artic IN (
      SELECT n_auto_adhpha FROM os_adhpha WHERE region_adhpha = %d
    )", region)
  } else {
    ""
  }

  # Filtre marque
  filtre_marque <- if (!is.null(marque)) {
    sprintf("AND n_auto_artic_artic IN (
      SELECT n_auto_artic FROM os_classif WHERE marque LIKE '%s%%'
    )", marque)
  } else {
    ""
  }

  # Filtre pharmacie (le plus précis)
  filtre_pharmacie <- if (!is.null(n_auto_adhpha_artic)) {
    sprintf("AND n_auto_adhpha_artic = %d", n_auto_adhpha_artic)
  } else {
    ""
  }

  # Construction de la requête SQL
  requete <- sprintf("
    SELECT TOP %d
      code_ean AS EAN,
      nom_artic AS Produit,
      n_auto_famille,
      lib_famille,
      SUM(qt_vendu_artic) AS [Quantité vendue],
      ROUND(SUM(ca_ht_artic), 2) AS CA
    FROM os_stat_artic
    LEFT JOIN os_artic ON n_auto_artic_artic = n_auto_artic
    LEFT JOIN os_ean ON n_auto_artic = n_auto_artic_ean
    LEFT JOIN os_classif ON n_auto_artic_artic = os_classif.n_auto_artic
    WHERE type_code = 1
      AND periode BETWEEN %d AND %d
      %s
      %s
      %s
    GROUP BY code_ean, nom_artic, n_auto_famille, lib_famille
    ORDER BY [Quantité vendue] DESC
  ",
                     top_n, date_debut, date_fin,
                     filtre_marque,
                     filtre_region,
                     filtre_pharmacie
  )

  # Exécution
  resultat <- executer_sql(requete)
  return(resultat)
}
