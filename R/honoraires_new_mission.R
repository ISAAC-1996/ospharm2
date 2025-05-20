#' Honoraires des nouvelles missions par pharmacie
#'
#' Cette fonction retourne un tableau croisé contenant le volume d'honoraires
#' de nouvelles missions réalisées par pharmacie sur une période donnée.
#'
#' Par défaut, elle retourne **toutes les pharmacies actives**.
#' Si un `groupement` est précisé, le tableau est restreint à ce groupement.
#'
#' @param groupement Entier (optionnel). Identifiant du groupement.
#' @param date_debut Entier. Période de début au format `YYYYMM` (ex: 202401)
#' @param date_fin Entier. Période de fin au format `YYYYMM` (ex: 202404)
#'
#' @return Un tableau `data.frame` de type large (pivoté), une ligne par pharmacie.
#'
#' @examples
#' \dontrun{
#' Honoraires_new_mission(date_debut = 202401, date_fin = 202404)
#' Honoraires_new_mission(groupement = 411, date_debut = 202401, date_fin = 202404)
#' }
#'
#' @export
Honoraires_new_mission <- function(groupement = NULL, date_debut, date_fin) {
  # clause conditionnelle pour le groupement
  filtre_groupement <- if (!is.null(groupement)) {
    sprintf("n_auto_adhpha_B2 IN (
      SELECT n_auto_adhpha FROM dbo.os_grp_adhpha WHERE n_auto_adhgrp = %d
    ) AND", groupement)
  } else {
    ""
  }

  # Requête SQL dynamique
  requete <- sprintf("
    SELECT
      n_auto_adhpha_B2 AS n_auto_adhpha,
      os_acteb2.acteB2 AS honoraires,
      sum(qt_vendu_B2) AS Volume
    FROM os_acteb2
    LEFT JOIN dbo.os_stat_B2 ON os_stat_B2.acteB2 = os_acteb2.acteb2
    WHERE %s
      n_auto_adhpha_B2 IN (
        SELECT n_auto_adhpha FROM dbo.vuProdAdhpha WHERE dextinct_adhpha IS NULL
      )
      AND periode BETWEEN %d AND %d
      AND os_acteb2.acteB2 NOT IN ('HD', 'HG', 'HC', 'HDA', 'HDE', 'HDR')
    GROUP BY os_acteb2.acteB2, n_auto_adhpha_B2
  ", filtre_groupement, date_debut, date_fin)

  # Exécuter la requête
  df <- executer_sql(requete)

  # Transformer en tableau pivoté
  df_pivot <- df %>%
    dplyr::group_by(n_auto_adhpha, honoraires) %>%
    dplyr::summarise(volume_total = sum(Volume), .groups = "drop") %>%
    tidyr::pivot_wider(names_from = honoraires, values_from = volume_total, values_fill = 0)

  return(df_pivot)
}
