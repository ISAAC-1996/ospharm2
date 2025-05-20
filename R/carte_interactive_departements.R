#' @title Carte interactive des départements de France avec `leaflet`
#' @description
#' Cette fonction génère une carte interactive des départements de France en utilisant les codes des départements comme clé d'association.
#' Les couleurs sont basées sur une variable principale et peuvent être personnalisées.
#' Il est aussi possible d'afficher des valeurs supplémentaires en info-bulle.
#'
#' @param base Un `data.frame` contenant les données des départements avec les valeurs associées.
#' @param var_code_dept Nom de la colonne contenant les codes des départements.
#' @param var_valeurs Vecteur de noms de colonnes des variables à afficher en info-bulle (`tooltip`).
#'        La **première variable** est utilisée pour la coloration de la carte.
#' @param titre_carte Titre affiché sur la carte (`default = "Carte Interactive des Départements de France"`).
#' @param couleur_palette Palette de couleurs pour `leaflet` (`default = "YlOrRd"`).
#' @param logo_path Chemin ou URL du logo à afficher en haut à droite (`default = NULL`).
#' @param signe_unite Indique l'unité à afficher pour la variable principale (`default = 0`).
#'        - `0` : Pas d'unité
#'        - `1` : Affiche `€`
#'        - `2` : Affiche `%`
#' @param valeurs_fixes_supp Vecteur de noms de colonnes des variables supplémentaires à afficher avec la valeur principale (`default = NULL`).
#'
#' @return Un objet `leaflet` affichant la carte interactive des départements de France.
#'
#' @import leaflet sf dplyr htmltools
#' @export
#'
carte_interactive_departements <- function(base,
                                           var_code_dept,
                                           var_valeurs,
                                           titre_carte = "Carte Interactive des Départements de France",
                                           couleur_palette = "YlOrRd",
                                           logo_path = NULL,
                                           signe_unite = 0,
                                           valeurs_fixes_supp = NULL) {

  # Charger les limites administratives des départements de France
  url_geojson <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson"
  departements <- st_read(url_geojson, quiet = TRUE)

  # Vérifier si la première variable est numérique
  if (!is.numeric(base[[var_valeurs[1]]])) {
    stop("La première variable de `var_valeurs` doit être numérique pour la coloration.")
  }

  # Renommer la colonne des codes des départements
  base <- base %>% rename(code_dept = {{ var_code_dept }})

  # Joindre les données aux limites départementales
  departements_data <- left_join(departements, base, by = c("code" = "code_dept"))

  # Définir une palette de couleurs
  palette_couleur <- colorNumeric(palette = couleur_palette, domain = departements_data[[var_valeurs[1]]], na.color = "gray")

  # Définition du symbole d'unité
  symbole <- ifelse(signe_unite == 1, "€", ifelse(signe_unite == 2, "%", ""))

  # Création des étiquettes dynamiques
  labels <- lapply(1:nrow(departements_data), function(i) {
    infos <- paste0("<strong>Département ", departements_data$code[i], "</strong><br/>")

    for (var in var_valeurs) {
      infos <- paste0(infos, var, ": ", round(departements_data[[var]][i], 2), " ", symbole, "<br/>")
    }
    return(HTML(infos))
  })

  # Création de la carte Leaflet
  carte <- leaflet(departements_data) %>%
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

  # Ajout des valeurs fixes sur la carte
  valeurs_fixes_text <- sapply(seq_len(nrow(departements_data)), function(i) {
    texte <- paste0(round(departements_data[[var_valeurs[1]]][i], 2), " ", symbole)
    if (!is.null(valeurs_fixes_supp)) {
      for (var in valeurs_fixes_supp) {
        texte <- paste0(texte, " - ", round(departements_data[[var]][i], 2))
      }
    }
    return(texte)
  })

  carte <- carte %>%
    addLabelOnlyMarkers(data = departements_data,
                        lng = st_coordinates(st_centroid(departements_data))[,1],
                        lat = st_coordinates(st_centroid(departements_data))[,2],
                        label = valeurs_fixes_text,
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
