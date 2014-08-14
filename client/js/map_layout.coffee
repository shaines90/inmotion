Meteor.subscribe('markers')
geocoder = undefined
map = undefined
mapClickedMarker = undefined
savedMarker = undefined
currentPosMarker = undefined
geoMarkerIcon = '/images/paleblue_MarkerA.png'
savedMarkerIcon = '/images/green_MarkerA.png'
clickMarkerIcon = '/images/blue_MarkerA.png'
currentFindMarker = undefined
mapClickInfoWindow = undefined
latData = undefined
lngData = undefined

Template.map.rendered = ->
  google.maps.event.addDomListener(window, 'load', initializeMap);
  initializeMap()
  geolocation()

initializeMap = ->
  geocoder = new google.maps.Geocoder()
  mapOptions =
    backgroundColor: "#AFBE48"
    zoom: 8
    # center: new google.maps.LatLng(-34.397, 150.644)
    minZoom: 2

  mapDiv = document.getElementById("map-canvas")
  map = new google.maps.Map(mapDiv, mapOptions)

  autoLoadSavedMarkers()
  mapClick()
  geolocation()

infoWindowContent = (infoWindow, contentString) ->
  infoWindow.setContent(contentString)

mapClick = ->
  google.maps.event.addListener map, "click", (event) ->
    latt = event.latLng.lat()
    long = event.latLng.lng()
    contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
    mapClickInfoWindow = new google.maps.InfoWindow(content: contentString)

    infoWindowContent(mapClickInfoWindow, contentString)

    mapClickedMarker.setMap null if mapClickedMarker
    mapClickedMarker = new google.maps.Marker(
      position:
        lat: latt,
        lng: long,
      map: map,
      draggable: true
      icon : clickMarkerIcon)

    google.maps.event.addListener mapClickedMarker, "click", ->
      mapClickInfoWindow.open map, mapClickedMarker
      latData = mapClickedMarker.position.lat()
      lngData = mapClickedMarker.position.lng()

    google.maps.event.addListener mapClickInfoWindow, "domready", ->
      $("#saveMarker").click ->
        description = document.getElementById("description content").value
        Markers.insert(markerObject(latData, lngData, description))

markerObject = (latData, lngData, description) ->
  {lat: latData, lng: lngData, description: description}

autoLoadSavedMarkers = ->
  if (Meteor.isClient)
    Deps.autorun () ->
      array = Markers.find().fetch()
      console.log Markers
      for key, object of array
        console.log key
        latt = object.lat
        long = object.lng
        description = object.description
        console.log latt
        console.log long
        console.log description
        contentString = "<div id=\"content\">" + $('#content_sourceShow').html() +  "</div>"
        savedInfoWindow = new google.maps.InfoWindow(content: contentString)

        infoWindowContent(savedInfoWindow, contentString)

        savedMarker = new google.maps.Marker
          position:
            lat: latt,
            lng: long,
          map: map,
          icon : savedMarkerIcon,
          draggable: false,
        console.log 'one new pin from DB has been made'

        google.maps.event.addListener savedMarker, "click", ->
          savedInfoWindow.open map, this
          latData = savedMarker.position.lat()
          lngData = savedMarker.position.lng()
          console.log "This is the lat: " + latData
          console.log "this is the long: " + lngData

        google.maps.event.addListener savedInfoWindow, "domready", ->
          console.log object.description
          $( "div.test" ).text( "#{description}" )

geolocation = ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition ((position) ->
      pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
      geolocationInfoWindow = new google.maps.InfoWindow(content: contentString)
      currentPosMarker = new google.maps.Marker
        map: map,
        position: pos,
        zoom: 8,
        icon : geoMarkerIcon,

      map.setCenter pos), ->
      handleNoGeolocation true

      google.maps.event.addListener currentPosMarker, "click", ->
        geolocationInfoWindow.open map, currentPosMarker
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

  map.setCenter options.position
  addMarker(position, map)

geocoding = ->
  Template.map.events
    "click button#address" : (e, t) ->
      address = document.getElementById("address").value
      geocoder.geocode
        address: address
      , (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          map.setCenter results[0].geometry.location
          contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
          geocodingInfoWindow = new google.maps.InfoWindow(content: contentString)
          currentFindMarker = new google.maps.Marker(
            map: map
            draggable:true,
            position: results[0].geometry.location
          )

          google.maps.event.addListener currentFindMarker, "click", ->
            geocodingInfoWindow.open map, currentFindMarker

        else
          alert "Geocode was not successful for the following reason: " + status

      e.preventDefault()
      false
geocoding()

reverseGeocoding = ->
  input = document.getElementById("latlng").value
  latlngStr = input.split(",", 2)
  lat = parseFloat(latlngStr[0])
  lng = parseFloat(latlngStr[1])
  latlng = new google.maps.LatLng(lat, lng)
  geocoder.geocode
    latLng: latlng
  , (results, status) ->
    if status is google.maps.GeocoderStatus.OK
      if results[1]
        map.setZoom 11
        marker = new google.maps.Marker(
          position: latlng
          map: map
        )

        google.maps.event.addListener currentPosMarker, "click", ->
          geocodingInfoWindow.setContent results[1].formatted_address
          geocodingInfoWindow.open map, marker
      else
        alert "No results found"
    else
      alert "Geocoder failed due to: " + status


#Info Window Content
getUserId = ->
  Meteor.userId()

getUserEmail = ->
  Meteor.user().emails[0].address

Template.infoWindowShow.helpers
  allContent: ->
    Content.find({})
#Info Window Content end
