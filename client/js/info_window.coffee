getUserId = ->
  Meteor.userId()

Template.infoWindowShow.helpers
  allContent: ->
    Content.find({})

Template.infoWindow.events
  'submit #infoWindow_form': (e, t) ->

    input = t.find('#content')
    content = input.value
    input.value = ""
    userId = getUserId()

    Content.insert buildContent(userId, content)

    e.preventDefault()
    false