Meteor.subscribe('markers')
map = undefined
mapClickedMarker = undefined
savedMarker = undefined

Template.map.rendered = ->
  google.maps.event.addDomListener(window, 'load', initializeMap);

  initializeMap()

initializeMap = ->
  # geocoder = new google.maps.Geocoder()
  mapOptions =
    zoom: 8
    center: new google.maps.LatLng(-34.397, 150.644)

  mapDiv = document.getElementById("map-canvas")
  map = new google.maps.Map(mapDiv, mapOptions)

  autoLoadSavedMarkers()
  mapClick()

infoWindowContent = (infoWindow, contentString) ->
  infoWindow.setContent(contentString)

mapClick = ->
  google.maps.event.addListener map, "click", (event) ->
    console.log latt = event.latLng.lat()
    console.log long = event.latLng.lng()
    $("button#saveMarker").data("lat", latt)
    $("button#saveMarker").data("long", long)
    contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
    mapClickInfoWindow = new google.maps.InfoWindow(content: contentString)

    infoWindowContent(mapClickInfoWindow, contentString)

    console.log "hidden: " + $("button#saveMarker").data("lat")
    mapClickedMarker = new google.maps.Marker(
      position:
        lat: latt,
        lng: long,
      map: map,
      draggable:true
      )

    google.maps.event.addListener mapClickedMarker, "click", ->
      mapClickInfoWindow.open map, mapClickedMarker


markerObject = (latData, longData) ->
  {lat: latData, lng: longData}

saveMarkerToDatabase = ->
  Template.editMarker.events
    "click button#saveMarker" : (e, t) ->
      console.log latData = $("button#saveMarker").data("lat")
      console.log longData = $("button#saveMarker").data("long")
      Markers.insert(markerObject(latData, longData))
saveMarkerToDatabase()

autoLoadSavedMarkers = ->
  if (Meteor.isClient)
    Deps.autorun () ->
      array = Markers.find().fetch()
      console.log Markers
      for key, object of array
        console.log key
        latt = object.lat
        long = object.lng
        console.log latt
        console.log long
        contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
        savedInfoWindow = new google.maps.InfoWindow(content: contentString)

        infoWindowContent(savedInfoWindow, contentString)

        savedMarker = new google.maps.Marker
          position:
            lat: latt,
            lng: long,
          map: map,
          draggable:true,
        console.log 'one new pin from DB has been made'

        google.maps.event.addListener savedMarker, "click", ->
          savedInfoWindow.open map, this


