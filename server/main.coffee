Meteor.publish "markers", ->
  Markers.find({})

Meteor.publish "picture", ->
  Images.find({})

Meteor.publish "contents", (options) ->
  Content.find({})
