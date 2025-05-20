#' Obtenir les pharmacies complètes pour une année donnée
#'
#' Cette fonction retourne les pharmacies considérées comme **complètes** sur 12 mois,
#' pour une année spécifique (par défaut l'année précédente), ainsi que leur chiffre d'affaires (CA).
#'
#' - Si `n = 0`, retourne les données pour l’année en cours - 1.
#' - Si `n = 1`, retourne l’année en cours - 2, etc.
#' - Jusqu’à `n = 2` (au-delà, un message est renvoyé).
#'
#' Le nom de la colonne du CA est généré dynamiquement (ex : "CA 2023").
#'
#' @param n Entier (défaut = 0). Nombre d'années à reculer depuis l'année actuelle - 1.
#'
#' @return Un data.frame contenant :
#' - `n_auto_adhpha_global` : identifiant de la pharmacie
#' - `CA xxxx` : le chiffre d'affaires pour l’année cible
#'
#' @examples
#' \dontrun{
#' pharma_complete_12()       # Pour l’année N-1
#' pharma_complete_12(n = 1)  # Pour l’année N-2
#' }
#'
#' @export
pharma_complete_12 <- function(n = 0) {
  annee_actuelle <- as.numeric(format(Sys.Date(), "%Y"))
  annee_cible <- annee_actuelle - 1 - n

  if (n > 2) {
    return("Pas de données disponibles pour cette période")
  }

  periode_debut <- annee_cible * 100 + 1
  periode_fin <- annee_cible * 100 + 12
  nom_colonne_ca <- paste0("CA ", annee_cible)

  requete <- sprintf("
    SELECT n_auto_adhpha_global,
           ROUND(SUM(ca_ht_global), 2) AS [%s]
    FROM dbo.os_stat_global
    WHERE n_auto_adhpha_global NOT IN (
        SELECT n_auto_adhpha
        FROM dbo.os_completudepha
        WHERE periode_completudepha BETWEEN %d AND %d
        AND moisok_completudepha IN (0, 8)
    )
    AND an_global = %d
    GROUP BY n_auto_adhpha_global
  ", nom_colonne_ca, periode_debut, periode_fin, annee_cible)

  resultat <- executer_sql(requete)
  return(resultat)
}
