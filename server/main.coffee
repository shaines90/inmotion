Meteor.publish "markers", ->
  Markers.find({})

Meteor.publish "picture", ->
  Images.find({})