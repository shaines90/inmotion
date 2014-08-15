Router.configure
  layoutTemplate: 'plain_layout'

Router.map ->
  @route 'main',
    path: '/'
    layoutTemplate: 'home_layout'

  @route "main",
    path: "/"
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('buttonText', 'in')
      Session.set('fromWhere', Router.current().path)
    onRun: ->
      if Meteor.userId()
        Router.go AccountsEntry.settings.dashboardRoute

      if AccountsEntry.settings.signInTemplate
        @template = AccountsEntry.settings.signInTemplate
        pkgRendered= Template.entrySignIn.rendered
        userRendered = Template[@template].rendered

        if userRendered
          Template[@template].rendered = ->
            pkgRendered.call(@)
            userRendered.call(@)
        else
          Template[@template].rendered = pkgRendered

        Template[@template].events(AccountsEntry.entrySignInEvents)
        Template[@template].helpers(AccountsEntry.entrySignInHelpers)


  @route "main",
    path: "/"
    onBeforeAction: ->
      Session.set('entryError', undefined)
      Session.set('buttonText', 'up')
    onRun: ->
      if AccountsEntry.settings.signUpTemplate
        @template = AccountsEntry.settings.signUpTemplate
        pkgRendered= Template.entrySignUp.rendered
        userRendered = Template[@template].rendered

        if userRendered
          Template[@template].rendered = ->
            pkgRendered.call(@)
            userRendered.call(@)
        else
          Template[@template].rendered = pkgRendered

        Template[@template].events(AccountsEntry.entrySignUpEvents)
        Template[@template].helpers(AccountsEntry.entrySignUpHelpers)

  @route 'login'
  @route 'registration'
  @route 'forgotPassword'

  @route 'map',
    waitOn: -> Meteor.subscribe "contents"
  @route 'profile'
  @route 'contact'

autoLogin = (pause) ->
  Router.go 'map' if Meteor.userId()

requireLogin = (pause) ->
  unless Meteor.userId()
    Router.go 'entrySignIn'

Router.onBeforeAction autoLogin,
  only: ['main', 'entrySignIn', 'entrySignUp']

Router.onBeforeAction requireLogin,
  only: ['map', 'profile', 'contact']


