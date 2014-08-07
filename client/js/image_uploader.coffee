Template.profile.events "dropped #dropzone": (event, temp) ->
  FS.Utility.eachFile event, (file) ->
    newFile = new FS.File(file)
    if !!Images.find().fetch()[0] == false
      Images.insert file, (err, fileObj) ->
    else
      Images.find().fetch()[0].remove()
      Images.insert file, (err, fileObj) ->
    return
  return
