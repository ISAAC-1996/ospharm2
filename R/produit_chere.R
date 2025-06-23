#' produit_chere
#'
#' Cette fonction retourne le chiffre d'affaires des produits considérés comme chers
#' sur une période donnée, avec un seuil configurable et un filtre optionnel sur une pharmacie.
#'
#' @param date_debut Entier. Période de début (format YYYYMM, ex: 202401).
#' @param date_fin Entier. Période de fin (format YYYYMM, ex: 202412).
#' @param P_Fab_HT Numeric. Seuil du prix fabricant HT à partir duquel un produit est considéré comme cher. Défaut = 1930.
#' @param n_auto_adhpha Entier (optionnel). Identifiant de la pharmacie. Si NULL, toutes les pharmacies sont considérées.
#'
#' @return Un data.frame avec l'identifiant de la pharmacie et le montant du chiffre d'affaires des produits chers.
#' @export
produit_chere <- function(date_debut, date_fin, P_Fab_HT = 1930, n_auto_adhpha = NULL) {
  library(dplyr)
  library(ospharm2)

  filtre_pharma <- if (is.null(n_auto_adhpha)) "" else sprintf("and b.n_auto_adhpha_artic = %d", n_auto_adhpha)

  requete <- sprintf("
    select
      n_auto_adhpha,
      round(sum(case when c.tva_artic = 1 then ca_ht_artic else 0 end), 2) as [Produit Chere]
    from os_stat_artic b
      left join OSP_DATASTAT.dbo.vuProdAdhpha a on a.n_auto_adhpha = b.n_auto_adhpha_artic
      left join os_artic c on b.n_auto_artic_artic = c.n_auto_artic
      left join hfl_os_tva d on c.tva_artic = d.code_tva and syndic = 1
    where dextinct_adhpha is null
      and periode between %d and %d
      and tva_artic = 1
      and n_auto_artic_artic not in (
        select Id_SQL
        from OSP_PROD.dbo.CEPS_Prix
        where Actif = 1 and P_Fab_HT > %f and Id_SQL is not null
      )
      %s
    group by n_auto_adhpha
  ", date_debut, date_fin, P_Fab_HT, filtre_pharma)

  resultat <- executer_sql(requete)
  return(resultat)
}
