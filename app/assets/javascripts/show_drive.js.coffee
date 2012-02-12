class SD_ServerSide
  constructor: (@baseUrl) ->
    
  getDriveData: (onLoad) =>
    $.getJSON("#{@baseUrl}", {}, onLoad)

class ShowDriveMapInitializator
  constructor: ->
  
  initializeMap: =>
    @mapView = new MapView()
    @geocoder = new google.maps.Geocoder()
    @directionService = new google.maps.DirectionsService()
    @serverSide = new SD_ServerSide(document.location.href)
    directionService = @directionService
    mapView = @mapView
    mapInit = @
    @serverSide.getDriveData( (data) ->
      waypoints = mapInit.convertWaypoints(data.throughs)
      request =
        origin: data.start_add,
        destination: data.destination_add,
        waypoints: waypoints,
        travelMode: google.maps.TravelMode.DRIVING
      directionService.route request,
        (result, status) ->
          if status is google.maps.DirectionsStatus.OK
            mapView.setDirections(result)
          else
             alert "Błąd w przetwarzaniu danych: " + status
      )
      
  convertWaypoints: (waypoints) =>
    result = []
    for waypoint in waypoints
      result.push 
        location: waypoint
        stopover: true
    result

$ ->
  mapInit = new ShowDriveMapInitializator()
  mapInit.initializeMap()
