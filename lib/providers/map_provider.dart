import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:assignment2/services/map_service.dart';

class MapProvider extends ChangeNotifier {
  final MapService _mapService = MapService();
  final MapController mapController = MapController();
  
  LatLng _currentCenter = LatLng(MapService.defaultLatitude, MapService.defaultLongitude);
  double _currentZoom = MapService.defaultZoom;
  List<Marker> _markers = [];

  LatLng get currentCenter => _currentCenter;
  double get currentZoom => _currentZoom;
  List<Marker> get markers => _markers;

  // Move camera to location
  void moveToLocation(LatLng location, {double? zoom}) {
    _currentCenter = location;
    _currentZoom = zoom ?? _currentZoom;
    mapController.move(location, _currentZoom);
    notifyListeners();
  }

  // Add marker
  void addMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  // Set markers
  void setMarkers(List<Marker> markers) {
    _markers = markers;
    notifyListeners();
  }

  // Clear markers
  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  // Update zoom
  void updateZoom(double zoom) {
    _currentZoom = zoom;
    notifyListeners();
  }

  // Get map service
  MapService get mapService => _mapService;
}
