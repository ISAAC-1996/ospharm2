#' @name format_excel_personnalise
#' @title Formatage avancé d'un fichier Excel
#' @description
#' Cette fonction prend un dataframe et crée un fichier Excel avec une mise en forme professionnelle
#' incluant : titres colorés et centrés, lignes alternées, bordures, filtres et logo d'entreprise.
#' Toutes les options sont personnalisables par l'utilisateur.
#'
#' @param data Un dataframe à exporter vers Excel
#' @param output_file Chemin du fichier Excel de sortie (défini par l'utilisateur)
#' @param header_bg_color Couleur d'arrière-plan des titres (hex, ex: "#0084ff")
#' @param header_font_color Couleur de police des titres (hex, ex: "#FFFFFF")
#' @param alternate_row_color Couleur des lignes alternées (hex, ex: "#e6f3ff")
#' @param logo_path Chemin vers le logo (URL ou chemin local)
#' @param sheet_name Nom de la feuille de calcul (défaut: "Rapport")
#' @param font_name Nom de la police (défaut: "Montserrat")
#' @param border_color Couleur des bordures (défaut: "#000000")
#' @param report_title Titre du rapport (défaut: NULL)
#'
#' @return Invisible, crée un fichier Excel formaté
#' @export
#' @import openxlsx httr
#'
format_excel_personnalise <- function(data,
                                      output_file,
                                      header_bg_color,
                                      header_font_color,
                                      alternate_row_color,
                                      logo_path = "https://isaac-1996.github.io/Localisation/03_LOGO_OSPHARM.png",
                                      sheet_name = "Rapport",
                                      font_name = "Montserrat",
                                      border_color = "#000000",
                                      report_title = NULL) {

  # Vérification des arguments obligatoires
  if (missing(data)) {
    stop("Argument 'data' manquant : veuillez fournir un dataframe")
  }
  if (missing(output_file)) {
    stop("Argument 'output_file' manquant : veuillez spécifier le nom du fichier de sortie")
  }
  if (missing(header_bg_color)) {
    stop("Argument 'header_bg_color' manquant : veuillez spécifier la couleur d'arrière-plan des titres")
  }
  if (missing(header_font_color)) {
    stop("Argument 'header_font_color' manquant : veuillez spécifier la couleur de police des titres")
  }
  if (missing(alternate_row_color)) {
    stop("Argument 'alternate_row_color' manquant : veuillez spécifier la couleur des lignes alternées")
  }

  # Vérification du format dataframe
  if (!is.data.frame(data)) {
    stop("L'argument 'data' doit être un dataframe")
  }

  # Vérification des packages nécessaires
  if(!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Le package 'openxlsx' est nécessaire. Installez-le avec install.packages('openxlsx')")
  }
  if(!requireNamespace("httr", quietly = TRUE)) {
    stop("Le package 'httr' est nécessaire. Installez-le avec install.packages('httr')")
  }

  # Gérer le logo (URL ou fichier local)
  temp_logo <- NULL
  if (grepl("^http", logo_path)) {
    temp_logo <- tempfile(fileext = ".png")
    response <- tryCatch({
      httr::GET(logo_path, httr::write_disk(temp_logo))
    }, error = function(e) {
      warning("Impossible de télécharger le logo: ", e$message)
      return(NULL)
    })

    if(is.null(response) || httr::status_code(response) != 200) {
      warning("Impossible de télécharger le logo. Le fichier sera créé sans logo.")
      temp_logo <- NULL
    }
  } else if (file.exists(logo_path)) {
    temp_logo <- logo_path
  } else {
    warning("Le fichier logo spécifié n'existe pas. Le fichier sera créé sans logo.")
  }

  # Créer un classeur et une feuille
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, sheet_name)

  # Définir les styles
  header_style <- openxlsx::createStyle(
    fontName = font_name,
    fontSize = 11,
    fontColour = header_font_color,
    halign = "center",
    valign = "center",
    fgFill = header_bg_color,
    border = "TopBottomLeftRight",
    borderColour = border_color,
    wrapText = TRUE,
    textDecoration = "bold"
  )

  alternate_row_style <- openxlsx::createStyle(
    fontName = font_name,
    fontSize = 10,
    fgFill = alternate_row_color,
    border = "TopBottomLeftRight",
    borderColour = border_color
  )

  default_style <- openxlsx::createStyle(
    fontName = font_name,
    fontSize = 10,
    border = "TopBottomLeftRight",
    borderColour = border_color
  )

  # Style pour le titre du rapport
  title_style <- openxlsx::createStyle(
    fontName = font_name,
    fontSize = 14,
    fontColour = "#000000",
    halign = "center",
    valign = "center",
    textDecoration = "bold",
    border = "TopBottomLeftRight",
    borderColour = border_color
  )

  # Modification: le tableau commence à la 6ème ligne
  start_row <- 6

  # Ajouter le logo en haut à gauche
  if(!is.null(temp_logo) && file.exists(temp_logo)) {
    openxlsx::insertImage(wb, sheet_name, file = temp_logo,
                          startRow = 1,  # Première ligne
                          startCol = 1,  # Première colonne
                          width = 2, height = 1, units = "in")
  }

  # Ajouter le titre du rapport si spécifié
  if(!is.null(report_title)) {
    openxlsx::writeData(wb, sheet_name, report_title, startRow = 3, startCol = 1)
    # Fusionner les cellules pour le titre et appliquer le style
    n_cols <- ncol(data)
    openxlsx::mergeCells(wb, sheet_name, cols = 1:n_cols, rows = 3)
    openxlsx::addStyle(wb, sheet_name, style = title_style,
                       rows = 3, cols = 1:n_cols, gridExpand = TRUE)
  }

  # Ajouter les données
  openxlsx::writeData(wb, sheet_name, data, startRow = start_row)

  # Nombre de lignes et colonnes
  n_rows <- nrow(data)
  n_cols <- ncol(data)

  # Appliquer les styles
  openxlsx::addStyle(wb, sheet_name, style = header_style,
                     rows = start_row, cols = 1:n_cols, gridExpand = TRUE)

  # Modification: pas de quadrillage - uniquement les bordures externes et les lignes entre colonnes
  # Pour les lignes de données
  for (row in (start_row+1):(start_row+n_rows)) {
    for (col in 1:n_cols) {
      cell_style <- if ((row - start_row) %% 2 == 0) alternate_row_style else default_style
      openxlsx::addStyle(wb, sheet_name, style = cell_style, rows = row, cols = col)
    }
  }

  # Auto-ajuster la largeur des colonnes
  openxlsx::setColWidths(wb, sheet_name, cols = 1:n_cols, widths = "auto")

  # Ajouter des filtres
  openxlsx::addFilter(wb, sheet_name, rows = start_row, cols = 1:n_cols)

  # Sauvegarder le fichier
  openxlsx::saveWorkbook(wb, output_file, overwrite = TRUE)

  # Nettoyer le fichier temporaire si c'était un téléchargement
  if(!is.null(temp_logo) && temp_logo != logo_path && file.exists(temp_logo)) {
    file.remove(temp_logo)
  }

  message("Fichier Excel créé avec succès: ", output_file)

  return(invisible(output_file))
}
