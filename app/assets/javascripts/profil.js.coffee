class ProfileView
  constructor: () ->
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
    
  setEditView: =>
    @.addInput('name_value', @name)
    @.addInput('first_name_value', @first_name)
    @.addInput('last_name_value', @last_name)
    @.addInput('email_value', @email)
    @.addInput('alt_email_value', @alt_email)
    @.addInput('phone_number_value', @phone_number)
    @.addInput('birthdate_value', @birthdate)
    @.addInput('hometown_value', @hometown)
    
  addInput: (elementId, attr) =>
    $('#'+elementId).html('<input type="text" id="' + elementId + '_input" name="' + elementId + '_input" value="' + attr + '"></input>')
    

class ProfileInitializator
  constructor: () ->
    @profileView
    
  initialize: =>
    @profileView = new ProfileView()
    $('#user_profile_tabs').tabs()
    #$('#add_first_name').button()
    $('#edit_profile').button()
    profV = @profileView
    $('#edit_profile').click (ev) ->
      profV.setEditView()
    
    console.log @profileView


$ ->
  init = new ProfileInitializator()
  init.initialize()
