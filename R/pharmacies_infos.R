#' Informations sur les pharmacies d’un groupement (ou toutes)
#'
#' Cette fonction récupère les informations principales des pharmacies,
#' avec ou sans filtrage par groupement.
#'
#' @param groupement Entier (optionnel). Identifiant du groupement.
#' Par défaut (`NULL`), la fonction renvoie toutes les pharmacies.
#'
#' @return Un data.frame avec les colonnes :
#' - `n_auto_adhpha` : identifiant de la pharmacie
#' - `PHARMACIE` : nom de la pharmacie
#' - `CIP` : code CIP
#' - `nom_region` : région
#' - `nom_ville` : ville
#' - `cp_ville` : code postal
#' - `mail` : email
#'
#' @examples
#' \dontrun{
#' pharmacies_infos()        # Toutes les pharmacies
#' pharmacies_infos(164)     # Pharmacies du groupement 164
#' }
#'
#' @export
pharmacies_infos <- function(groupement = NULL) {

  # Partie conditionnelle pour le filtrage
  condition_groupement <- if (!is.null(groupement)) {
    sprintf("AND n_auto_adhpha IN (
      SELECT n_auto_adhpha
      FROM dbo.os_grp_adhpha
      WHERE n_auto_adhgrp = %d
    )", groupement)
  } else {
    ""
  }

  # Construction de la requête SQL complète
  requete <- sprintf("
    SELECT n_auto_adhpha,
           rs_adhpha AS PHARMACIE,
           cip AS CIP,
           nom_region,
           nom_ville,
           cp_ville,
           mail
    FROM dbo.vuProdAdhpha
    LEFT JOIN dbo.os_region ON region_adhpha = n_auto_region
    LEFT JOIN ospharea_adherents ON finess_adhpha = finess
    WHERE dextinct_adhpha IS NULL and n_auto_adhpha >1
    %s
  ", condition_groupement)

  resultat <- executer_sql(requete)
  return(resultat)
}

