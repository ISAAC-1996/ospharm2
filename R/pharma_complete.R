#' Obtenir les pharmacies complètes sur une période définie
#'
#' La fonction `pharma_complete()` retourne les pharmacies considérées comme **complètes**
#' sur une période donnée (définie par une date de début et une date de fin au format `YYYYMM`),
#' ainsi que leurs indicateurs économiques principaux (CA HT, CA TTC, nombre de ventes, quantités vendues).
#'
#' - Les noms des colonnes de sortie sont fixes (non dynamiques).
#'
#' @param date_debut Entier. Date de début au format `YYYYMM` (ex : 202401).
#' @param date_fin Entier. Date de fin au format `YYYYMM` (ex : 202412). Doit être ≥ à `date_debut`.
#'
#' @return Un `data.frame` listant les pharmacies complètes sur la période indiquée, avec leurs données consolidées.
#'
#' @examples
#' \dontrun{
#' pharma_complete(202401, 202412)
#' }
#'
#' @export
pharma_complete <- function(date_debut, date_fin) {
  if (missing(date_debut) || missing(date_fin)) {
    stop("Merci de spécifier une date de début et une date de fin au format YYYYMM.")
  }

  if (date_fin < date_debut) {
    stop("La date de fin doit être supérieure ou égale à la date de début.")
  }

  requete <- sprintf("
    SELECT
      n_auto_adhpha_global AS n_auto_adhpha,
      nom_syndicat,
      nom_typhie,
      cip,
      rs_adhpha,
      nom_ville,
      cp_ville,
      ssii_adhpha,
      ROUND(SUM(ca_ht_global), 2) AS [ca ht],
      ROUND(SUM(ca_ttc_global), 2) AS [ca_ttc],
      SUM(nb_vte_global) AS [vente],
      SUM(qt_vendu_global) AS quantité
    FROM dbo.os_stat_global a
    LEFT JOIN dbo.vuProdAdhpha b ON n_auto_adhpha_global = n_auto_adhpha
    LEFT JOIN dbo.os_syndicat ON syndic_adhpha = n_auto_syndicat
    LEFT JOIN dbo.os_typhie on b.typhie_adhpha = n_auto_typhie
    WHERE dextinct_adhpha IS NULL
      AND n_auto_adhpha_global NOT IN (
        SELECT n_auto_adhpha
        FROM dbo.os_completudepha
        WHERE periode_completudepha BETWEEN %d AND %d
          AND moisok_completudepha IN (0, 8)
      )
      AND periode BETWEEN %d AND %d
    GROUP BY
      n_auto_adhpha_global, nom_typhie, cip, rs_adhpha, nom_ville, cp_ville, ssii_adhpha, nom_syndicat
  ",
                     date_debut, date_fin,
                     date_debut, date_fin
  )

  resultat <- executer_sql(requete)
  return(resultat)
}
