Template.login.events

  'submit #login-form': (e, t) ->

    email = t.find('#accounts-email').value
    password = t.find('#accounts-password').value

    Meteor.loginWithPassword email, password, (error) ->
      if error
        console.log error
      else
        console.log "Logged in as:"
        console.log Meteor.user()

    e.preventDefault()
    false