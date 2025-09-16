#' -------- Fonction inactifs_datastat() --------
#'
#' Cette fonction retourne, jour par jour, le nombre de **pharmacies désactivées (inactives)**
#' du service *DataStat*, ainsi que leur cumul depuis le 01/01/2002.
#'
#' ##Usage
#'
#' inactifs_datastat()
#'
#' ## Résultat
#'
#' Un `data.frame` (tibble) avec les colonnes suivantes :
#' - `n_auto_adhpha`            : identifiant de la pharmacie (NA si aucune sortie ce jour-là)
#' - `date_complete`            : date de sortie (AAAA/MM/JJ)
#' - `Nb_Inactif_journalier`    : nombre de pharmacies devenues inactives ce jour-là
#' - `somme_cumulative_Inactif` : cumul total d’inactivations depuis 2002
#'
#' ## Exemple
#'
#' inactifs_datastat()
#'
#' @export
inactifs_datastat <- function() {
  query <- "WITH Liste_Jours AS (\n    SELECT CAST('2002-01-01' AS DATE) AS date_adhesion\n    UNION ALL\n    SELECT DATEADD(DAY, 1, date_adhesion)\n    FROM Liste_Jours\n    WHERE date_adhesion < CAST(GETDATE() AS DATE)\n)\nSELECT a.n_auto_adhpha,\n       FORMAT(Liste_Jours.date_adhesion, 'yyyy/MM/dd') AS date_complete,\n       COALESCE(COUNT(a.n_auto_adhpha), 0) AS Nb_Inactif_journalier,\n       SUM(COALESCE(COUNT(a.n_auto_adhpha), 0)) OVER (ORDER BY Liste_Jours.date_adhesion) AS somme_cumulative_Inactif\nFROM Liste_Jours\nLEFT JOIN [OSP_PROD].[dbo].os_adhpha a\n       ON CAST(a.dextinct_adhpha AS DATE) = Liste_Jours.date_adhesion\n      AND a.dextinct_adhpha IS NOT NULL\nGROUP BY a.n_auto_adhpha, Liste_Jours.date_adhesion\nORDER BY Liste_Jours.date_adhesion\nOPTION (MAXRECURSION 0)"

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  res
}
