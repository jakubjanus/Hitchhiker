geocoder = undefined
map = undefined
start_marker = undefined
dest_marker = undefined
directionsDisplay = undefined
directionsService = undefined
startL = undefined
destL = undefined

initialize = -> 
  latlng =  new google.maps.LatLng(52, 19)
  geocoder = new google.maps.Geocoder()
  directionsService = new google.maps.DirectionsService()
  directionsDisplay = new google.maps.DirectionsRenderer()
  myOptions =
    zoom: 5,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  map = new google.maps.Map(document.getElementById("map_canvas"),myOptions)
  directionsDisplay.setMap(map);

window.updateMap = ->
  start_addr = $('#start_addr').val()
  dest_addr = $('#dest_addr').val()
  
  unless start_addr is ""
    geocoder.geocode
      address: start_addr,
      (results, status) ->
        if start_marker?
          start_marker.setMap null
        if status is google.maps.GeocoderStatus.OK
          start_marker = new google.maps.Marker(
            map: map
            position: results[0].geometry.location
          )
        else
          alert "Błąd w przetwarzaniu danych: " + status
    
  unless dest_addr is ""
    geocoder.geocode
      address: dest_addr,
      (results, status) ->
        if dest_marker?
          dest_marker.setMap null
        if status is google.maps.GeocoderStatus.OK
          dest_marker = new google.maps.Marker(
            map: map
            position: results[0].geometry.location
          )
          destL = results[0].geometry.location
        else
          alert "Błąd w przetwarzaniu danych: " + status
          
  if start_addr isnt "" and dest_addr isnt ""
    waypnts = getWaypoints()
    request =
      origin: start_addr,
      destination: dest_addr,
      waypoints: waypnts,
      travelMode: google.maps.TravelMode.DRIVING
    directionsService.route request,
      (result, status) ->
        if status is google.maps.DirectionsStatus.OK
          directionsDisplay.setDirections(result)
        else
          alert "Błąd w przetwarzaniu danych: " + status
    

getWaypoints = ->
  i = 0
  waypoints =[]
  while i<=throughCount
    elid = '#through'+i
    if $(elid).val() isnt ""
      waypoints.push
        location: $(elid).val()
        stopover: true
    i++
  waypoints
  
      
throughCount = 0
window.throughPlus = ->
  throughCount++
  name = 'through'+throughCount
  $('#through').append '<input id="'+name+'" name="' + name + '" type="text"/ onchange="updateMap()"><br/>'
  
$(document).ready initialize

