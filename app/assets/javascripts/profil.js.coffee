class ProfileEditValidator
  constructor: () ->
  
  validateForm: () =>
    
    
  validateName: (name) =>
    (/^[(A-Z)|(a-z)]+$/).test(name)
    
  validateEmail: (email) =>
    (/^[0-9a-z][0-9a-z.+]+[0-9a-z]@[0-9a-z][0-9a-z.-]+[0-9a-z]$/).test(email)
    
  validatePhoneNumber: (number) =>
    (/^([+]*[\d\d]*)[-]*(\d\d\d)[-]*(\d\d\d)[-]*(\d\d\d)$/).test(number)

class ProfileServerSide
  constructor: (@baseUrl) ->
    
  changePersonalUserData: (onLoad) =>
    data = @.getData()
    $.get("#{@baseUrl}/home/profil/edit_user", data, onLoad)
    
  getData: =>
    data = []
    data.push @.getValue('first_name', '_value_input')
    data.push @.getValue('last_name', '_value_input')
    data.push @.getValue('email', '_value_input')
    data.push @.getValue('alt_email', '_value_input')
    data.push @.getValue('phone_number', '_value_input')
    data.push @.getValue('birthdate', '_value_input')
    data.push @.getValue('hometown', '_value_input')
    data.push @.getValue('email_visibility', '_select')
    data.push @.getValue('alt_email_visibility', '_select')
    data.push @.getValue('phone_number_visibility', '_select')
    data.push @.getValue('hometown_visibility', '_select')
    data
    
  getValue: (atr, suffix) =>
    unless $('#'+atr+suffix).val() is 'brak danych'
      res=
        name: atr
        value: $('#'+atr+suffix).val()

class ProfileView
  constructor: (@serverSide) ->
    @name = $.trim($('#name_value').text())
    @first_name = $.trim($('#first_name_value').text())
    @last_name = $.trim($('#last_name_value').text())
    @email = $.trim($('#email_value').text())
    @alt_email = $.trim($('#alt_email_value').text())
    @phone_number = $.trim($('#phone_number_value').text())
    @birthdate = $.trim($('#birthdate_value').text())
    @hometown = $.trim($('#hometown_value').text())
    @email_visibility = $.trim($('#email_visibility').text())
    @alt_email_visibility = $.trim($('#alt_email_visibility').text())
    @phone_number_visibility = $.trim($('#phone_number_visibility').text())
    @hometown_visibility = $.trim($('#hometown_visibility').text())
    
  setInfoView: =>
    $('#name_value').text(@name)
    $('#first_name_value').text(@first_name)
    $('#last_name_value').text(@last_name)
    $('#email_value').text(@email)
    $('#alt_email_value').text(@alt_email)
    $('#phone_number_value').text(@phone_number)
    $('#birthdate_value').text(@birthdate)
    $('#hometown_value').text(@hometown)
    
    $('#buttons_div').html(@.createButton('edit_profile', 'edytuj dane osobowe'))
    $('#edit_profile').button()
    
  setEditView: =>
    @.addInput('first_name_value', @first_name)
    @.addInput('last_name_value', @last_name)
    @.addInput('email_value', @email)
    @.addInput('alt_email_value', @alt_email)
    @.addInput('phone_number_value', @phone_number)
    @.addInput('birthdate_value', @birthdate)
    @.addInput('hometown_value', @hometown)
    @.addSelectVisibilities()
    
    $('#buttons_div').html(@.createButton('info_profile', 'powrót') + @.createButton('save_profile', 'zapisz'))
    $('#info_profile').button()
    $('#save_profile').button()
    
  addSelectVisibilities: () =>
    $('#email_visibility').html(@.getSelectVisibilityTag('email_visibility_select'))
    $('#alt_email_visibility').html(@.getSelectVisibilityTag('alt_email_visibility_select'))
    $('#phone_number_visibility').html(@.getSelectVisibilityTag('phone_number_visibility_select'))
    $('#hometown_visibility').html(@.getSelectVisibilityTag('#hometown_visibility_select'))
    
  getSelectVisibilityTag: (id) =>
    '<select id="' + id + '" name="' + id + '">' +
      '<option value="everyone">wszyscy</option>' +
      '<option value="nobody">nikt</option>' +
      '<option value="registered">zarejestrowani</option></select>'
            
    
  addInput: (elementId, attr) =>
    $('#'+elementId).html('<input type="text" id="' + elementId + '_input" name="' + 
      elementId + '_input" value="' + attr + '"></input>')
      
  createButton: (id, label) =>
    '<button id="' + id + '" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"' +
       'role="button" aria-disabled="false"><span class="ui-button-text">' + label + '</span></button>'
    

class ProfileEventMenager
  constructor: (@serverSide, @view, @showEditViewButton, @backButton, @saveButton, @dateInput) ->
  
  initialize : =>
    @.addSetInfoViewActionToElement()
    @.addSetEditViewActionToElement()
    @.addSaveChangesActionToElement()
    
  addSaveChangesActionToElement: () =>
    ss = @serverSide
    $('#'+@saveButton).click (ev) ->
      ss.changePersonalUserData (data) ->
        #console.log data
        if data.status is "redirect"
          window.location.href = data.path
  
  addSetInfoViewActionToElement: =>
    th = @
    $('#'+@backButton).click (ev) ->
      th.view.setInfoView()
      th.addSetEditViewActionToElement()
      
  addSetEditViewActionToElement: =>
    th = @
    $('#'+@showEditViewButton).click (ev) ->
      th.view.setEditView()
      th.addSetInfoViewActionToElement()
      th.addSaveChangesActionToElement()
      th.addDatePickerToElement()
      
  addDatePickerToElement: () =>
    $('#'+@dateInput).datepicker({monthNames: ['styczeń', 'luty', 'marzec', 'kwiecień', 'maj', 'czerwiec', 
      'lipiec', 'sierpień', 'wrzesień', 'październik', 'listopad', 'grudzień']
      , dayNamesMin: ['Pn', 'Wt', 'Śr', 'Czw', 'Pt', 'So', 'Nd']
      , dateFormat: 'dd-mm-yy'
      , minDate: new Date(1900, 1 - 1, 1)
      , changeYear: true})

class ProfileInitializator
  constructor: () ->
    @profileView
    
  initialize: =>
    baseUrl = (/http:\/\/[a-z0-9]+([\-\.:]{1}[a-z0-9]+)*/.exec document.location.href)[0]
    @serverSide = new ProfileServerSide(baseUrl)
    @profileView = new ProfileView(@serverSide)
    @validator = new ProfileEditValidator()
   
    $('#user_profile_tabs').tabs()
    $('#edit_profile').button()
    profV = @profileView

    @eventMenager = new ProfileEventMenager(@serverSide, @profileView, 'edit_profile', 'info_profile', 'save_profile', 'birthdate_value_input')
    @eventMenager.initialize()
    console.log @profileView


$ ->
  init = new ProfileInitializator()
  init.initialize()
