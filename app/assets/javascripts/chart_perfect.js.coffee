myData = () ->
  series1 = []
  for i in [1...100]
    series1.push({
      x: i, y: 100 / i
    })

  [{
    key: "Series #1",
    values: series1,
    color: "#0000ff"
  }]

$ ->
  if $('svg').size > 0
    nv.addGraph ()->
      chart = nv.models.scatterChart()
        .showDistX(true)
        .showDistY(true)
        .color(d3.scale.category10().range())

      chart.xAxis.tickFormat(d3.format('.02f'))
      chart.yAxis.tickFormat(d3.format('.02f'))

      d3.select("svg")
        .datum($('svg').data('data'))
        .transition().duration(500)
        .call(chart)

      nv.utils.windowResize(chart.update)

      chart
