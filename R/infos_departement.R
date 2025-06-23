#' Infos sur les départements français (via sf)
#'
#' Cette fonction télécharge et lit le fichier GeoJSON des départements français
#' via le package sf.
#'
#' @return Un data.frame avec le nom, le code, la longitude et la latitude du centroïde
#' @importFrom sf st_read st_centroid st_coordinates
#' @examples
#' \dontrun{
#'   df <- infos_departement()
#'   head(df)
#' }
infos_departement <- function() {
  url <- "https://france-geojson.gregoiredavid.fr/repo/departements.geojson"
  local_file <- tempfile(fileext = ".geojson")
  download.file(url, local_file, quiet = TRUE)

  sf_obj <- sf::st_read(local_file, quiet = TRUE)

  # Calcul du centroïde
  centroids <- sf::st_centroid(sf_obj$geometry)
  coords <- sf::st_coordinates(centroids)

  df <- data.frame(
    nom = sf_obj$nom,
    code = sf_obj$code,
    lon = coords[,1],
    lat = coords[,2],
    stringsAsFactors = FALSE
  )

  return(df)
}
