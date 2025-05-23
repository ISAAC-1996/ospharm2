% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/carte_interactive_france.R
\name{carte_interactive_france}
\alias{carte_interactive_france}
\title{Carte interactive de la France avec \code{leaflet}}
\usage{
carte_interactive_france(
  base,
  var_region,
  var_valeurs,
  titre_carte = "Carte Interactive de la France",
  couleur_palette = "YlOrRd",
  logo_path = NULL,
  signe_unite = 0,
  valeurs_fixes_supp = NULL
)
}
\arguments{
\item{base}{Un \code{data.frame} contenant les données des régions avec les valeurs associées.}

\item{var_region}{Nom de la colonne contenant les noms des régions.}

\item{var_valeurs}{Vecteur de noms de colonnes des variables à afficher en info-bulle (\code{tooltip}).
La \strong{première variable} est utilisée pour la coloration de la carte.}

\item{titre_carte}{Titre affiché sur la carte (\code{default = "Carte Interactive de la France"}).}

\item{couleur_palette}{Palette de couleurs pour \code{leaflet} (\code{default = "YlOrRd"}).
Exemples : \code{"Blues"}, \code{"Greens"}, \code{"Reds"}, \code{"Purples"}.}

\item{logo_path}{Chemin ou URL du logo à afficher en haut à droite (\code{default = NULL}).}

\item{signe_unite}{Indique l'unité à afficher pour la variable principale (\code{default = 0}).
- \code{0} : Pas d'unité
- \code{1} : Affiche \verb{€}
- \code{2} : Affiche \verb{\%}}

\item{valeurs_fixes_supp}{Vecteur de noms de colonnes des variables supplémentaires à afficher
avec la valeur principale fixée sur la carte (\code{default = NULL}).}
}
\value{
Un objet \code{leaflet} affichant la carte interactive de la France.
}
\description{
Cette fonction permet de générer une carte interactive de la France avec des données personnalisables.
Les couleurs des régions sont basées sur une variable principale et peuvent être personnalisées.
Il est aussi possible d'afficher des valeurs supplémentaires en étiquette.
}
\examples{
# Création d'un jeu de données
donnees_france <- data.frame(
  region = c("Île-de-France", "Auvergne-Rhône-Alpes", "Nouvelle-Aquitaine", 
             "Occitanie", "Grand Est", "Hauts-de-France", "Bretagne", 
             "Normandie", "Pays de la Loire", "Provence-Alpes-Côte d'Azur",
             "Centre-Val de Loire", "Bourgogne-Franche-Comté", "Corse"),
  temperature = c(15, 12, 14, 17, 10, 9, 13, 11, 14, 18, 10, 9, 20),
  taux_croissance = c(3.5, 2.8, 4.1, 3.9, 3.2, 2.5, 3.8, 2.9, 3.6, 4.2, 3.0, 2.7, 3.9),
  population = c(12000000, 8000000, 6000000, 5500000, 5000000, 7000000, 
                 3300000, 3200000, 3800000, 5100000, 2500000, 2800000, 350000)
)

# Affichage de la carte avec la température et d'autres indicateurs
carte_interactive_france(base = donnees_france, 
                         var_region = "region", 
                         var_valeurs = c("temperature", "taux_croissance", "population"), 
                         titre_carte = "Température moyenne par région",
                         couleur_palette = "YlOrRd", 
                         logo_path = "https://logo.png",
                         signe_unite = 2,  # Ajoute le signe "\%"
                         valeurs_fixes_supp = c("taux_croissance", "population"))

}
