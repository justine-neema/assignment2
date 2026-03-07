import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:assignment2/services/map_service.dart';

class MapWidget extends StatelessWidget {
  final LatLng? center;
  final double zoom;
  final List<Marker> markers;
  final MapController? controller;
  final Function(LatLng)? onTap;
  final bool showZoomControls;

  const MapWidget({
    super.key,
    this.center,
    this.zoom = MapService.defaultZoom,
    this.markers = const [],
    this.controller,
    this.onTap,
    this.showZoomControls = true,
  });

  @override
  Widget build(BuildContext context) {
    final mapService = MapService();
    
    return FlutterMap(
      mapController: controller,
      options: mapService.getMapOptions(
        center: center,
        zoom: zoom,
        onTap: onTap,
      ),
      children: [
        mapService.getTileLayer(),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
