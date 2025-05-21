#' Visualisation interactive des fonctions du package ospharm2 avec recherche intelligente
#'
#' La fonction `refresh_ospharm_network()` génère un réseau interactif des fonctions exportées du package `ospharm2`, en les reliant à un nœud central nommé "OSPHARM".
#' Elle inclut une interface web enrichie avec champ de recherche autocomplete, survol, clic, et affichage dynamique de la documentation de chaque fonction si disponible.
#'
#' Un panneau latéral s’affiche à droite avec la documentation des fonctions, extraite depuis des fichiers `.txt` stockés dans le dossier local `doc/`, portant le nom exact de chaque fonction.
#'
#' Chaque fonction possède désormais un groupe unique, permettant une meilleure différenciation visuelle dans le graphe.
#'
#' Le fichier HTML résultant (`ospharm_network.html`) est autoportant et peut être ouvert directement dans un navigateur.
#'
#' @details
#' - Les fichiers de documentation doivent être présents dans un dossier `doc/`, avec un fichier par fonction (ex : `doc/ma_fonction.txt`).
#' - Le champ de recherche suggère automatiquement les fonctions selon la saisie utilisateur.
#' - Un clic sur un nœud ou une sélection depuis le champ de recherche déclenche la mise en évidence du nœud et l’affichage de sa documentation.
#'
#' @return Un objet `htmlwidget` affichant le réseau interactif dans RStudio ou un navigateur.
#' @export
#'
#' @examples
#' \dontrun{
#' refresh_ospharm_network()
#' # Ouvre le fichier "ospharm_network.html" dans un navigateur
#' }
refresh_ospharm_network <- function() {
  library(networkD3)
  library(htmlwidgets)
  library(ospharm2)
  fonctions <- getNamespaceExports("ospharm2")
  doc_dir <- "doc"
  descriptions <- sapply(fonctions, function(f) {
    path <- file.path(doc_dir, paste0(f, ".txt"))
    if (file.exists(path)) {
      paste(readLines(path, warn = FALSE), collapse = "\n")
    } else {
      "Aucune documentation disponible."
    }
  }, USE.NAMES = TRUE)
  doc_html <- paste0(
    '<div id="doc-panel" style="position:absolute; top:60px; right:20px; width:40%; height:85%; overflow:auto;
       background-color: rgba(255,255,255,0.8); border-radius:10px; padding:15px; font-family:monospace; font-size:14px; display:none;">
       <div id="doc-content" style="white-space: pre-wrap;"></div>
     </div>'
  )

  # Création d'un groupe différent pour chaque fonction
  nodes <- data.frame(
    name = c("OSPHARM", fonctions),
    group = c(0, 1:length(fonctions)),  # Chaque fonction a son propre groupe
    size = c(200, rep(80, length(fonctions))),
    stringsAsFactors = FALSE
  )

  links <- data.frame(
    source = 1:length(fonctions),
    target = rep(0, length(fonctions))
  )

  network <- forceNetwork(
    Links = links,
    Nodes = nodes,
    Source = "source",
    Target = "target",
    NodeID = "name",
    Group = "group",
    Nodesize = "size",
    fontSize = 18,
    opacity = 1,
    zoom = TRUE,
    charge = -1000,
    linkDistance = 250,
    opacityNoHover = 1,
    clickAction = NULL
  )

  # Remplacer le menu déroulant par un champ autocomplete
  autocomplete_html <- paste0('
    <div style="padding:10px; background-color:#e6f3ff; position:relative;">
      <label><strong>🔍 Rechercher une fonction :</strong></label>
      <input type="text" id="searchInput" placeholder="Taper le nom d\'une fonction..." style="margin-left:10px; width:220px; padding:5px;">
      <div id="autocompleteList" style="position:absolute; z-index:999; background-color:white; width:220px; max-height:200px; overflow-y:auto; display:none; left:188px; border:1px solid #ddd; box-shadow:0 2px 4px rgba(0,0,0,0.2);"></div>
    </div>
  ')

  network <- htmlwidgets::prependContent(network, htmltools::HTML(autocomplete_html))
  network <- htmlwidgets::appendContent(network, htmltools::HTML(doc_html))

  js_descriptions <- paste0("var docData = {",
                            paste0('"', fonctions, '": `', gsub("`", "'", descriptions), '`', collapse = ","),
                            "};")

  js_functions_array <- paste0("var functions = [",
                               paste0('"', fonctions, '"', collapse = ", "),
                               "];")

  network <- htmlwidgets::onRender(network, paste0("
    function(el, x) {
      d3.select(el).select('svg')
        .style('background-color', '#99e6ff');

      d3.select(el).selectAll('.node text')
        .style('font-size', '14px')
        .style('fill', '#333333')
        .style('font-weight', 'bold')
        .style('opacity', 1)
        .attr('dx', function(d) { return d.group === 0 ? 0 : 15; })
        .attr('dy', function(d) { return d.group === 0 ? 0 : 0; })
        .style('pointer-events', 'none');

      ", js_descriptions, "
      ", js_functions_array, "

      // Fonction pour mettre à jour l'affichage d'un nœud sélectionné
      function updateSelectedNode(selectedName) {
        selectedName = selectedName ? selectedName.toLowerCase() : '';

        // Réinitialiser tous les nœuds
        d3.select(el).selectAll('.node circle')
          .style('stroke', null)
          .style('stroke-width', 1.5)
          .style('r', function(d) { return d.size / 10; });

        // Mettre en évidence le nœud sélectionné
        if (selectedName) {
          d3.select(el).selectAll('.node circle')
            .filter(function(d) { return d.name.toLowerCase() === selectedName; })
            .style('stroke', 'red')
            .style('stroke-width', 5)
            .style('r', 20);

          // Afficher la documentation
          var docPanel = document.getElementById('doc-panel');
          var docBox = document.getElementById('doc-content');
          if (docData[selectedName]) {
            docBox.innerText = docData[selectedName];
            docPanel.style.display = 'block';
          } else {
            docBox.innerText = '';
            docPanel.style.display = 'none';
          }
        } else {
          // Masquer la documentation
          document.getElementById('doc-panel').style.display = 'none';
          document.getElementById('doc-content').innerText = '';
        }
      }

      // Configurer l'autocomplétion
      var input = document.getElementById('searchInput');
      var autocompleteList = document.getElementById('autocompleteList');

      input.addEventListener('input', function() {
        var inputValue = this.value.toLowerCase();
        autocompleteList.innerHTML = '';

        if (inputValue.length > 0) {
          var matches = functions.filter(function(func) {
            return func.toLowerCase().indexOf(inputValue) !== -1;
          });

          if (matches.length > 0) {
            autocompleteList.style.display = 'block';
            matches.forEach(function(match) {
              var item = document.createElement('div');
              item.innerHTML = match;
              item.style.padding = '8px';
              item.style.cursor = 'pointer';

              item.addEventListener('mouseover', function() {
                this.style.backgroundColor = '#f1f1f1';
              });

              item.addEventListener('mouseout', function() {
                this.style.backgroundColor = 'white';
              });

              item.addEventListener('click', function() {
                input.value = match;
                autocompleteList.style.display = 'none';
                updateSelectedNode(match);
              });

              autocompleteList.appendChild(item);
            });
          } else {
            autocompleteList.style.display = 'none';
          }
        } else {
          autocompleteList.style.display = 'none';
          updateSelectedNode('');
        }
      });

      // Gérer le clic en dehors de la liste pour la fermer
      document.addEventListener('click', function(e) {
        if (e.target !== input && e.target !== autocompleteList) {
          autocompleteList.style.display = 'none';
        }
      });

      // Gérer l'événement d'appui sur la touche Entrée
      input.addEventListener('keyup', function(e) {
        if (e.key === 'Enter') {
          var firstMatch = functions.find(function(func) {
            return func.toLowerCase().indexOf(input.value.toLowerCase()) !== -1;
          });

          if (firstMatch) {
            input.value = firstMatch;
            autocompleteList.style.display = 'none';
            updateSelectedNode(firstMatch);
          }
        }
      });

      // Ajouter l'événement de clic sur les nœuds
      d3.select(el).selectAll('.node').on('click', function(d) {
        var nodeName = d.name;

        if (nodeName.toLowerCase() !== 'ospharm') {
          input.value = nodeName;
          updateSelectedNode(nodeName);
        } else {
          input.value = '';
          updateSelectedNode('');
        }
      });

      d3.select(el).select('.network-title').style('visibility', 'hidden');
    }
  "))

  saveWidget(network, "ospharm_network.html", selfcontained = TRUE)
  network
}
