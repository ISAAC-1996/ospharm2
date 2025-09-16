#' Statistiques de complétude mensuelle par adhérent
#'
#' Cette fonction exécute une requête SQL intégrée sur la base `os_stat_artic`,
#' calcule le nombre de mois consécutifs de données disponibles par adhérent,
#' et retourne la table complète de complétude sans le pourcentage.
#'
#' @return Un data.frame détaillé avec la complétude mensuelle par adhérent.
#' @export
#'
#' @examples
#' df_stat <- stat_completude()
stat_completude <- function() {
  # Chargement des dépendances internes
  require(dplyr)
  require(lubridate)
  require(purrr)
  require(tidyr)

  # Fonctions internes de conversion période <-> date
  periode_to_date <- function(periode) {
    as.Date(paste0(periode, "01"), format = "%Y%m%d")
  }

  date_to_periode <- function(date) {
    as.integer(format(date, "%Y%m"))
  }

  # Générer une séquence de mois depuis 202201 jusqu'au mois_ref
  generer_mois_attendus_complet <- function(mois_ref, mois_depart = 202201) {
    start_date <- periode_to_date(mois_depart)
    end_date <- periode_to_date(mois_ref)
    sequence <- seq(from = end_date, to = start_date, by = "-1 month")
    sapply(sequence, date_to_periode)
  }

  # Mois de référence = mois précédent
  mois_ref <- date_to_periode(Sys.Date() - months(1))
  mois_attendus <- generer_mois_attendus_complet(mois_ref)

  # Requête SQL pour récupérer les données pertinentes
  df_sql <- executer_sql("
    SELECT periode,
           n_auto_adhpha_artic,
           SUM(ca_ht_artic) AS CA,
           SUM(qt_vendu_artic) AS volume
    FROM os_stat_artic
    WHERE periode >= 202201
      AND n_auto_adhpha_artic IN (
        SELECT n_auto_adhpha
        FROM dbo.vuProdAdhpha
        WHERE dextinct_adhpha IS NULL
      )
    GROUP BY periode, n_auto_adhpha_artic
  ")

  # Calcul de la complétude
  completude_df <- df_sql %>%
    filter(periode <= mois_ref) %>%
    arrange(n_auto_adhpha_artic, desc(periode)) %>%
    group_by(n_auto_adhpha_artic) %>%
    nest() %>%
    mutate(
      periodes_disponibles = map(data, ~ sort(unique(.x$periode), decreasing = TRUE)),
      nb_mois_complet = map_int(periodes_disponibles, function(periodes) {
        count <- 0
        for (mois in mois_attendus) {
          if (mois %in% periodes) {
            count <- count + 1
          } else {
            break
          }
        }
        count
      }),
      periodes_valides = map(periodes_disponibles, function(periodes) {
        mois_valides <- c()
        for (mois in mois_attendus) {
          if (mois %in% periodes) {
            mois_valides <- c(mois_valides, mois)
          } else {
            break
          }
        }
        mois_valides
      }),
      df_complet = pmap(list(data, periodes_valides, nb_mois_complet), function(data, periodes_valides, nb_mois_complet) {
        data %>%
          filter(periode %in% periodes_valides) %>%
          mutate(
            nb_mois_complet = nb_mois_complet,
            completude = paste0("complête sur ", nb_mois_complet, " mois"),
            mois_reference = mois_ref
          )
      })
    ) %>%
    select(df_complet) %>%
    unnest(df_complet)

  return(completude_df)
}
