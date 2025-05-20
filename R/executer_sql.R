#' Exécuter une requête SQL
#'
#' Cette fonction permet d'exécuter facilement une requête SQL sur la base de données
#' en établissant automatiquement la connexion.
#'
#' @param query Chaîne de caractères contenant la requête SQL
#' @param params Liste optionnelle de paramètres pour les requêtes paramétrées
#' @param database Nom de la base de données (par défaut: "OSP_DATASTAT")
#' @return Résultat de la requête (data frame)
#' @export
#' @examples
#' \dontrun{
#' resultats <- executer_sql("SELECT * FROM ma_table WHERE id < ?", params = list(100))
#' }
executer_sql <- function(query, params = NULL, database = "OSP_DATASTAT") {
  # Établir la connexion
  con <- auto_connect_db(database)

  # Exécuter la requête avec gestion d'erreur
  tryCatch({
    if (is.null(params)) {
      resultats <- DBI::dbGetQuery(con, query)
    } else {
      resultats <- DBI::dbGetQuery(con, query, params = params)
    }
    return(resultats)
  }, error = function(e) {
    stop("Erreur lors de l'exécution de la requête: ", e$message)
  }, finally = {
    # Toujours fermer la connexion
    DBI::dbDisconnect(con)
  })
}
