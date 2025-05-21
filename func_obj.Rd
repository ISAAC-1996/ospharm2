\name{func_obj}
\alias{func_obj}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
func_obj(region = NULL, marque = NULL, n_auto_adhpha_artic = NULL, date_debut, date_fin, top_n = 20)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{region}{
%%     ~~Describe \code{region} here~~
}
  \item{marque}{
%%     ~~Describe \code{marque} here~~
}
  \item{n_auto_adhpha_artic}{
%%     ~~Describe \code{n_auto_adhpha_artic} here~~
}
  \item{date_debut}{
%%     ~~Describe \code{date_debut} here~~
}
  \item{date_fin}{
%%     ~~Describe \code{date_fin} here~~
}
  \item{top_n}{
%%     ~~Describe \code{top_n} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (region = NULL, marque = NULL, n_auto_adhpha_artic = NULL, 
    date_debut, date_fin, top_n = 20) 
{
    filtre_region <- if (!is.null(region)) {
        sprintf("AND n_auto_adhpha_artic IN (\n      SELECT n_auto_adhpha FROM os_adhpha WHERE region_adhpha = \%d\n    )", 
            region)
    }
    else {
        ""
    }
    filtre_marque <- if (!is.null(marque)) {
        sprintf("AND n_auto_artic_artic IN (\n      SELECT n_auto_artic FROM os_classif WHERE marque LIKE '\%s\%\%'\n    )", 
            marque)
    }
    else {
        ""
    }
    filtre_pharmacie <- if (!is.null(n_auto_adhpha_artic)) {
        sprintf("AND n_auto_adhpha_artic = \%d", n_auto_adhpha_artic)
    }
    else {
        ""
    }
    requete <- sprintf("\n    SELECT TOP \%d\n      code_ean AS EAN,\n      nom_artic AS Produit,\n      n_auto_famille,\n      lib_famille,\n      SUM(qt_vendu_artic) AS [Quantité vendue],\n      ROUND(SUM(ca_ht_artic), 2) AS CA\n    FROM os_stat_artic\n    LEFT JOIN os_artic ON n_auto_artic_artic = n_auto_artic\n    LEFT JOIN os_ean ON n_auto_artic = n_auto_artic_ean\n    LEFT JOIN os_classif ON n_auto_artic_artic = os_classif.n_auto_artic\n    WHERE type_code = 1\n      AND periode BETWEEN \%d AND \%d\n      \%s\n      \%s\n      \%s\n    GROUP BY code_ean, nom_artic, n_auto_famille, lib_famille\n    ORDER BY [Quantité vendue] DESC\n  ", 
        top_n, date_debut, date_fin, filtre_marque, filtre_region, 
        filtre_pharmacie)
    resultat <- executer_sql(requete)
    return(resultat)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
