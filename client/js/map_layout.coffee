Meteor.subscribe('markers')
map = undefined
codeAddress = undefined
geocoder = undefined
yellowMarker = '/images/yellow_MarkerA.png'
blueMarker = '/images/blue_MarkerA.png'
currentPosMarker = undefined
currentPosInfowindow = undefined
currentFindMarker = undefined
currentFindInfowindow = undefined
# array = undefined
marker = undefined


lastClickedMarker = "No click yet"
lastClickedInfowindow = "No click yet"
lastClickIsApin = undefined
pinInfowindow = undefined
pinMarkermarker = undefined

Template.map.rendered = ->
  google.maps.event.addDomListener(window, 'load', initialize);
  initialize()
  geoLocation()


initialize = ->
  geocoder = new google.maps.Geocoder()
  mapOptions =
    zoom: 8
    minZoom: 2
    # center: new google.maps.LatLng(-34.397, 150.644)

  mapDiv = document.getElementById("map-canvas")
  map = new google.maps.Map(mapDiv, mapOptions)
  pinMarker()
  autorunPinOnMap()

pinMarker = ->
  google.maps.event.addListener map, "click", (event) ->

    console.log latt = event.latLng.lat()
    console.log long = event.latLng.lng()
    # console.log a = $("button#createMarker").data("lat")
    # console.log a
    # if $("button#createMarker").data("lat") == undefined
    $("button#createMarker").data("lat", latt)
    $("button#createMarker").data("long", long)
    console.log $("button#createMarker").data("lat")
    contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
    pinInfowindow = new google.maps.InfoWindow(content: contentString)
    pinMarkermarker = new google.maps.Marker(
      position:
        lat: latt,
        lng: long,
      map: map,
      draggable:true,
      icon: blueMarker

      )
    if lastClickedInfowindow == "No click yet"
      lastClickIsApin = true
      lastClickedInfowindow = pinInfowindow
      lastClickedMarker = pinMarkermarker
      pinInfowindow.open map, pinMarkermarker
    else
      if lastClickIsApin == undefined
        lastClickedInfowindow = pinInfowindow
        lastClickedMarker = pinMarkermarker
        lastClickIsApin = true
        pinInfowindow.open map, pinMarkermarker
      if lastClickIsApin is true
        lastClickedMarker.setMap(null)
        lastClickedInfowindow = pinInfowindow
        lastClickedMarker = pinMarkermarker
        lastClickIsApin = true
        pinInfowindow.open map, pinMarkermarker
      else
        lastClickedInfowindow.close map, lastClickedMarker
        lastClickedInfowindow = pinInfowindow
        lastClickedMarker = pinMarkermarker
        lastClickIsApin = true
        pinInfowindow.open map, pinMarkermarker

    google.maps.event.addListener pinMarkermarker, "click", ->
      if lastClickedInfowindow == "No click yet"
        lastClickedInfowindow = pinInfowindow
        lastClickedMarker = pinMarkermarker
        lastClickIsApin = true
        pinInfowindow.open map, pinMarkermarker
      else
        lastClickedInfowindow.close map, lastClickedMarker
        if lastClickIsApin is true
          lastClickedMarker.setMap(null)
          lastClickedInfowindow = pinInfowindow
          lastClickedMarker = pinMarkermarker
          lastClickIsApin = true
          pinInfowindow.open map, pinMarkermarker

        else
          lastClickedInfowindow = pinInfowindow
          lastClickedMarker = pinMarkermarker
          lastClickIsApin = true
          pinInfowindow.open map, pinMarkermarker

autorunPinOnMap = ->
  if (Meteor.isClient)
    Deps.autorun () ->
      array = Markers.find().fetch()
      console.log array.length
      for key, object of array
        console.log key
        latt = object.lat
        long = object.lng
        contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
        infowindow = new google.maps.InfoWindow(content: contentString)
        marker = new google.maps.Marker
          position:
            lat: latt,
            lng: long,
          map: map,
          draggable:true,
        google.maps.event.addListener marker, "click", ->
          if lastClickIsApin is true
            lastClickedMarker.setMap(null)
            lastClickedMarker = this
            lastClickedInfowindow = infowindow
            lastClickIsApin = false
            infowindow.open map, this
          else
            if lastClickedInfowindow == "No click yet"
              lastClickedMarker = this
              lastClickedInfowindow = infowindow
              lastClickIsApin = false
              infowindow.open map, this
            else
              lastClickedInfowindow.close map, lastClickedMarker
              lastClickedMarker = this
              lastClickedInfowindow = infowindow
              lastClickIsApin = false
              infowindow.open map, this
              console.log 'one new pin from DB has been made'

geoLocation = ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition ((position) ->
      pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
      currentPosInfowindow = new google.maps.InfoWindow(content: contentString)
      currentPosMarker = new google.maps.Marker
        map: map,
        position: pos,
        icon: yellowMarker
        zoom: 13
      lastClickedInfowindow = currentPosInfowindow
      lastClickedMarker = currentPosMarker
      lastClickIsApin = false
      console.log "this is here"
      console.log pos
      google.maps.event.addListener currentPosMarker, "click", ->
        if lastClickedInfowindow == "No click yet"
          lastClickedInfowindow = currentPosInfowindow
          lastClickedMarker = currentPosMarker
          lastClickIsApin = false
          currentPosInfowindow.open map, currentPosMarker
        else
          if lastClickIsApin is true
            lastClickedMarker.setMap(null)
            lastClickedInfowindow = currentPosInfowindow
            lastClickedMarker = currentPosMarker
            lastClickIsApin = false
            currentPosInfowindow.open map, currentPosMarker
          else
            lastClickedInfowindow.close map, lastClickedMarker
            lastClickedInfowindow = currentPosInfowindow
            lastClickedMarker = currentPosMarker
            lastClickIsApin = false
            currentPosInfowindow.open map, currentPosMarker
            return

      map.setCenter pos), ->
      handleNoGeolocation true
  else
    handleNoGeolocation false

handleNoGeolocation = (errorFlag) ->
  if errorFlag
    content = "Error: The Geolocation service failed."
  else
    content = "Error: Your browser doesn't support geolocation."
  options =
    map: map
    position: new google.maps.LatLng(60, 105)
    content: content

  infowindow = new google.maps.InfoWindow(options)
  map.setCenter options.position
  addMarker(position, map)

insertMarkersInDb =  ->
  Template.editMarker.events
    "click button#createMarker" : (e, t) ->
      console.log latData = $("button#createMarker").data("lat")
      console.log longData = $("button#createMarker").data("long")
      Markers.insert(markerObjectForm(latData, longData))
insertMarkersInDb()

markerObjectForm =  (latData, longData) ->
  {lat: latData, lng: longData}

findOnMap = ->
  Template.map.events
    "click button#address" : (e, t) ->
      address = document.getElementById("address").value
      geocoder.geocode
        address: address
      , (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          map.setCenter results[0].geometry.location
          contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
          currentFindInfowindow = new google.maps.InfoWindow(content: contentString)
          currentFindMarker = new google.maps.Marker(
            map: map
            draggable:true,
            position: results[0].geometry.location
          )

          google.maps.event.addListener currentFindMarker, "click", ->
            console.log currentFindInfowindow
            console.log currentFindMarker
            if lastClickedInfowindow == "No click yet"
              lastClickedInfowindow = currentFindInfowindow
              lastClickedMarker = currentFindMarker
              lastClickIsApin = false
              currentFindInfowindow.open map, currentFindMarker
            else
              if lastClickIsApin is true
                lastClickedMarker.setMap(null)
                lastClickedInfowindow = currentFindInfowindow
                lastClickedMarker = currentFindMarker
                lastClickIsApin = false
                currentFindInfowindow.open map, currentFindMarker
              else
                lastClickedInfowindow.close map, lastClickedMarker
                lastClickedInfowindow = currentFindInfowindow
                lastClickedMarker = currentFindMarker
                lastClickIsApin = false
                currentFindInfowindow.open map, currentFindMarker
        else
          alert "Geocode was not successful for the following reason: " + status
        return
      return
      e.preventDefault()
      false
findOnMap()



