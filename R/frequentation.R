#' Calcul de la fréquentation journalière moyenne
#'
#' Cette fonction calcule la **fréquentation moyenne journalière** d'une pharmacie
#' (nombre moyen de clients par jour), sur une période personnalisée.
#'
#' @param n_auto Identifiant de la pharmacie (`n_auto_adhpha_ecollect`)
#' @param date_debut Période de début au format `YYYYMM` (ex : 202401)
#' @param date_fin Période de fin au format `YYYYMM` (ex : 202404)
#'
#' @return Un data.frame avec :
#' - `n_auto` : identifiant de la pharmacie
#' - `frequentation_moyenne_jour` : fréquentation moyenne journalière
#'
#' @examples
#' \dontrun{
#' frequentation_journaliere(123456, 202401, 202404)
#' }
#'
#' @export
frequentation_journaliere <- function(n_auto, date_debut, date_fin) {
  requete <- sprintf("
    WITH ventes_par_jour AS (
      SELECT n_auto_adhpha_ecollect AS n_auto,
        CONVERT(date, dateheure_ecollect) AS jour,
        COUNT(DISTINCT n_auto_ecollect) AS nb_clients
      FROM v_el_collect_ospharm
      WHERE periode BETWEEN %d AND %d
        AND n_auto_adhpha_ecollect = %d
      GROUP BY n_auto_adhpha_ecollect, CONVERT(date, dateheure_ecollect)
    )
    SELECT n_auto,
      ROUND(AVG(nb_clients), 1) AS [frequentation_moyenne_jour]
    FROM ventes_par_jour
    GROUP BY n_auto
  ", date_debut, date_fin, n_auto)

  result <- executer_sql(requete)
  return(result)
}
