$ ->
  mapV = new NewDriveMapInitializator('start_addr','dest_addr')
  mapV.initializeMap()
  $('#through0').change(mapV.updateMap())
  $('#throughButton').click (ev) ->
    ev.stopImmediatePropagation()
    mapV.driveEM.throughPlus()
