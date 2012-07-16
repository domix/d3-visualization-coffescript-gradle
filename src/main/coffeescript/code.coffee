margin = top: 120, right: 60, bottom: 60, left: 60

width = 1280 - margin.right - margin.left
height = 720 - margin.top - margin.bottom
x = d3.time.scale().range([ 0, width - 60 ])
y = d3.scale.linear().range([ height / 4 - 20, 0 ])


areas = ->
  g = svg.selectAll(".symbol")
  axis.y height / 4 - 21
  g.select(".line").attr "d", (d) ->
    axis d.values

  g.each (d) ->
    y.domain [ 0, d.maxPrice ]
    d3.select(this).select(".line").transition().duration(duration).style("stroke-opacity", 1).each "end", ->
      d3.select(this).style "stroke-opacity", null

    d3.select(this).selectAll(".area").filter((d, i) ->
      i
    ).transition().duration(duration).style("fill-opacity", 1e-6).attr("d", area(d.values)).remove()
    d3.select(this).selectAll(".area").filter((d, i) ->
      not i
    ).transition().duration(duration).style("fill", color(d.key)).attr "d", area(d.values)

  svg.select("defs").transition().duration(duration).remove()
  g.transition().duration(duration).each "end", ->
    d3.select(this).attr "clip-path", null

  setTimeout stackedArea, duration + delay
stackedArea = ->
  stack = d3.layout.stack().values((d) ->
    d.values
  ).x((d) ->
    d.date
  ).y((d) ->
    d.price
  ).out((d, y0, y) ->
    d.price0 = y0
  ).order("reverse")
  stack symbols
  y.domain([ 0, d3.max(symbols[0].values.map((d) ->
    d.price + d.price0
  )) ]).range [ height, 0 ]
  line.y (d) ->
    y d.price0

  area.y0((d) ->
    y d.price0
  ).y1 (d) ->
    y d.price0 + d.price

  t = svg.selectAll(".symbol").transition().duration(duration).attr("transform", "translate(0,0)").each("end", ->
    d3.select(this).attr "transform", null
  )
  t.select("path.area").attr "d", (d) ->
    area d.values

  t.select("path.line").style("stroke-opacity", (d, i) ->
    (if i < 3 then 1e-6 else 1)
  ).attr "d", (d) ->
    line d.values

  t.select("text").attr "transform", (d) ->
    d = d.values[d.values.length - 1]
    "translate(" + (width - 60) + "," + y(d.price / 2 + d.price0) + ")"

  setTimeout streamgraph, duration + delay
streamgraph = ->
  stack = d3.layout.stack().values((d) ->
    d.values
  ).x((d) ->
    d.date
  ).y((d) ->
    d.price
  ).out((d, y0, y) ->
    d.price0 = y0
  ).order("reverse").offset("wiggle")
  stack symbols
  line.y (d) ->
    y d.price0

  t = svg.selectAll(".symbol").transition().duration(duration)
  t.select("path.area").attr "d", (d) ->
    area d.values

  t.select("path.line").style("stroke-opacity", 1e-6).attr "d", (d) ->
    line d.values

  t.select("text").attr "transform", (d) ->
    d = d.values[d.values.length - 1]
    "translate(" + (width - 60) + "," + y(d.price / 2 + d.price0) + ")"

  setTimeout overlappingArea, duration + delay
overlappingArea = ->
  g = svg.selectAll(".symbol")
  line.y (d) ->
    y d.price0 + d.price

  g.select(".line").attr "d", (d) ->
    line d.values

  y.domain([ 0, d3.max(symbols.map((d) ->
    d.maxPrice
  )) ]).range [ height, 0 ]
  area.y0(height).y1 (d) ->
    y d.price

  line.y (d) ->
    y d.price

  t = g.transition().duration(duration)
  t.select(".line").style("stroke-opacity", 1).attr "d", (d) ->
    line d.values

  t.select(".area").style("fill-opacity", .5).attr "d", (d) ->
    area d.values

  t.select("text").attr("dy", ".31em").attr "transform", (d) ->
    d = d.values[d.values.length - 1]
    "translate(" + (width - 60) + "," + y(d.price) + ")"

  svg.append("line").attr("class", "line").attr("x1", 0).attr("x2", width - 60).attr("y1", height).attr("y2", height).style("stroke-opacity", 1e-6).transition().duration(duration).style "stroke-opacity", 1
  setTimeout groupedBar, duration + delay
groupedBar = ->
  x = d3.scale.ordinal().domain(symbols[0].values.map((d) ->
    d.date
  )).rangeBands([ 0, width - 60 ], .1)
  x1 = d3.scale.ordinal().domain(symbols.map((d) ->
    d.key
  )).rangeBands([ 0, x.rangeBand() ])
  g = svg.selectAll(".symbol")
  t = g.transition().duration(duration)
  t.select(".line").style("stroke-opacity", 1e-6).remove()
  t.select(".area").style("fill-opacity", 1e-6).remove()
  g.each (p, j) ->
    d3.select(this).selectAll("rect").data((d) ->
      d.values
    ).enter().append("rect").attr("x", (d) ->
      x(d.date) + x1(p.key)
    ).attr("y", (d) ->
      y d.price
    ).attr("width", x1.rangeBand()).attr("height", (d) ->
      height - y(d.price)
    ).style("fill", color(p.key)).style("fill-opacity", 1e-6).transition().duration(duration).style "fill-opacity", 1

  setTimeout stackedBar, duration + delay
stackedBar = ->
  x.rangeRoundBands [ 0, width - 60 ], .1
  stack = d3.layout.stack().values((d) ->
    d.values
  ).x((d) ->
    d.date
  ).y((d) ->
    d.price
  ).out((d, y0, y) ->
    d.price0 = y0
  ).order("reverse")
  g = svg.selectAll(".symbol")
  stack symbols
  y.domain([ 0, d3.max(symbols[0].values.map((d) ->
    d.price + d.price0
  )) ]).range [ height, 0 ]
  t = g.transition().duration(duration / 2)
  t.select("text").delay(symbols[0].values.length * 10).attr "transform", (d) ->
    d = d.values[d.values.length - 1]
    "translate(" + (width - 60) + "," + y(d.price / 2 + d.price0) + ")"

  t.selectAll("rect").delay((d, i) ->
    i * 10
  ).attr("y", (d) ->
    y d.price0 + d.price
  ).attr("height", (d) ->
    height - y(d.price)
  ).each "end", ->
    d3.select(this).style("stroke", "#fff").style("stroke-opacity", 1e-6).transition().duration(duration / 2).attr("x", (d) ->
      x d.date
    ).attr("width", x.rangeBand()).style "stroke-opacity", 1

  setTimeout transposeBar, duration + symbols[0].values.length * 10 + delay
transposeBar = ->
  x.domain(symbols.map((d) ->
    d.key
  )).rangeRoundBands [ 0, width ], .2
  y.domain [ 0, d3.max(symbols.map((d) ->
    d3.sum d.values.map((d) ->
      d.price
    )
  )) ]
  stack = d3.layout.stack().x((d, i) ->
    i
  ).y((d) ->
    d.price
  ).out((d, y0, y) ->
    d.price0 = y0
  )
  stack d3.zip.apply(null, symbols.map((d) ->
    d.values
  ))
  g = svg.selectAll(".symbol")
  t = g.transition().duration(duration / 2)
  t.selectAll("rect").delay((d, i) ->
    i * 10
  ).attr("y", (d) ->
    y(d.price0 + d.price) - 1
  ).attr("height", (d) ->
    height - y(d.price) + 1
  ).attr("x", (d) ->
    x d.symbol
  ).attr("width", x.rangeBand()).style "stroke-opacity", 1e-6
  t.select("text").attr("x", 0).attr("transform", (d) ->
    "translate(" + (x(d.key) + x.rangeBand() / 2) + "," + height + ")"
  ).attr("dy", "1.31em").each "end", ->
    d3.select(this).attr("x", null).attr "text-anchor", "middle"

  svg.select("line").transition().duration(duration).attr "x2", width
  setTimeout donut, duration / 2 + symbols[0].values.length * 10 + delay
donut = ->
  arcTween = (d) ->
    path = d3.select(this)
    text = d3.select(@parentNode.appendChild(@previousSibling))
    x0 = x(d.data.key)
    y0 = height - y(d.data.sumPrice)
    (t) ->
      r = height / 2 / Math.min(1, t + 1e-3)
      a = Math.cos(t * Math.PI / 2)
      xx = (-r + (a) * (x0 + x.rangeBand()) + (1 - a) * (width + height) / 2)
      yy = ((a) * height + (1 - a) * height / 2)
      f =
        innerRadius: r - x.rangeBand() / (2 - a)
        outerRadius: r
        startAngle: a * (Math.PI / 2 - y0 / r) + (1 - a) * d.startAngle
        endAngle: a * (Math.PI / 2) + (1 - a) * d.endAngle

      path.attr "transform", "translate(" + xx + "," + yy + ")"
      path.attr "d", arc(f)
      text.attr "transform", "translate(" + arc.centroid(f) + ")translate(" + xx + "," + yy + ")rotate(" + ((f.startAngle + f.endAngle) / 2 + 3 * Math.PI / 2) * 180 / Math.PI + ")"
  g = svg.selectAll(".symbol")
  g.selectAll("rect").remove()
  pie = d3.layout.pie().value((d) ->
    d.sumPrice
  )
  arc = d3.svg.arc()
  g.append("path").style("fill", (d) ->
    color d.key
  ).data(->
    pie symbols
  ).transition().duration(duration).tween "arc", arcTween
  g.select("text").transition().duration(duration).attr "dy", ".31em"
  svg.select("line").transition().duration(duration).attr("y1", 2 * height).attr("y2", 2 * height).remove()
  setTimeout donutTransition, duration + delay
donutTransition = ->
  transitionSplit = (d, i) ->
    d3.select(this).transition().duration(duration / 2).tween("arc", tweenArc(
      innerRadius: (if i & 1 then r0 else (r0 + r1) / 2)
      outerRadius: (if i & 1 then (r0 + r1) / 2 else r1)
    )).each "end", transitionRotate
  transitionRotate = (d, i) ->
    a0 = d.next.startAngle + d.next.endAngle
    a1 = d.startAngle - d.endAngle
    d3.select(this).transition().duration(duration / 2).tween("arc", tweenArc(
      startAngle: (a0 + a1) / 2
      endAngle: (a0 - a1) / 2
    )).each "end", transitionResize
  transitionResize = (d, i) ->
    d3.select(this).transition().duration(duration / 2).tween("arc", tweenArc(
      startAngle: d.next.startAngle
      endAngle: d.next.endAngle
    )).each "end", transitionUnite
  transitionUnite = (d, i) ->
    d3.select(this).transition().duration(duration / 2).tween "arc", tweenArc(
      innerRadius: r0
      outerRadius: r1
    )
  tweenArc = (b) ->
    (a) ->
      path = d3.select(this)
      text = d3.select(@nextSibling)
      i = d3.interpolate(a, b)
      for key of b
        a[key] = b[key]
      (t) ->
        a = i(t)
        path.attr "d", arc(a)
        text.attr "transform", "translate(" + arc.centroid(a) + ")translate(" + width / 2 + "," + height / 2 + ")rotate(" + ((a.startAngle + a.endAngle) / 2 + 3 * Math.PI / 2) * 180 / Math.PI + ")"
  r0 = height / 2 - x.rangeBand() / 2
  r1 = height / 2
  pie1 = d3.layout.pie().value((d) ->
    d.sumPrice
  )(symbols)
  pie2 = d3.layout.pie().value((d) ->
    d.maxPrice
  )(symbols)
  arc = d3.svg.arc()
  svg.selectAll(".symbol path").datum((d, i) ->
    d = pie1[i]
    d.innerRadius = r0
    d.outerRadius = r1
    d.next = pie2[i]
    d
  ).each transitionSplit
  setTimeout donutExplode, 2 * duration + delay
donutExplode = ->
  transitionExplode = (d, i) ->
    d.innerRadius = r0a
    d.outerRadius = r1a
    d3.select(this).transition().duration(duration / 2).tween "arc", tweenArc(
      innerRadius: r0b
      outerRadius: r1b
    )
  tweenArc = (b) ->
    (a) ->
      path = d3.select(this)
      text = d3.select(@nextSibling)
      i = d3.interpolate(a, b)
      for key of b
        a[key] = b[key]
      (t) ->
        a = i(t)
        path.attr "d", arc(a)
        text.attr "transform", "translate(" + arc.centroid(a) + ")translate(" + width / 2 + "," + height / 2 + ")rotate(" + ((a.startAngle + a.endAngle) / 2 + 3 * Math.PI / 2) * 180 / Math.PI + ")"
  r0a = height / 2 - x.rangeBand() / 2
  r1a = height / 2
  r0b = 2 * height - x.rangeBand() / 2
  r1b = 2 * height
  arc = d3.svg.arc()
  svg.selectAll(".symbol path").each transitionExplode
  #setTimeout startViz, 2 * duration + delay

horizons = ->
  svg.insert("defs", ".symbol").append("clipPath").attr("id", "clip").append("rect").attr("width", width).attr "height", height / 4 - 20
  color = d3.scale.ordinal().range([ "#c6dbef", "#9ecae1", "#6baed6" ])
  g = svg.selectAll(".symbol").attr("clip-path", "url(#clip)")
  g.select("circle").transition().duration(duration).attr("transform", (d) ->
    "translate(" + (width - 60) + "," + (-height / 4) + ")"
  ).remove()
  g.select("text").transition().duration(duration).attr("transform", (d) ->
    "translate(" + (width - 60) + "," + (height / 4 - 20) + ")"
  ).attr "dy", "0em"
  g.each (d) ->
    y.domain [ 0, d.maxPrice ]
    d3.select(this).selectAll(".area").data(d3.range(3)).enter().insert("path", ".line").attr("class", "area").attr("transform", (d) ->
      "translate(0," + (d * (height / 4 - 20)) + ")"
    ).attr("d", area(d.values)).style("fill", (d, i) ->
      color i
    ).style "fill-opacity", 1e-6
    y.domain [ 0, d.maxPrice / 3 ]
    d3.select(this).selectAll(".line").transition().duration(duration).attr("d", line(d.values)).style "stroke-opacity", 1e-6
    d3.select(this).selectAll(".area").transition().duration(duration).style("fill-opacity", 1).attr("d", area(d.values)).each "end", ->
      d3.select(this).style "fill-opacity", null

  setTimeout areas, duration + delay

lines = ->
  draw = (k) ->
    g.each (d) ->
      e = d3.select(this)
      y.domain [ 0, d.maxPrice ]
      e.select("path").attr "d", (d) ->
        line d.values.slice(0, k + 1)

      e.selectAll("circle, text").data((d) ->
        [ d.values[k], d.values[k] ]
      ).attr "transform", (d) ->
        "translate(" + x(d.date) + "," + y(d.price) + ")"
  g = svg.selectAll(".symbol").attr("transform", (d, i) ->
    "translate(0," + i * height / 4 + ")"
  )
  g.each (d) ->
    e = d3.select(this)
    e.append("path").attr "class", "line"
    e.append("circle").attr("r", 5).style("fill", (d) ->
      color d.key
    ).style("stroke", "#000").style "stroke-width", "2px"
    e.append("text").attr("x", 12).attr("dy", ".31em").text d.key

  k = 1
  n = symbols[0].values.length
  d3.timer ->
    draw k
    if (k += 2) >= n - 1
      draw n - 1
      setTimeout horizons, 500
      true

duration = 1500
delay = 500
color = d3.scale.category10()
svg = d3.select("body").append("svg").attr("width", width + margin.right + margin.left).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")
stocks = undefined
symbols = undefined
line = d3.svg.line().interpolate("basis").x((d) ->
    x d.date
).y((d) ->
    y d.price
)
axis = d3.svg.line().interpolate("basis").x((d) ->
    x d.date
).y(height)
area = d3.svg.area().interpolate("basis").x((d) ->
    x d.date
).y0(height / 4 - 20).y1((d) ->
    y d.price
)

d3.csv "data/stocks.csv", (data) ->
    parse = d3.time.format("%b %Y").parse
    filter = AAPL: 1, AMZN: 1, MSFT: 1,IBM: 1

    stocks = data.filter((d) ->
      d.symbol of filter
    )
    symbols = d3.nest().key((d) ->
      d.symbol
    ).entries(stocks)
    symbols.forEach (s) ->
      s.values.forEach (d) ->
        d.date = parse(d.date)
        d.price = +d.price

      s.maxPrice = d3.max(s.values, (d) ->
        d.price
      )
      s.sumPrice = d3.sum(s.values, (d) ->
        d.price
      )

    symbols.sort (a, b) ->
      b.maxPrice - a.maxPrice

    x.domain [ d3.min(symbols, (d) ->
      d.values[0].date
    ), d3.max(symbols, (d) ->
      d.values[d.values.length - 1].date
    ) ]
    g = svg.selectAll("g").data(symbols).enter().append("g").attr("class", "symbol")
    setTimeout lines, duration
#startViz = ->
  

