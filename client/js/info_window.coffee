getUserId = ->
  Meteor.userId()

Template.infoWindowShow.helpers
  allContent: ->
    Content.find({})