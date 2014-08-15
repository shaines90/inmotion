Meteor.subscribe('markers')
clickMarkerIcon = '/images/blueMarker-01.png'
currentFindMarker = undefined
currentPosMarker = undefined
geocoder = undefined
geoMarkerIcon = '/images/yellowMarker.png'
latData = undefined
lngData = undefined
map = undefined
mapClickInfoWindow = undefined
mapClickedMarker = undefined
savedMarker = undefined
savedMarkerIcon = '/images/greenMarker-01.png'
formatedAddress = undefined
address = undefined
poly = undefined
geolocationInfoWindow = undefined
currentPosMarker = undefined

Template.map.rendered = ->
  google.maps.event.addDomListener(window, 'load', initializeMap);
  geolocation()
  initializeMap()

initializeMap = ->
  geocoder = new google.maps.Geocoder()

  mapOptions =
    backgroundColor: "#AFBE48"
    zoom: 8
    minZoom: 2
  mapDiv = document.getElementById("map-canvas")
  map = new google.maps.Map(mapDiv, mapOptions)

  polyOptions =
      strokeColor: "#000000"
      strokeOpacity: 1.0
      strokeWeight: 3

  poly = new google.maps.Polyline(polyOptions)
  poly.setMap map

  autoLoadSavedMarkers()
  geolocation()
  mapClick()

infoWindowContent = (infoWindow, contentString) ->
  infoWindow.setContent(contentString)

mapClick = ->
  google.maps.event.addListener map, "click", (event) ->
    latt = event.latLng.lat()
    long = event.latLng.lng()
    latlng = new google.maps.LatLng(latt, long)
    geocoder.geocode
      latLng: latlng
    , (results, status) ->
      if status is google.maps.GeocoderStatus.OK
       formatedAddress = results[1].formatted_address
       console.log formatedAddress
      else
        alert "Geocoder failed due to: " + status

    contentString = "<div id=\"content\">" + $('#content_source').html() +  "</div>"
    mapClickInfoWindow = new google.maps.InfoWindow(content: contentString)

    infoWindowContent(mapClickInfoWindow, contentString)

    mapClickedMarker.setMap null if mapClickedMarker
    mapClickedMarker = new google.maps.Marker(
      position:
        lat: latt,
        lng: long,
      map: map,
      draggable: false,
      icon : clickMarkerIcon)

    google.maps.event.addListener mapClickedMarker, "click", ->
      mapClickInfoWindow.open map, mapClickedMarker
      latData = mapClickedMarker.position.lat()
      lngData = mapClickedMarker.position.lng()

    google.maps.event.addListener mapClickInfoWindow, "domready", ->
      imageId = null
      $( "div.location" ).html("<h1>#{formatedAddress}</h1>")

      if (Meteor.isClient)
        Dropzone.autoDiscover = true
        new Dropzone "#content form#location-images.dropzone",
          accept: (file, done) ->
            Images.insert file, (err, fileObj) ->
              if err
                alert "Error exists: ", err
              else
                imageId = fileObj._id
            done()

      $("#saveMarker").click ->
        description = $("#content #description").val()
        Markers.insert(markerObject(latData, lngData, description, imageId, formatedAddress))

markerObject = (latData, lngData, description, imageId, formatedAddress) ->
  {lat: latData, lng: lngData, description: description, imageId: imageId, address: formatedAddress}

autoLoadSavedMarkers = ->
  if (Meteor.isClient)
    Deps.autorun () ->
      array = Markers.find().fetch()
      for key, object of array
        latt = object.lat
        long = object.lng
        description = object.description
        address = object.adress
        Session.set("(#{latt}, #{long})", object._id)
        latlng = new google.maps.LatLng(latt, long)
        path = poly.getPath()
        path.push latlng

        savedMarker = new google.maps.Marker
          position:
            lat: latt,
            lng: long,
          map: map,
          icon : savedMarkerIcon,
          draggable: false,

        google.maps.event.addListener savedMarker, "click", (event) ->
          markerId = Session.get(event.latLng.toString())
          marker = Markers.findOne({_id: markerId})
          if marker.imageId
            imgUrl = Images.findOne({_id: marker.imageId}).url()
            imageTag = "<img src='#{imgUrl}' />"
          contentString = "<div id=\"content\">" + "<h1> #{marker.address} </h1><div>#{marker.description}</div>" + imageTag + "</div>"
          savedInfoWindow = new google.maps.InfoWindow(content: contentString)
          infoWindowContent(savedInfoWindow, contentString)

          savedInfoWindow.open map, this

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

      google.maps.event.addListener currentPosMarker, "click", ->
        geolocationInfoWindow.open map, currentPosMarker
        latt = currentPosMarker.position.lat()
        long = currentPosMarker.position.lng()
        latlng = new google.maps.LatLng(latt, long)
        geocoder.geocode
          latLng: latlng
        , (results, status) ->
          if status is google.maps.GeocoderStatus.OK
           formatedAddress = results[1].formatted_address
           console.log formatedAddress
          else
            alert "Geocoder failed due to: " + status
          $( "div.location" ).html("<h1>#{formatedAddress}</h1>")

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
            latt = currentFindMarker.position.lat()
            long = currentFindMarker.position.lng()
            latlng = new google.maps.LatLng(latt, long)
            geocoder.geocode
              latLng: latlng
            , (results, status) ->
              if status is google.maps.GeocoderStatus.OK
               formatedAddress = results[1].formatted_address
               console.log formatedAddress
              else
                alert "Geocoder failed due to: " + status

              $( "div.location" ).html("<h1>#{formatedAddress}</h1>")
        else
          alert "Geocode was not successful for the following reason: " + status

      e.preventDefault()
      false
geocoding()


