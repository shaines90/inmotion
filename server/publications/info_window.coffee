Meteor.publish "contents", (options) ->
  Content.find()
