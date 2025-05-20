#' get_previous_month - Obtenir un mois précédent sous format YYYYmm
#'
#' Cette fonction permet d'obtenir la date du mois précédent par défaut,
#' ou un nombre de mois avant spécifié par l'utilisateur.
#'
#' @param n Un entier représentant le nombre de mois à remonter (par défaut 0 pour le mois précédent).
#'
#' @return Une chaîne de caractères représentant l'année et le mois au format YYYYmm.
#'
#' @export
#'
#' @examples
#' get_previous_month()   # Mois précédent
#' get_previous_month(1)  # Deux mois avant
#' get_previous_month(12) # Douze mois avant
#'
get_previous_month <- function(n = 0) {
  # Obtenir la date actuelle
  current_date <- Sys.Date()

  # Obtenir le premier jour du mois actuel et soustraire le nombre de mois spécifié
  previous_month_date <- seq(as.Date(format(current_date, "%Y-%m-01")), length = 2, by = paste0("-", n + 1, " months"))[2]

  # Extraire l'année et le mois sous le format souhaité
  previous_month_str <- format(previous_month_date, "%Y%m")

  return(previous_month_str)
}


