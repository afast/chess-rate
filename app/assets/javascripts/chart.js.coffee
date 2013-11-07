$ ->
  if $('#chart svg').size() > 0
    nv.addGraph ()->
      chart = nv.models.scatterChart()
        .showDistX(true)
        .showDistY(true)
        .color(d3.scale.category10().range())

      chart.xAxis.tickFormat(d3.format('.02f'))
      chart.yAxis.tickFormat(d3.format('.02f'))

      d3.select("svg")
        .datum(data)
        .transition().duration(500)
        .call(chart)

      nv.utils.windowResize(chart.update)

      chart
