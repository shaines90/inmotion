Template.profile.events "dropped #dropzone": (event, temp) ->
  Deps.autorun (c) ->
    console.log "count  : ", Images.find().count()
    console.log "profile: ", Images.find().fetch()[0].url()
    Meteor.users.update {_id: Meteor.userId()},
      "$set":
        'profile.profileImageURL': Images.find().fetch()[0].url()

  FS.Utility.eachFile event, (file) ->
    newFile = new FS.File(file)
    if !!Images.find().fetch()[0] == true
      Images.find(Meteor.userId()).fetch()[0].remove()
    Images.insert file, (err, fileObj) ->
      if err
        console.log "Error exists: ", err
    return
  return

