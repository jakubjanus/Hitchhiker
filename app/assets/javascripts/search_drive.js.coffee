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
    console.log "SUBMIT"
    if start_city.name and dest_city.name
      data = $('#search_drive').serializeArray()
      data.push
        name: 'start_location'
        value: new LatLon(start_city.location.Oa, start_city.location.Pa).toJSON()
      data.push
        name: 'dest_location'
        value: new LatLon(dest_city.location.Oa, dest_city.location.Pa).toJSON()
      console.log data
      console.log "#{@baseURL}/drives/search"
      $.get("#{@baseURL}/drives/search", data, 
      (data) ->
        if data.status is "redirect"
          window.location.href = data.path
        else
          console.log data
          )

class SearchSiteEventMenager
  constructor: () ->
  
  addMarkerAdditionActionToElement: (elementId, map, city) =>
    $('#'+elementId).bind("change", (ev) ->
      if $('#'+elementId).val() isnt ""
        map.geocoder.geocode
          address: $('#'+elementId).val(),
          (results, status) ->
            if status is google.maps.GeocoderStatus.OK
              map.mapView.addMarker(results[0].geometry.location)
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
        #console.log start_city.location.Oa
      else
        console.log "NIEEEEE"
  

class SearchDriveInitializator
  constructor: (@baseUrl) ->
    
  initialize: () =>
    @mapView = new MapView()
    @geocoder = new google.maps.Geocoder()
    @eventMenager = new SearchSiteEventMenager()
    start_city = new City()
    dest_city = new City()
    @eventMenager.addMarkerAdditionActionToElement('start_address', @, start_city)
    @eventMenager.addMarkerAdditionActionToElement('dest_address', @, dest_city)
    baseUrl = (/http:\/\/[a-z0-9]+([\-\.:]{1}[a-z0-9]+)*/.exec document.location.href)[0]
    serverSide = new ServerSide(baseUrl)
    @eventMenager.changeSubmitAction('search_submit', start_city, dest_city, ->
      serverSide.submitSearch(start_city, dest_city)
      )


$ ->
  SDInit = new SearchDriveInitializator(document.location.href)
  SDInit.initialize()
  