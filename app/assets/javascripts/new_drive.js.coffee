$ ->
  mapV = new Map('start_addr','dest_addr')
  mapV.initializeMap()
  $('#through0').change(mapV.updateMap())
  $('#throughButton').click (ev) ->
    ev.stopImmediatePropagation()
    mapV.mapView.throughPlus()
