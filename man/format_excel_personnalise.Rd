% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format_excel_personnalise.R
\name{format_excel_personnalise}
\alias{format_excel_personnalise}
\title{Formatage avancé d'un fichier Excel}
\usage{
format_excel_personnalise(
  data,
  output_file,
  header_bg_color,
  header_font_color,
  alternate_row_color,
  logo_path = "https://isaac-1996.github.io/Localisation/03_LOGO_OSPHARM.png",
  sheet_name = "Rapport",
  font_name = "Montserrat",
  border_color = "#000000",
  report_title = NULL
)
}
\arguments{
\item{data}{Un dataframe à exporter vers Excel}

\item{output_file}{Chemin du fichier Excel de sortie (défini par l'utilisateur)}

\item{header_bg_color}{Couleur d'arrière-plan des titres (hex, ex: "#0084ff")}

\item{header_font_color}{Couleur de police des titres (hex, ex: "#FFFFFF")}

\item{alternate_row_color}{Couleur des lignes alternées (hex, ex: "#e6f3ff")}

\item{logo_path}{Chemin vers le logo (URL ou chemin local)}

\item{sheet_name}{Nom de la feuille de calcul (défaut: "Rapport")}

\item{font_name}{Nom de la police (défaut: "Montserrat")}

\item{border_color}{Couleur des bordures (défaut: "#000000")}

\item{report_title}{Titre du rapport (défaut: NULL)}
}
\value{
Invisible, crée un fichier Excel formaté
}
\description{
Cette fonction prend un dataframe et crée un fichier Excel avec une mise en forme professionnelle
incluant : titres colorés et centrés, lignes alternées, bordures, filtres et logo d'entreprise.
Toutes les options sont personnalisables par l'utilisateur.
}
