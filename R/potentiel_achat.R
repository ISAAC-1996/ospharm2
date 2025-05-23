#' potentiel_achat
#'
#' Calcule le potentiel d’achat et la remise pondérée par pharmacie, cip et ville pour des fournisseurs donnés.
#'
#' @param n_auto_adhgrp (optionnel) Identifiant du groupement de pharmacies (entier). Si NULL, récupère toutes les pharmacies.
#' @param date_debut Date de début au format AAAAMM (entier).
#' @param date_fin Date de fin au format AAAAMM (entier).
#' @param n_auto_adhfour_vect Vecteur des identifiants des fournisseurs (vecteur d'entiers).
#'
#' @return Un data.frame contenant les colonnes Pharmacie, cip, ville, et pour chaque fournisseur sélectionné :
#' POTENTIEL <NOM FOURNISSEUR> n°1 en PFHT et REMISE PONDEREE <NOM FOURNISSEUR>
#' @export
potentiel_achat <- function(n_auto_adhgrp = NULL, date_debut, date_fin, n_auto_adhfour_vect) {
  library(dplyr)
  library(ospharm2)
  library(purrr)

  four_str <- paste(n_auto_adhfour_vect, collapse = ",")

  clause_pharma <- if (is.null(n_auto_adhgrp)) "" else
    sprintf("n_auto_adhpha_artic in (select n_auto_adhpha from dbo.os_grp_adhpha where n_auto_adhgrp = %d) and", n_auto_adhgrp)

  requete <- sprintf("
    select rs_adhpha as 'Pharmacie', cip, nom_ville as ville, nom_adhfour as manufacturer_name,
           ct2.n_auto_adhfour, sum(prix) as price,
           sum(prix * (remise_max * 100)) / sum(prix) as max_discount
    from (
        select distinct(os_labogener_artic.lien2), n_auto_adhpha_artic,
               sum(qt_vendu_artic * pfht) as prix
        from os_stat_artic
        inner join os_labogener_artic on os_stat_artic.n_auto_artic_artic = n_auto_artic
        where %s
              os_labogener_artic.type_artic is null
              and periode between %d and %d
        group by os_labogener_artic.lien2, n_auto_adhpha_artic
    ) as ct1
    inner join (
        select n_auto_adhfour, lien2,
               max(remise) / 100 as remise,
               max(remise_max) / 100 as remise_max,
               max(remise_max2) / 100 as remise_max2
        from os_labogener_artic
        where n_auto_adhfour in (%s) and date_fin_application > getdate()
        group by lien2, n_auto_adhfour
    ) as ct2
    on ct2.lien2 = ct1.lien2
    inner join os_adhfour on os_adhfour.n_auto_adhfour = ct2.n_auto_adhfour
    inner join dbo.vuProdAdhpha on n_auto_adhpha_artic = n_auto_adhpha
    where dextinct_adhpha is null
    group by rs_adhpha, cip, nom_ville, ct2.n_auto_adhfour, nom_adhfour
    order by nom_adhfour",
                     clause_pharma, date_debut, date_fin, four_str
  )

  REMISE <- executer_sql(requete)

  resultat_list <- list()

  for (four in unique(REMISE$manufacturer_name)) {
    four_upper <- toupper(four)
    df_four <- REMISE %>%
      filter(toupper(manufacturer_name) == four_upper) %>%
      group_by(Pharmacie, cip, ville) %>%
      summarise(
        !!paste0("POTENTIEL ", four_upper, " n°1 en PFHT") := sum(price, na.rm = TRUE),
        !!paste0("REMISE PONDEREE ", four_upper) := round(mean(max_discount, na.rm = TRUE), 2),
        .groups = "drop"
      )
    resultat_list[[four]] <- df_four
  }

  ROCADE <- reduce(resultat_list, full_join, by = c("Pharmacie", "cip", "ville"))

  return(ROCADE)
}
