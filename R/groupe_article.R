#' -------- Fonction groupe_article() --------
#'
#' Récupère la liste des groupes d'article (Princeps, Générique, Biosimilaire, etc.).
#'
#' ##Usage
#'
#' groupe_article()
#'
#' ## Résultat
#'
#' Un data.frame (tibble) avec les colonnes :
#' - `type_artic` : code interne du type d'article ;
#' - `Groupe`     : libellé normalisé (Princeps, Hors liste ANSM, Bioréférent, Biosimilaire, Hybride, Générique) ;
#' - `type`       : famille («Biosimilaires» ou «Générique»).
#'
#' ##Exemple
#'
#' groupe_article()
#'
#' @export
groupe_article <- function() {
  query <- "SELECT DISTINCT
              type_artic,
              CASE
                WHEN type_artic = 'P' THEN 'Princeps'
                WHEN type_artic = 'A' THEN 'Hors liste ANSM'
                WHEN type_artic = 'R' THEN 'Bioréferent'
                WHEN type_artic = 'B' THEN 'Biosimilaire'
                WHEN type_artic = 'H' THEN 'Hybride'
                ELSE 'Génerique'
              END AS Groupe,
              CASE
                WHEN type_artic IN ('R', 'B', 'H') THEN 'Biosimilaires'
                ELSE 'Génerique'
              END AS type
            FROM os_labogener_artic"

  res <- executer_sql(query)

  if (!inherits(res, "data.frame")) {
    stop("`executer_sql()` n'a pas renvoyé un data.frame comme attendu.")
  }

  res
}
