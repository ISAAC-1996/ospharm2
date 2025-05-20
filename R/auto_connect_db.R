#' Connexion automatique à une base de données SQL
#'
#' Cette fonction permet de se connecter automatiquement à une base de données SQL
#' en utilisant les variables d'environnement configurées.
#'
#' @param database Nom de la base de données (par défaut: "OSP_DATASTAT")
#' @return Un objet de connexion DBI
#' @export
#' @examples
#' \dontrun{
#' con <- auto_connect_db()
#' DBI::dbListTables(con)
#' DBI::dbDisconnect(con)
#' }
auto_connect_db <- function(database = "OSP_DATASTAT") {
  # Vérifier si les variables d'environnement sont définies
  required_vars <- c("sql_driver", "sql_server", "sql_uid", "sql_pwd", "sql_port")
  missing_vars <- required_vars[!nzchar(Sys.getenv(required_vars))]

  if (length(missing_vars) > 0) {
    stop("Variables d'environnement manquantes : ", paste(missing_vars, collapse = ", "))
  }

  # Établir la connexion
  con <- DBI::dbConnect(
    odbc::odbc(),
    Database = database,
    Driver   = Sys.getenv("sql_driver"),
    Server   = Sys.getenv("sql_server"),
    UID      = Sys.getenv("sql_uid"),
    PWD      = Sys.getenv("sql_pwd"),
    Port     = Sys.getenv("sql_port")
  )

  # Retourner l'objet connexion
  return(con)
}
