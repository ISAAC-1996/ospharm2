#' -------- Fonction periode_window() --------
#'
#' Cette fonction retourne une table des périodes (AAAAMM) avec le nom du mois
#' correspondant, soit sur la base d'une fenêtre glissante en mois, soit entre deux dates données.
#'
#' ##Usage
#'
#' periode_window(n = 6)
#' periode_window(date_debut = 202301, date_fin = 202312)
#'
#' ## Paramètres
#'
#' - `n` : entier. Nombre de mois à retourner en arrière à partir du mois précédent (par défaut : NULL)
#' - `date_debut` : entier (AAAAMM), début de période si `n` est NULL.
#' - `date_fin` : entier (AAAAMM), fin de période si `n` est NULL.
#'
#' ## Résultat
#' Un data.frame avec deux colonnes :
#' - `Periode` : code période au format AAAAMM
#' - `Mois`    : nom du mois en français
#'
#' ## Exemple
#'
#' periode_window(5)
#' periode_window(date_debut = 202201, date_fin = 202212)
#'
#' @export
periode_window <- function(n = NULL, date_debut = NULL, date_fin = NULL) {
  mois_fr <- c("Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
               "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre")

  if (!is.null(n)) {
    today <- Sys.Date()
    first_day_current_month <- as.Date(paste0(format(today, "%Y-%m"), "-01"))
    first_day_last_month <- seq(first_day_current_month, by = "-1 month", length.out = 2)[2]
    dates <- seq(from = first_day_last_month, by = "-1 month", length.out = n)
    # Garder dans l'ordre décroissant (le plus récent en haut)
    periodes <- format(dates, "%Y%m")
    noms_mois <- mois_fr[as.integer(format(dates, "%m"))]
  } else if (!is.null(date_debut) && !is.null(date_fin)) {
    dates <- seq(as.Date(paste0(date_debut, "01"), "%Y%m%d"),
                 as.Date(paste0(date_fin, "01"), "%Y%m%d"), by = "month")
    periodes <- format(dates, "%Y%m")
    noms_mois <- mois_fr[as.integer(format(dates, "%m"))]
  } else {
    stop("Vous devez renseigner soit `n`, soit `date_debut` et `date_fin`.")
  }

  tibble::tibble(Periode = periodes, Mois = noms_mois)
}
