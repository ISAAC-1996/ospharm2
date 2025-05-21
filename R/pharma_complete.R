#' Obtenir les pharmacies complètes sur une période définie
#'
#' La fonction `pharma_complete_12()` retourne les pharmacies considérées comme **complètes**
#' sur une période donnée (définie par une date de début et une date de fin au format `YYYYMM`),
#' ainsi que leurs indicateurs économiques principaux (CA HT, CA TTC, nombre de ventes, quantités vendues).
#'
#' Elle permet également de filtrer les résultats par un **code groupement** (`n_auto_adhgrp`).
#'
#' - Si aucun groupement n'est spécifié, la fonction retourne **l’ensemble** des pharmacies complètes sur la période.
#' - Les noms des colonnes de sortie sont générés dynamiquement à partir des dates renseignées.
#'
#' @param date_debut Entier. Date de début au format `YYYYMM` (ex : 202401).
#' @param date_fin Entier. Date de fin au format `YYYYMM` (ex : 202412). Doit être ≥ à `date_debut`.
#' @param code_groupement Entier optionnel. Code du groupement (`n_auto_adhgrp`). Par défaut : `NULL` (toutes les pharmacies).
#'
#' @return Un `data.frame` listant les pharmacies complètes sur la période indiquée, avec leurs données consolidées.
#'
#' @examples
#' \dontrun{
#' pharma_complete_12(202401, 202412) # Toutes les pharmacies complètes en 2024
#' pharma_complete_12(202301, 202312, code_groupement = 411) # Uniquement le groupement 411
#' }
#'
#' @export
pharma_complete_12 <- function(date_debut, date_fin, code_groupement = NULL) {
  if (missing(date_debut) || missing(date_fin)) {
    stop("Merci de spécifier une date de début et une date de fin au format YYYYMM.")
  }

  if (date_fin < date_debut) {
    stop("La date de fin doit être supérieure ou égale à la date de début.")
  }

  # Générer dynamiquement les noms des colonnes
  periode_label <- paste0(date_debut, " - ", date_fin)
  nom_ca_ht <- paste0("CA HT ", periode_label)
  nom_ca_ttc <- paste0("CA TTC ", periode_label)
  nom_nb_vente <- paste0("Nombre de vente de ", periode_label)
  nom_qte <- paste0("Quantité vendu de ", periode_label)

  # Clause conditionnelle pour le groupement
  clause_groupement <- if (!is.null(code_groupement)) {
    paste0("AND a.n_auto_adhgrp = ", code_groupement)
  } else {
    ""
  }

  # Construire la requête SQL dynamiquement
  requete <- sprintf("
    SELECT
      n_auto_adhpha_global AS n_auto_adhpha,
      nom_syndicat,
      cip,
      rs_adhpha,
      nom_ville,
      cp_ville,
      ssii_adhpha,
      ROUND(SUM(ca_ht_global), 2) AS [%s],
      ROUND(SUM(ca_ttc_global), 2) AS [%s],
      SUM(nb_vte_global) AS [%s],
      SUM(qt_vendu_global) AS [%s]
    FROM dbo.os_stat_global
    LEFT JOIN dbo.vuProdAdhpha ON n_auto_adhpha_global = n_auto_adhpha
    LEFT JOIN dbo.os_grp_adhpha a ON n_auto_adhpha_global = a.n_auto_adhpha
    LEFT JOIN dbo.os_adhgrp b ON a.n_auto_adhgrp = b.n_auto_adhgrp
    LEFT JOIN dbo.os_syndicat ON syndic_adhpha = n_auto_syndicat
    WHERE dextinct_adhpha IS NULL
      AND n_auto_adhpha_global NOT IN (
        SELECT n_auto_adhpha
        FROM dbo.os_completudepha
        WHERE periode_completudepha BETWEEN %d AND %d
          AND moisok_completudepha IN (0, 8)
      )
      AND periode BETWEEN %d AND %d
      %s
    GROUP BY
      n_auto_adhpha_global, nom_syndicat, cip, rs_adhpha, nom_ville, cp_ville, ssii_adhpha
  ",
                     nom_ca_ht, nom_ca_ttc, nom_nb_vente, nom_qte,
                     date_debut, date_fin,
                     date_debut, date_fin,
                     clause_groupement
  )

  # Exécuter la requête SQL
  resultat <- executer_sql(requete)
  return(resultat)
}
