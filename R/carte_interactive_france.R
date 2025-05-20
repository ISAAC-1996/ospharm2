#' @title Carte interactive de la France avec `leaflet`
#' @description
#' Cette fonction permet de générer une carte interactive de la France avec des données personnalisables.
#' Les couleurs des régions sont basées sur une variable principale et peuvent être personnalisées.
#' Il est aussi possible d'afficher des valeurs supplémentaires en étiquette.
#'
#' @param base Un `data.frame` contenant les données des régions avec les valeurs associées.
#' @param var_region Nom de la colonne contenant les noms des régions.
#' @param var_valeurs Vecteur de noms de colonnes des variables à afficher en info-bulle (`tooltip`). 
#'        La **première variable** est utilisée pour la coloration de la carte.
#' @param titre_carte Titre affiché sur la carte (`default = "Carte Interactive de la France"`).
#' @param couleur_palette Palette de couleurs pour `leaflet` (`default = "YlOrRd"`). 
#'        Exemples : `"Blues"`, `"Greens"`, `"Reds"`, `"Purples"`.
#' @param logo_path Chemin ou URL du logo à afficher en haut à droite (`default = NULL`).
#' @param signe_unite Indique l'unité à afficher pour la variable principale (`default = 0`).
#'        - `0` : Pas d'unité  
#'        - `1` : Affiche `€`  
#'        - `2` : Affiche `%`
#' @param valeurs_fixes_supp Vecteur de noms de colonnes des variables supplémentaires à afficher 
#'        avec la valeur principale fixée sur la carte (`default = NULL`).
#'
#' @return Un objet `leaflet` affichant la carte interactive de la France.
#'
#' @examples
#' # Création d'un jeu de données
#' donnees_france <- data.frame(
#'   region = c("Île-de-France", "Auvergne-Rhône-Alpes", "Nouvelle-Aquitaine", 
#'              "Occitanie", "Grand Est", "Hauts-de-France", "Bretagne", 
#'              "Normandie", "Pays de la Loire", "Provence-Alpes-Côte d'Azur",
#'              "Centre-Val de Loire", "Bourgogne-Franche-Comté", "Corse"),
#'   temperature = c(15, 12, 14, 17, 10, 9, 13, 11, 14, 18, 10, 9, 20),
#'   taux_croissance = c(3.5, 2.8, 4.1, 3.9, 3.2, 2.5, 3.8, 2.9, 3.6, 4.2, 3.0, 2.7, 3.9),
#'   population = c(12000000, 8000000, 6000000, 5500000, 5000000, 7000000, 
#'                  3300000, 3200000, 3800000, 5100000, 2500000, 2800000, 350000)
#' )
#'
#' # Affichage de la carte avec la température et d'autres indicateurs
#' carte_interactive_france(base = donnees_france, 
#'                          var_region = "region", 
#'                          var_valeurs = c("temperature", "taux_croissance", "population"), 
#'                          titre_carte = "Température moyenne par région",
#'                          couleur_palette = "YlOrRd", 
#'                          logo_path = "https://logo.png",
#'                          signe_unite = 2,  # Ajoute le signe "%"
#'                          valeurs_fixes_supp = c("taux_croissance", "population"))
#'
#' @import leaflet sf tmaptools dplyr htmltools
#' @export
#' 
carte_interactive_france <- function(base, 
                                     var_region, 
                                     var_valeurs,  # Liste de plusieurs variables
                                     titre_carte = "Carte Interactive de la France",
                                     couleur_palette = "YlOrRd",
                                     logo_path = NULL,
                                     signe_unite = 0,
                                     valeurs_fixes_supp = NULL) {  # Nouveau paramètre pour ajouter d'autres valeurs fixes
  
  # Charger les limites administratives des régions de France
  url_geojson <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/regions.geojson"
  regions <- st_read(url_geojson, quiet = TRUE)
  
  # Vérifier si la première variable (celle qui colore la carte) est numérique
  if (!is.numeric(base[[var_valeurs[1]]])) {
    stop("La première variable de `var_valeurs` doit être numérique pour la coloration.")
  }
  
  # Assurez-vous que les noms de régions correspondent bien
  base <- base %>%
    rename(region = {{ var_region }}) 
  
  # Joindre les données aux limites régionales
  regions_data <- left_join(regions, base, by = c("nom" = "region"))
  
  # Définir une palette de couleurs dynamique en fonction de la première variable
  palette_couleur <- colorNumeric(palette = couleur_palette, domain = regions_data[[var_valeurs[1]]], na.color = "gray")
  
  # Définition du symbole en fonction du paramètre signe_unite
  symbole <- ifelse(signe_unite == 1, "€", 
                    ifelse(signe_unite == 2, "%", ""))
  
  # Création des étiquettes dynamiques pour chaque région
  labels <- lapply(1:nrow(regions_data), function(i) {
    infos <- paste0("<strong>", regions_data$nom[i], "</strong><br/>")
    
    for (var in var_valeurs) {
      infos <- paste0(infos, var, ": ", round(regions_data[[var]][i], 2), " ", symbole, "<br/>")
    }
    
    return(HTML(infos))
  })
  
  # Création de la carte Leaflet
  carte <- leaflet(regions_data) %>%
    addTiles() %>%
    addPolygons(fillColor = ~palette_couleur(get(var_valeurs[1])),
                weight = 1, 
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.7,
                highlightOptions = highlightOptions(weight = 3, color = "#666", fillOpacity = 0.9, bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "bold"), 
                                            textsize = "14px", 
                                            direction = "auto")) %>%
    addLegend(pal = palette_couleur, values = ~get(var_valeurs[1]), opacity = 0.7, 
              title = titre_carte, position = "bottomright")
  
  # Ajouter un logo en haut à droite si fourni
  if (!is.null(logo_path)) {
    carte <- carte %>%
      addControl(html = sprintf("<img src='%s' width='150px'>", logo_path), position = "topright")
  }
  
  # Construction de l'étiquette fixe
  valeurs_fixes_text <- sapply(seq_len(nrow(regions_data)), function(i) {
    texte <- paste0(round(regions_data[[var_valeurs[1]]][i], 2), " ", symbole)  # Valeur principale avec unité
    if (!is.null(valeurs_fixes_supp)) {
      for (var in valeurs_fixes_supp) {
        texte <- paste0(texte, " - ", round(regions_data[[var]][i], 2))  # Ajout des valeurs supplémentaires
      }
    }
    return(texte)
  })
  
  # Ajouter les valeurs fixes sur la carte (avec valeurs supplémentaires si spécifiées)
  carte <- carte %>%
    addLabelOnlyMarkers(data = regions_data, 
                        lng = st_coordinates(st_centroid(regions_data))[,1], 
                        lat = st_coordinates(st_centroid(regions_data))[,2], 
                        label = valeurs_fixes_text,  # Liste des valeurs fixes
                        labelOptions = labelOptions(noHide = TRUE, 
                                                    direction = "center", 
                                                    textsize = "12px", 
                                                    opacity = 0.8, 
                                                    style = list(
                                                      "color" = "black",
                                                      "font-size" = "11px",
                                                      "font-weight" = "bold",
                                                      "background-color" = "rgba(255,255,255,0.7)",
                                                      "padding" = "2px")))
  
  # Ajouter un titre en haut à gauche
  carte <- carte %>%
    addControl(html = sprintf("<div style='background-color:white; padding:10px; border-radius:5px; 
                               font-size:16px; font-weight:bold; text-align:center;'>
                               %s</div>", titre_carte), 
               position = "topleft")
  
  return(carte)
}