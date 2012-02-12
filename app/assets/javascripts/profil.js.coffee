class ProfileEditValidator
  constructor: () ->
    
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
    console.log data
    $.get("#{@baseUrl}/home/profil/edit_user", data, onLoad)
    
  getData: =>
    data = []
    data.push @.getValue('first_name')
    data.push @.getValue('last_name')
    data.push @.getValue('email')
    data.push @.getValue('alt_email')
    data.push @.getValue('phone_number')
    data.push @.getValue('birthdate')
    data.push @.getValue('hometown')
    data
    
  getValue: (atr) =>
    unless $('#'+atr+'_value_input').val() is 'brak danych'
      res=
        name: atr
        value: $('#'+atr+'_value_input').val()

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
    #th = @
    #$('#edit_profile').click (ev) ->
    #  th.setEditView()
    
  setEditView: =>
    @.addInput('first_name_value', @first_name)
    @.addInput('last_name_value', @last_name)
    @.addInput('email_value', @email)
    @.addInput('alt_email_value', @alt_email)
    @.addInput('phone_number_value', @phone_number)
    @.addInput('birthdate_value', @birthdate)
    @.addInput('hometown_value', @hometown)
    
    $('#buttons_div').html(@.createButton('info_profile', 'powrót') + @.createButton('save_profile', 'zapisz'))
    $('#info_profile').button()
    $('#save_profile').button()
    #th = @
    #$('#info_profile').click (ev) ->
    #  th.setInfoView()
    #$('#save_profile').click (ev) ->
    #  th.serverSide.changePersonalUserData (data) ->
    #    console.log data
    
  addInput: (elementId, attr) =>
    $('#'+elementId).html('<input type="text" id="' + elementId + '_input" name="' + 
      elementId + '_input" value="' + attr + '"></input>')
      
  createButton: (id, label) =>
    '<button id="' + id + '" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"' +
       'role="button" aria-disabled="false"><span class="ui-button-text">' + label + '</span></button>'
    

class ProfileEventMenager
  constructor: (@serverSide, @view, @showEditViewButton, @backButton, @saveButton) ->
  
  initialize : =>
    @.addSetInfoViewActionToElement()
    @.addSetEditViewActionToElement()
    @.addSaveChangesActionToElement()
    
  addSaveChangesActionToElement: () =>
    ss = @serverSide
    $('#'+@saveButton).click (ev) ->
      ss.changePersonalUserData (data) ->
        console.log data
  
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

class ProfileInitializator
  constructor: () ->
    @profileView
    
  initialize: =>
    baseUrl = (/http:\/\/[a-z0-9]+([\-\.:]{1}[a-z0-9]+)*/.exec document.location.href)[0]
    @serverSide = new ProfileServerSide(baseUrl)
    @profileView = new ProfileView(@serverSide)
    @validator = new ProfileEditValidator()
   
    #@profileView.setEditView()
    #console.log @validator.validatePhoneNumber("-888-888-888")
    $('#user_profile_tabs').tabs()
    $('#edit_profile').button()
    profV = @profileView
    #$('#edit_profile').click (ev) ->
    #  profV.setEditView()
    @eventMenager = new ProfileEventMenager(@serverSide, @profileView, 'edit_profile', 'info_profile', 'save_profile')
    @eventMenager.initialize()
    console.log @profileView


$ ->
  init = new ProfileInitializator()
  init.initialize()
