#' Récupère les informations géographiques des communes françaises
#'
#' Cette fonction interroge l'API \url{https://geo.api.gouv.fr} pour retourner
#' une table contenant les noms, codes INSEE, codes postaux, population, géolocalisation,
#' départements et régions de toutes les communes françaises (communes et arrondissements municipaux).
#'
#' @return Un \code{data.frame} avec les informations par commune
#' @export
#' @examples
#' \dontrun{
#'   df <- infos_communes()
#'   head(df)
#' }
infos_communes <- function() {
  requireNamespace("httr", quietly = TRUE)
  requireNamespace("jsonlite", quietly = TRUE)

  get_communes <- function(type = NULL) {
    base_url <- "https://geo.api.gouv.fr/communes?fields=nom,code,codesPostaux,population,centre,departement,region&format=json&geometry=centre"

    if (!is.null(type)) {
      base_url <- paste0(base_url, "&type=", type)
    }

    res <- httr::GET(base_url)

    if (httr::status_code(res) == 200) {
      data <- jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"))

      if (length(data) == 0) return(NULL)

      return(data.frame(
        nom = data$nom,
        code_insee = data$code,
        code_postal = sapply(data$codesPostaux, function(x) if (length(x) > 0) x[1] else NA),
        population = data$population,
        lon = sapply(data$centre$coordinates, function(x) x[1]),
        lat = sapply(data$centre$coordinates, function(x) x[2]),
        departement = data$departement$nom,
        region = data$region$nom,
        type = if (is.null(type)) "commune" else type,
        stringsAsFactors = FALSE
      ))
    } else {
      stop("Erreur API : ", httr::status_code(res))
    }
  }

  # Fusionne communes et arrondissements
  df <- do.call(rbind, list(
    get_communes(),
    get_communes("arrondissement-municipal")
  ))

  return(df)
}
