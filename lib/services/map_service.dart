import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  // Default Kigali coordinates
  static const double defaultLatitude = -1.9441;
  static const double defaultLongitude = 30.0619;
  static const double defaultZoom = 13.0;

  // Get default Kigali location
  LatLng getDefaultLocation() {
    return LatLng(defaultLatitude, defaultLongitude);
  }

  // Create marker from coordinates
  Marker createMarker({
    required String id,
    required LatLng position,
    required String label,
    void Function()? onTap,
  }) {
    return Marker(
      point: position,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: onTap,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ),
    );
  }

  // Create markers from list of locations
  List<Marker> createMarkersFromLocations(
    List<Map<String, dynamic>> locations,
    Function(String id) onMarkerTap,
  ) {
    return locations.map((location) {
      return createMarker(
        id: location['id'] as String,
        position: LatLng(
          location['latitude'] as double,
          location['longitude'] as double,
        ),
        label: location['name'] as String,
        onTap: () => onMarkerTap(location['id'] as String),
      );
    }).toList();
  }

  // Get map options
  MapOptions getMapOptions({
    LatLng? center,
    double zoom = defaultZoom,
    Function(LatLng)? onTap,
  }) {
    return MapOptions(
      initialCenter: center ?? getDefaultLocation(),
      initialZoom: zoom,
      onTap: (tapPosition, point) => onTap?.call(point),
    );
  }

  // Get tile layer (OpenStreetMap)
  TileLayer getTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.assignment2',
    );
  }

  // Calculate distance between two points (in kilometers)
  double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  // Open location in external maps app
  Future<void> openInMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Get directions to location
  Future<void> getDirections(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
