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
       background-color: rgba(255,255,255,0.8); border-radius:10px; padding:15px; font-family:monospace; font-size:14px;">
       <div id="doc-content" style="white-space: pre-wrap;"></div>
     </div>'
  )

  nodes <- data.frame(
    name = c("OSPHARM", fonctions),
    group = c(0, rep(1, length(fonctions))),
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

  select_html <- paste0(
    '<div style="padding:10px; background-color:#e6f3ff;">
       <label><strong>🔍 Sélectionner une fonction :</strong></label>
       <select id="searchNode" style="margin-left:10px; width:220px;">
         <option value="">-- Choisir une fonction --</option>',
    paste0('<option value="', fonctions, '">', fonctions, '</option>', collapse = ""),
    '</select>
     </div>'
  )

  network <- htmlwidgets::prependContent(network, htmltools::HTML(select_html))
  network <- htmlwidgets::appendContent(network, htmltools::HTML(doc_html))

  js_descriptions <- paste0("var docData = {",
                            paste0('"', fonctions, '": `', gsub("`", "'", descriptions), '`', collapse = ","),
                            "};")

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

      document.getElementById('searchNode').addEventListener('change', function() {
        var selected = this.value.toLowerCase();

        d3.select(el).selectAll('.node circle')
          .style('stroke', function(d) {
            return d.name.toLowerCase() === selected ? 'red' : null;
          })
          .style('stroke-width', function(d) {
            return d.name.toLowerCase() === selected ? 5 : 1.5;
          })
          .style('r', function(d) {
            return d.name.toLowerCase() === selected ? 20 : d.size / 10;
          });

        var docBox = document.getElementById('doc-content');
        if (selected && docData[selected]) {
          docBox.innerText = docData[selected];
        } else {
          docBox.innerText = '';
        }
      });

      d3.select(el).select('.network-title').style('visibility', 'hidden');
    }
  "))

  saveWidget(network, "ospharm_network.html", selfcontained = TRUE)
  network
}
