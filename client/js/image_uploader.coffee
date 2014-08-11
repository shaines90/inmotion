Meteor.subscribe('picture')

Template.profile.rendered = () ->
  $('#bio').keydown (event) ->
    if event.keyCode == 13
      $('#bio').blur()

  if (Meteor.isClient)
    Dropzone.autoDiscover = false
    $('.dropzone').dropzone
      accept: (file, done) ->
        FS.Utility.eachFile event, (file) ->
          Images.insert file, (err, fileObj) ->
            if err
              console.log "Error exists: ", err
            else
              fileId = fileObj._id
              userId = Meteor.userId()
              Meteor.users.update userId,
                $set:
                  'profile.imageId': fileId
        done()
