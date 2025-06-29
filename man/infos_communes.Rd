% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/infos_communes.R
\name{infos_communes}
\alias{infos_communes}
\title{Récupère les informations géographiques des communes françaises}
\usage{
infos_communes()
}
\value{
Un \code{data.frame} avec les informations par commune
}
\description{
Cette fonction interroge l'API \url{https://geo.api.gouv.fr} pour retourner
une table contenant les noms, codes INSEE, codes postaux, population, géolocalisation,
départements et régions de toutes les communes françaises (communes et arrondissements municipaux).
}
\examples{
\dontrun{
  df <- infos_communes()
  head(df)
}
}
