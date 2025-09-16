#' -------- Fonction actives_datastat() --------
#'
#' Cette fonction retourne, jour par jour, le nombre de **nouvelles pharmacies adhérentes**
#' (actives) au service *DataStat*, ainsi que la somme cumulée depuis 2002‑01‑01.
#'
#' ##Usage
#'
#' actives_datastat()
#'
#' ## Résultat
#'
#' Un `data.frame` (tibble) avec les colonnes:
#' - `n_auto_adhpha`          : identifiant de la pharmacie (NA si aucune arrivée ce jour‑là)
#' - `date_complete`          : date d’adhésion (AAAA/MM/JJ)
#' - `Nb_Actif_journalier`    : nombre de nouveaux adhérents ce jour‑là
#' - `somme_cumulative_Actif` : cumul des adhérents depuis le 1ᵉʳjanvier 2002
#'
#' ## Exemple
#'
#' actives_datastat()
#'
#' @export
actives_datastat <- function() {
  query <- "WITH Liste_Jours AS (\n    SELECT CAST('2002-01-01' AS DATE) AS date_adhesion\n    UNION ALL\n    SELECT DATEADD(DAY, 1, date_adhesion)\n    FROM Liste_Jours\n    WHERE date_adhesion < CAST(GETDATE() AS DATE)\n)\nSELECT a.n_auto_adhpha,\n       FORMAT(Liste_Jours.date_adhesion, 'yyyy/MM/dd') AS date_complete,\n       COALESCE(COUNT(a.n_auto_adhpha), 0) AS Nb_Actif_journalier,\n       SUM(COALESCE(COUNT(a.n_auto_adhpha), 0)) OVER (ORDER BY Liste_Jours.date_adhesion) AS somme_cumulative_Actif\nFROM   Liste_Jours\nLEFT JOIN [OSP_PROD].[dbo].os_adhpha a\n       ON CAST(a.dinscript_adhpha AS DATE) = Liste_Jours.date_adhesion\nWHERE  a.dextinct_adhpha IS NULL\nGROUP BY a.n_auto_adhpha, Liste_Jours.date_adhesion\nORDER BY Liste_Jours.date_adhesion\nOPTION (MAXRECURSION 0);"

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  res
}
