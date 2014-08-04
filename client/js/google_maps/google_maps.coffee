GoogleMaps.init(
  {
    'sensor': true
    'key': 'AIzaSyCoXPNILPDUYhoJxvLw-mp0EA5RC2qoqTQ'
    'language': 'en'
  }, ->
    mapOptions = {
      zoom: 13
      mapTypeId: google.maps.MapTypeId.SATELLITE
    }

    map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)
    map.setCenter(new google.maps.LatLng(35.363556, 138.730438)))