import 'package:flutter/material.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/services/map_service.dart';
import 'package:assignment2/widgets/map_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapDirectionsScreen extends StatefulWidget {
  final ListingModel listing;

  const MapDirectionsScreen({super.key, required this.listing});

  @override
  State<MapDirectionsScreen> createState() => _MapDirectionsScreenState();
}

class _MapDirectionsScreenState extends State<MapDirectionsScreen> {
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = _mapService.getDefaultLocation();
          _isLoadingLocation = false;
          _errorMessage = 'Location services disabled. Using default location.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = _mapService.getDefaultLocation();
            _isLoadingLocation = false;
            _errorMessage = 'Location permission denied. Using default location.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = _mapService.getDefaultLocation();
          _isLoadingLocation = false;
          _errorMessage = 'Location permission denied forever. Using default location.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentLocation = _mapService.getDefaultLocation();
        _isLoadingLocation = false;
        _errorMessage = 'Error getting location. Using default location.';
      });
    }
  }

  double _calculateDistance() {
    if (_currentLocation == null) return 0;
    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      widget.listing.location.latitude,
      widget.listing.location.longitude,
    );
    return distance / 1000;
  }

  String _estimateTravelTime(double distanceKm) {
    final avgSpeedKmh = 40;
    final hours = distanceKm / avgSpeedKmh;
    final minutes = (hours * 60).round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hrs}h ${mins}min';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Getting Directions'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final markers = [
      if (_currentLocation != null)
        _mapService.createMarker(
          id: 'current',
          position: _currentLocation!,
          label: 'Your Location',
        ),
      _mapService.createMarker(
        id: widget.listing.id,
        position: widget.listing.location,
        label: widget.listing.name,
      ),
    ];

    final polylines = _currentLocation != null
        ? [
            Polyline(
              points: [_currentLocation!, widget.listing.location],
              color: Colors.blue,
              strokeWidth: 4.0,
            ),
          ]
        : <Polyline>[];

    final center = _currentLocation ?? _mapService.getDefaultLocation();
    final distance = _calculateDistance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directions'),
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Location',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.listing.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.listing.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_currentLocation != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.straighten, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              '${distance.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'Distance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        Column(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(height: 4),
                            Text(
                              _estimateTravelTime(distance),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                            const Text(
                              'Est. Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: MapWidget(
              controller: _mapController,
              center: center,
              zoom: 13,
              markers: markers,
              polylines: polylines,
            ),
          ),
        ],
      ),
    );
  }
}
