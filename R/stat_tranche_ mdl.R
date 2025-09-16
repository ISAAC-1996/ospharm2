#' Statistiques par tranche MDL sur une période donnée
#'
#' Cette fonction interroge la base `os_stat_artic` en joignant la table
#' `CEPS_Prix` pour calculer les statistiques de CA et de volume par
#' tranche MDL. Elle prend en paramètre une période de début et une période de fin
#' (au format `YYYYMM`), et retourne un tableau agrégé par mois et tranche MDL.
#'
#' @param date_debut Période de début au format numérique `YYYYMM` (ex: 202306)
#' @param date_fin Période de fin au format numérique `YYYYMM` (ex: 202406)
#'
#' @return Un data.frame avec les colonnes : `periode`, `Tranche_MDL`, `CA`, `volume`.
#' @export
#'
#' @examples
#' df_mdl <- stat_tranche_mdl(202301, 202405)
#' head(df_mdl)
stat_tranche_mdl <- function(date_debut, date_fin) {
  # Vérification des arguments
  if (missing(date_debut) || missing(date_fin)) {
    stop("Veuillez fournir les paramètres `date_debut` et `date_fin` au format YYYYMM.")
  }

  if (!is.numeric(date_debut) || !is.numeric(date_fin)) {
    stop("Les paramètres doivent être au format numérique YYYYMM.")
  }

  if (date_fin < date_debut) {
    stop("La date de fin doit être supérieure ou égale à la date de début.")
  }

  # Construction dynamique de la requête SQL
  requete_sql <- glue::glue("
    SELECT
      periode,
      Tranche_MDL,
      ROUND(SUM(ca_ht_artic), 2) AS CA,
      SUM(qt_vendu_artic) AS volume
    FROM dbo.os_stat_artic
      INNER JOIN OSP_PROD.dbo.CEPS_Prix
        ON (
          Id_SQL = n_auto_artic_artic
          AND Date_Debut <= DATEFROMPARTS(an_artic, mois_artic, 1)
          AND Date_Fin >= DATEFROMPARTS(an_artic, mois_artic, 1)
        )
    WHERE periode BETWEEN {date_debut} AND {date_fin}
    GROUP BY periode, Tranche_MDL
  ")

  # Exécution de la requête
  df <- executer_sql(as.character(requete_sql))

  return(df)
}
