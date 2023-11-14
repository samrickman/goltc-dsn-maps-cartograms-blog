
HTMLWidgets.addPostRenderHandler(function() {
function createLegend(main_svg = "#eng_hex") {
  let vals = ["1 (most)","80","159","238","317 (least)"];
  let colors = ["#800026","#E31A1C","#FD8D3C","#FED976","#FFFFCC"];
  let legend_vals = vals.map((val, i) => {
    return {
      val: val,
      color: colors[i],
    };
  });
  let svg = d3.select(main_svg);
  svg
    .append("div")
    .style("position", "absolute")
    .style("background-color", "white")
    .style("border", "solid")
    .style("border-width", "0px")
    .style("border-radius", "10px")
    .style("padding", "10px")
    .style("font-family", "Arial, Helvetica, sans-serif")
    .style("color", "black")
    .style("width", "110px")
    .style("left", svg.node().getBoundingClientRect().left)
    .style("top", svg.node().getBoundingClientRect().top)
    .attr("id", "legend")
    .append("svg")
    .attr("id", "legend_svg")
    .style("width", "110px")
    .style("height", "200px");
  svg
    .node()
    .insertBefore(d3.select("#legend").node(), svg.node().childNodes[0]);

  let legend = d3.select("#legend_svg");

  let size = 20;
  legend
    .selectAll("symbols")
    .data(legend_vals)
    .enter()
    .append("rect")
    .style("stroke", "black")
    .attr("x", 0)
    .attr("y", function (d, i) {
      return i * size * 1.25;
    })
    .attr("width", size)
    .attr("height", size)
    .style("fill", function (d) {
      return d.color;
    });

  legend
    .selectAll("labels")
    .data(legend_vals)
    .enter()
    .append("text")
    .attr("x", size * 1.2)
    .attr("y", function (d, i) {
      return i * size * 1.25 + size * 0.6;
    })
    .style("fill", function (d) {
      return "black";
    })
    .text(function (d) {
      return d.val;
    })
    .attr("text-anchor", "left")
    .style("alignment-baseline", "middle");

    // do not draw over map and stop tooltip hover
    legend.lower();
}
function highlightPolygons(polygons) {
  // Highlight the required polygons
  polygons.each(function (d) {
    d3.select(this).style("stroke", d.highlight_color);
    if (d.highlight) {
      d3.select(this).style("stroke-width", 3);
      d3.select(this.parentElement).raise();
    }
  });
}

function createToolTip() {
  // Find the map element (eng_hex) and  polygons
  let svg = d3.select("#eng_hex");
  let polygons = svg.selectAll("polygon");
  // Create a container for the hover text
  svg
    .append("div")
    .style("position", "absolute")
    .style("background-color", "black")
    .style("border", "solid")
    .style("border-width", "1px")
    .style("border-radius", "10px")
    .style("padding", "10px")
    .style("font-family", "Arial, Helvetica, sans-serif")
    .style("color", "white")
    .style("visibility", "hidden")
    .attr("id", "hoverText")
    .text("");

  highlightPolygons(polygons);
  // Show tooltip when mouse is over polygon
  polygons.on("mouseover", function (d) {
    // Get mouse position for tooltip
    let mouseOffset = 15; // pixels
    let mousePos = d3.mouse(document.body);
    // Put the correct text in the tooltip
    d3.select("#hoverText")
      .html(d.label)
      .style("left", mousePos[0] + mouseOffset + "px")
      .style("top", mousePos[1] + mouseOffset + "px");
    // Highlight this polygon and make it slightly larger
    d3.select(this)
      .style("stroke", function (d) {
        return d.highlight ? d.highlight_color : "white";
      })
      .attr("transform", "scale(1.2)");
    // Bring to front so highlighted border is visible
    d3.select(this.parentElement).raise();
  });

  // Set each polygon back to normal on mouse out
  polygons.on("mouseout", function (d) {
    d3.select(this)
      .style("stroke", function (d) {
        return d.highlight ? d.highlight_color : "black";
      })
      .attr("transform", "scale(1)");
    highlightPolygons(polygons); // bring highlighted to top
  });
  // Hide tooltip when mouse is not over the map
  svg.on("mouseout", function () {
    d3.select("#hoverText").style("visibility", "hidden");
  });
  // Show tooltip when mouse is over the map
  svg.on("mouseover", function () {
    d3.select("#hoverText").style("visibility", "visible");
  });
}
function drawElements() {
    createToolTip();
    createLegend();
}
drawElements();

});
