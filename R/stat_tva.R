#' Statistiques de ventilation par taux de TVA
#'
#' Cette fonction récupère les statistiques de chiffre d'affaires (CA) et volume
#' des articles vendus ventilés par taux de TVA, pour les pharmacies complètes
#' entre deux périodes spécifiées.
#'
#' @param date_debut Un entier au format YYYYMM représentant la période de début (ex: 202406)
#' @param date_fin Un entier au format YYYYMM représentant la période de fin (ex: 202505)
#'
#' @return Un data.frame contenant les colonnes : periode, tva_artic, CA, volume
#'
#' @examples
#' \dontrun{
#' stat_tva(202406, 202505)
#' }
#'
#' @export
stat_tva <- function(date_debut, date_fin) {

  # Validation des entrées
  if (!is.numeric(date_debut) || !is.numeric(date_fin)) {
    stop("Les dates doivent être au format numérique YYYYMM.")
  }

  # Construction de la requête SQL
  requete <- glue::glue("
    SELECT periode,
           tva_artic,
           ROUND(SUM(ca_ht_artic), 2) AS CA,
           SUM(qt_vendu_artic) AS volume
    FROM os_stat_artic
    LEFT JOIN os_artic ON n_auto_artic_artic = n_auto_artic
    WHERE periode BETWEEN {date_debut} AND {date_fin}
      AND tva_artic IN (
        SELECT code_tva
        FROM dbo.hfl_os_tva
        WHERE syndic = 1
      )
      AND n_auto_adhpha_artic NOT IN (
        SELECT n_auto_adhpha
        FROM dbo.os_completudepha
        WHERE moisok_completudepha IN (0, 8)
          AND periode_completudepha BETWEEN {date_debut} AND {date_fin}
      )
    GROUP BY periode, tva_artic
  ")

  # Exécution via fonction d'accès définie (adapter si besoin)
  resultats <- executer_sql(requete)

  return(resultats)
}
