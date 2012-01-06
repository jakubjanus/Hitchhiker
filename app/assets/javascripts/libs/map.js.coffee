class LatLon
  constructor: (@latitude, @longitude) ->

  toJSON: =>
    res = '{ "latitude": "' + @latitude + '" , "longitude": "' + @longitude + '"}'
  
class ServerSide
  constructor: (@baseUrl) ->
    
  loadCities: (name,onLoad) =>
    $.getJSON("#{@baseUrl}/cities/getMatchedCities?name=#{name}", {}, onLoad)
    
  addLatLon: (@start, @throughs, @dest) =>

  submitDrive: =>
    if @start && @dest
      data = $('#new_drive').serializeArray()
      data.push
        name: "startLatLon"
        value: @start.toJSON()

      throughs = @throughs
      tJSONArray = '{ "throughsLatLon" : ['
      coma = ''
      for through in throughs
        tJSONArray = tJSONArray + coma + through.toJSON()
        coma = ','
      
      tJSONArray = tJSONArray + "] }"
      data.push
        name: "throughsLatLon"
        value: tJSONArray
      data.push
        name: "destLatLon"
        value: @dest.toJSON()
    
      $.post("#{@baseUrl}/drives", data, 
      (data) ->
        if data.status is "redirect"
          window.location.href = data.path
          )

class MapView
  constructor: (@mapModel, @serverSide) ->
    latlng =  new google.maps.LatLng(52, 19)
    myOptions =
      zoom: 5,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    @map = new google.maps.Map(document.getElementById("map_canvas"),myOptions)
    @directionsDisplay = new google.maps.DirectionsRenderer()
    @directionsDisplay.setMap(@map)
    @throughCount = 0
    
  setDirections: (result) =>
    @directionsDisplay.setDirections(result)
   
  throughPlus: =>
    @throughCount++
    id = 'through' + @throughCount
    $('#through').append '<input id="'+id+'" name="' + id + '" type="text" autocomplete="off"/><br/>'
    @addAutocompletionToElement(id)
    mapModel = @mapModel
    $('#'+id).change (ev) ->
      mapModel.updateMap()
      
  addAutocompletionToElement: (inputTextId) =>
    serverSide = @serverSide
    $('#'+inputTextId).keyup ->
      serverSide.loadCities($('#'+inputTextId).val(),(data) ->
        cities = []
        for object in data.cities
          cities.push object.name
        $('#'+inputTextId).autocomplete({source: cities})
      )
      
  getWaypoints: =>
    waypoints = []
    i = 0
    while i <= @throughCount
      city = $('#through'+i).val()
      if city? and city isnt ""
        waypoints.push
          location: city
          stopover: true
      i++
    waypoints
      
  addUpdateActionToElement: (buttonId,map) =>
    $('#'+buttonId).change (ev) ->
      map.updateMap()
    $('#'+buttonId).bind("autocompletechange", (ev) ->
      map.updateMap())


class Map
  constructor: (@startAddField, @destAddField) ->
    @throughCount = 0
    baseUrl = (/http:\/\/[a-z0-9]+([\-\.:]{1}[a-z0-9]+)*/.exec document.location.href)[0]
    @serverSide = new ServerSide(baseUrl)
    @mapView = new MapView(@,@serverSide)
    @startLatLon
    @destLatLon
    @throughLatLon = []
    
  initializeMap: =>
      @geocoder = new google.maps.Geocoder()
      @directionsService = new google.maps.DirectionsService()

      @mapView.addUpdateActionToElement('start_addr', @)
      @mapView.addUpdateActionToElement('dest_addr', @)
      @mapView.addUpdateActionToElement('through0', @)
    
      @mapView.addAutocompletionToElement('start_addr')
      @mapView.addAutocompletionToElement('dest_addr')
      @mapView.addAutocompletionToElement('through0')     
      
      serverSide = @serverSide
      $('#new_drive').submit (event) ->
        event.preventDefault()
        serverSide.submitDrive()

  updateMap: =>
    startAddress = $('#'+@startAddField).val()
    destAddress = $('#'+@destAddField).val()
    map = @map
    
    unless startAddress is ""
      @geocoder.geocode
        address: startAddress,
        (results, status) ->
          if @startMarker?
            @startMarker.setMap null
          if status is google.maps.GeocoderStatus.OK
            location = results[0].geometry.location
            @startMarker = new google.maps.Marker(
              map: map
              position: location
            )
          else
            alert "Błąd w przetwarzaniu danych: " + status + 'wartosc pola ' + @startAddField + ' to ' + startAddress
          
    unless destAddress is ""
      @geocoder.geocode
        address: destAddress,
        (results, status) ->
          if @destMarker?
            @destMarker.setMap null
          if status is google.maps.GeocoderStatus.OK
            location = results[0].geometry.location
            @destMarker = new google.maps.Marker(
              map: map
              position: location
            )
          else
            alert "Błąd w przetwarzaniu danych: " + status
    
    if startAddress isnt "" and destAddress isnt ""
      waypoints = @mapView.getWaypoints()
      mapView = @mapView
      serverSide = @serverSide
      geocoder = @geocoder
      mapM = @
      request =
        origin: startAddress,
        destination: destAddress,
        waypoints: waypoints,
        travelMode: google.maps.TravelMode.DRIVING
      @directionsService.route request,
        (result, status) ->
          if status is google.maps.DirectionsStatus.OK
            mapView.setDirections(result)
            throughs = mapM.getLatLngsFromWaypoints(waypoints)
            start = mapM.getLatLngFromCity(startAddress)
            dest = mapM.getLatLngFromCity(destAddress)
            serverSide.addLatLon(start, throughs, dest)
          else
            alert "Błąd w przetwarzaniu danych: " + status
  
  getLatLngsFromWaypoints: (waypoints) =>
    latlngs = []
    geocoder = @geocoder
    if waypoints
      for waypoint in waypoints
        latlngs.push @getLatLngFromCity(waypoint.location)
    latlngs
    
  getLatLngFromCity: (city) =>
    latlng = new LatLon(0,0)
    loc = undefined
    @geocoder.geocode
      address: city
      (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          location = results[0].geometry.location
          latlng.latitude = location.lat()
          latlng.longitude = location.lng()
        else
          console.log "cos poszlo zle"
    latlng
    
window.LatLon = LatLon
window.ServerSide = ServerSide
window.MapView = MapView
window.Map = Map
