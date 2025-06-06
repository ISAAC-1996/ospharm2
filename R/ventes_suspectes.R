#' Identifier les pharmacies avec des ventes suspectes
#'
#' Cette fonction identifie les pharmacies ayant des quantités vendues
#' suspectes pour une période donnée.
#'
#' @param periode Un entier représentant la période au format YYYYMM (ex: 202505)
#' @param seuil_suspect Seuil de quantité considérée comme suspecte (défaut: 999)
#'
#' @return Un data.frame contenant les colonnes:
#'   \itemize{
#'     \item dateheure_ecollect
#'     \item n_auto_adhpha
#'     \item LGO
#'     \item typ_vte_ecollect
#'     \item n_auto_artic
#'     \item nom_artic
#'     \item quantite_vendue
#'   }
#'
#' @export
get_ventes_suspectes <- function(periode, seuil_suspect = 999) {

  # Vérification des paramètres
  if (!is.numeric(periode) || length(periode) != 1) {
    stop("La période doit être un entier unique au format YYYYMM (ex: 202505)")
  }

  if (!is.numeric(seuil_suspect) || seuil_suspect < 0) {
    stop("Le seuil suspect doit être un nombre positif")
  }

  # Conversion et validation de la période
  periode_str <- as.character(periode)
  if (nchar(periode_str) != 6) {
    stop("La période doit être au format YYYYMM (6 chiffres)")
  }

  annee <- substr(periode_str, 1, 4)
  mois <- substr(periode_str, 5, 6)

  if (as.numeric(mois) < 1 || as.numeric(mois) > 12) {
    stop("Le mois doit être entre 01 et 12")
  }

  # Détermination des dates de début et fin
  date_debut <- paste0(annee, "-", mois, "-01 00:00:00")
  dernier_jour <- switch(
    mois,
    "01" = "31", "03" = "31", "05" = "31", "07" = "31",
    "08" = "31", "10" = "31", "12" = "31",
    "04" = "30", "06" = "30", "09" = "30", "11" = "30",
    {
      annee_num <- as.numeric(annee)
      if ((annee_num %% 4 == 0 && annee_num %% 100 != 0) || (annee_num %% 400 == 0)) "29" else "28"
    }
  )
  date_fin <- paste0(annee, "-", mois, "-", dernier_jour, " 23:59:59")

  # Requête SQL mise à jour avec colonnes précises
  requete_sql <- paste0(
    "SELECT dateheure_ecollect, n_auto_adhpha_ecollect as n_auto_adhpha, ",
    "ssii_adhpha as LGO, typ_vte_ecollect, n_auto_artic, nom_artic, ",
    "n_auto_ecollect, qt_vendu_lcollect as quantite_vendue ",
    "FROM OSP_datastat.dbo.v_el_collect_ospharm ",
    "LEFT JOIN dbo.os_adhpha ON n_auto_adhpha_ecollect = n_auto_adhpha ",
    "LEFT JOIN dbo.os_artic ON n_auto_artic_lcollect = n_auto_artic ",
    "WHERE qt_vendu_lcollect >= ", seuil_suspect, " ",
    "AND dateheure_ecollect BETWEEN '", date_debut, "' AND '", date_fin, "';"
  )

  if (getOption("ospharm.debug", FALSE)) {
    message("Requête SQL exécutée :")
    message(requete_sql)
  }

  # Exécution et affichage du message
  tryCatch({
    resultat <- executer_sql(requete_sql)

    # Sélection des colonnes demandées (protection si requête modifiée)
    colonnes_voulues <- c("dateheure_ecollect", "n_auto_adhpha", "LGO",
                          "typ_vte_ecollect", "n_auto_artic", "nom_artic", "quantite_vendue")
    resultat <- resultat[, intersect(colonnes_voulues, colnames(resultat))]

    if (nrow(resultat) == 0) {
      message(sprintf("Aucune vente suspecte détectée pour la période %s (%s au %s).", periode_str, date_debut, date_fin))
    } else {
      message(sprintf(" %d ventes suspectes détectées pour la période %s :", nrow(resultat), periode_str))
      print(resultat)
    }

    return(resultat)

  }, error = function(e) {
    stop("Erreur lors de l'exécution de la requête SQL : ", e$message)
  })
}
