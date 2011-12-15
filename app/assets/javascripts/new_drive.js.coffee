class ServerSide
  constructor: (@baseUrl) ->
    
  loadCities: (name,onLoad) =>
    $.getJSON("#{@baseUrl}/cities/getMatchedCities?name=#{name}", {}, onLoad)
    
  submitDrive: (onConfirm, startAddr, destAddr, thrs, date, seats) =>
    $.post("#{@baseUrl}/drives", {
      start_address:startAddr
      #through0:kielce
   #   destination_address:destAddr,
   #   drive[seats]:seats,
   #   drive[date(1i)]:date[0],
   #   drive[date(2i)]:date[1],
   #   drive[date(3i)]:date[2],
   #   commit:"dodaj trasę"
    }, onConfirm)

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
    $('#through').append '<input id="'+id+'" name="' + id + '" type="text"/><br/>'
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

class LatLon
  constructor: (@latitude, @longitude) ->

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
        serverSide.submitDrive(null, "wrocław", "warszawa", [], [], 2)

  updateMap: =>
    console.log "upd"
    startAddress = $('#'+@startAddField).val()
    destAddress = $('#'+@destAddField).val()
    map = @map
    
    unless startAddress is ""
      console.log "update startaddr"
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
            @startLatLon = new LatLon(location.lat(), location.lng())
            console.log @startLatLon
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
            @destLatLon = new LatLon(location.lat(), location.lng())
          else
            alert "Błąd w przetwarzaniu danych: " + status
    
    if startAddress isnt "" and destAddress isnt ""
      waypoints = @mapView.getWaypoints()
      console.log waypoints
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
            mapM.getLatLngsFromWaypoints(waypoints)
          else
            alert "Błąd w przetwarzaniu danych: " + status
  
  getLatLngsFromWaypoints: (waypoints) =>
    console.log "get latlns th"
    latlngs = []
    geocoder = @geocoder
    if waypoints
      for waypoint in waypoints
        geocoder.geocode
          address: waypoint.location,
          (results, status) ->
            if status is google.maps.GeocoderStatus.OK
              location = results[0].geometry.location
              latlngs.push new LatLon(location.lat(), location.lng())
            else
              console.log "cos poszlo zle"
    console.log latlngs
    latlngs
  
  addLatLongParamsOnSabmit: (submitId) =>
    

$ ->
  mapV = new Map('start_addr','dest_addr')
  mapV.initializeMap()
  $('#through0').change(mapV.updateMap())
  $('#throughButton').click (ev) ->
    ev.stopImmediatePropagation()
    mapV.mapView.throughPlus()
