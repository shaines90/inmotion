Images = new FS.Collection("images",
  stores: [new FS.Store.FileSystem("images",
    path: "~/uploads"
  )]
)

Template.hello.events "dropped #dropzone": (event, temp) ->
  console.log "files dropped"
  FS.Utility.eachFile event, (file) ->
    Images.insert file, (err, fileObj) ->

    return

  return