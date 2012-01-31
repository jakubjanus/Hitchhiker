class LatLon
  constructor: (@latitude, @longitude) ->

  toJSON: =>
    res = '{ "latitude": "' + @latitude + '" , "longitude": "' + @longitude + '"}'

class UserValidation
  constructor: ->
  
  addFormValidationToElement: (buttonId) =>
    thisVal = @
    $('#'+buttonId).click((ev) ->
      validation = thisVal.validateForm()
      unless validation.cond
        thisVal.showDialog("Błąd walidacji",validation.msg + 'Proszę wypełnij powyższe pola.',true)
        ev.preventDefault()
      )
  
  validateForm: =>
    cond = true
    msg =""
    inputs = ['start_addr', 'dest_addr', 'drive_seats', 'date']
    names = {'start_addr':'adres startowy', 'dest_addr':'adres docelowy', 'drive_seats':'liczba miejsc', 'date':'data'}
    for input in inputs
      unless @.validatePresence(input)
        cond = false
        msg += 'Pole ' + names[input] + ' jest wymagane.<br/>'
    unless @.validateNumberFormat('drive_seats')
      cond = false
      msg += 'Pole ilość miejsc musi być liczbą większą lub równą 0.<br/>'
    result=
      cond: cond
      msg: msg
      
  validatePresence: (elementId) =>
    $('#'+elementId).val() isnt "" 
    
  validateNumberFormat: (elementId) =>
    patt = /^(\d)+$/
    patt.test($('#'+elementId).val())
    
  showDialog: (title, msg, modal) =>
    dialog = '<div id="CNFdialog" title="' + title + '"<p>' + msg + '</p></div>'
    $('#content').append(dialog)
    options =
      modal: modal,
      buttons:
        ok:
          () ->
            $(@).dialog("close")
    $('#CNFdialog').dialog(options)
    
  showCityNotFoundDialog: (city) =>
    @.showDialog("Błąd","Nie znaleziono miasta: " + city + ". Proszę spróbuj ponownie.",true)

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
  constructor: ->
    latlng =  new google.maps.LatLng(52, 19)
    myOptions =
      zoom: 5,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    @map = new google.maps.Map(document.getElementById("map_canvas"),myOptions)
    @directionsDisplay = new google.maps.DirectionsRenderer()
    @directionsDisplay.setMap(@map)
    
  setDirections: (result) =>
    @directionsDisplay.setDirections(result)
    
  addMarker: (position) =>
    option =
      map: @map
      position: position
    marker = new google.maps.Marker(option)
    

class DriveEventMenager
  constructor : (@mapModel, @serverSide) ->
    @throughCount = 0
    
  throughPlus: =>
    @throughCount++
    id = 'through' + @throughCount
    $('#through').append '<input id="'+id+'" name="' + id + '" type="text" autocomplete="off"/><br/>'
    @addAutocompletionToElement(id)
    @.addUpdateActionToElement(id, @mapModel)
    
  addDatePickerToElement: (elementId) =>
    $('#'+elementId).datepicker({monthNames: ['styczeń', 'luty', 'marzec', 'kwiecień', 'maj', 'czerwiec', 
      'lipiec', 'sierpień', 'wrzesień', 'październik', 'listopad', 'grudzień']
      , dayNamesMin: ['Pn', 'Wt', 'Śr', 'Czw', 'Pt', 'So', 'Nd']
      , dateFormat: 'dd-mm-yy'
      , minDate: 0})
  
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
    $('#'+buttonId).bind("autocompletechange", (ev) ->
      if $('#'+buttonId).val() isnt ""
        map.geocoder.geocode
          address: $('#'+buttonId).val()
          (result, status) ->
            if status is google.maps.GeocoderStatus.OK
              map.updateMap()
            else
              dv = new UserValidation()
              dv.showCityNotFoundDialog($('#'+buttonId).val())
              $('#'+buttonId).val("")
    )
      

class NewDriveMapInitializator
  constructor: (@startAddField, @destAddField) ->
    baseUrl = (/http:\/\/[a-z0-9]+([\-\.:]{1}[a-z0-9]+)*/.exec document.location.href)[0]
    @serverSide = new ServerSide(baseUrl)
    @mapView = new MapView()
    @driveEM = new DriveEventMenager(@,@serverSide)
    @userValidation = new UserValidation()
    @startLatLon
    @destLatLon
    @throughLatLon = []
    
  initializeMap: =>
      @geocoder = new google.maps.Geocoder()
      @directionsService = new google.maps.DirectionsService()

      @driveEM.addUpdateActionToElement('start_addr', @)
      @driveEM.addUpdateActionToElement('dest_addr', @)
      @driveEM.addUpdateActionToElement('through0', @)
    
      @driveEM.addAutocompletionToElement('start_addr')
      @driveEM.addAutocompletionToElement('dest_addr')
      @driveEM.addAutocompletionToElement('through0')    
      
      @driveEM.addDatePickerToElement('date') 
      
      @userValidation.addFormValidationToElement('submitButton')
      
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
    
    if startAddress isnt "" and destAddress isnt "" 
      waypoints = @driveEM.getWaypoints()
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
window.MapView = MapView
window.NewDriveMapInitializator = NewDriveMapInitializator
window.UserValidation = UserValidation
