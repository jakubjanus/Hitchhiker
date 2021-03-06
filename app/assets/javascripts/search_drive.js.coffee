class City
  constructor: ->
    @name
    @location
    
  setName: (name) =>
    @name = name
  
  setLocation: (location) =>
    @location = location
    

class ServerSide
  constructor: (@baseURL) ->
    
  submitSearch: (start_city, dest_city) =>
    if start_city.name and dest_city.name
      data = $('#search_drive').serializeArray()
      
      data.push @.createLocationObject('start_location', start_city)
      data.push @.createLocationObject('dest_location', dest_city)

      $.get("#{@baseURL}/drives/search", data, 
      (data) ->
        resultsView = new SearchResultsView(data)
        resultsView.setView('searchContents')
        )
          
  createLocationObject: (name, city) =>
    res=
      name: name
      value: new LatLon(city.location.$a, city.location.ab).toJSON()
      

class SearchSiteEventMenager
  constructor: () ->
    @startMarker
    @destinationMarker
  
  addMarkerAdditionActionToElement: (elementId, map, city, markerType) =>
    if markerType == 'start'
      marker = @startMarker
    else
      marker = @destinationMarker
    $('#'+elementId).bind("change", (ev) ->
      if $('#'+elementId).val() isnt ""
        map.geocoder.geocode
          address: $('#'+elementId).val(),
          (results, status) ->
            if status is google.maps.GeocoderStatus.OK
              if marker 
                marker.setMap null
              marker = map.mapView.addMarker(results[0].geometry.location)
              city.setName($('#'+elementId).val())
              city.setLocation(results[0].geometry.location)
            else
              new UserValidation().showDialog("Błąd", "Niestety nie znaleziono miejscowości: " +
                $('#'+elementId).val() + ". <br/>Proszę wprowadź dokładniejszą nazwę miejscowości.", true)
              $('#'+elementId).val("")
              
    )
    
  changeSubmitAction: (elementId, start_city, dest_city, onLoad) =>
    $('#'+elementId).click (ev) ->
      ev.preventDefault()
      if start_city.name and dest_city.name
        onLoad.call(@)
      else
        new UserValidation().showDialog("Błąd", "Wprowadź nazwę miejscowości startowej oraz docelowej.", true)
  

class SearchDriveInitializator
  constructor: (@baseUrl) ->
    
  initialize: () =>
    @mapView = new MapView()
    @geocoder = new google.maps.Geocoder()
    @eventMenager = new SearchSiteEventMenager()
    start_city = new City()
    dest_city = new City()
    @eventMenager.addMarkerAdditionActionToElement('start_address', @, start_city, 'start')
    @eventMenager.addMarkerAdditionActionToElement('dest_address', @, dest_city, 'destination')
    baseUrl = (/http:\/\/[a-z0-9]+([\-\.:]{1}[a-z0-9]+)*/.exec document.location.href)[0]
    serverSide = new ServerSide(baseUrl)
    @eventMenager.changeSubmitAction('search_submit', start_city, dest_city, ->
      serverSide.submitSearch(start_city, dest_city)
      )


$ ->
  SDInit = new SearchDriveInitializator(document.location.href)
  SDInit.initialize()
  