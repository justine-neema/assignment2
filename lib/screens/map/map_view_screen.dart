import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/screens/listing/listing_detail_screen.dart';
import 'package:provider/provider.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Listen to listings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ListingProvider>(context, listen: false);
      provider.listenToAllListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'Map View Temporarily Disabled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Google Maps API key is required for this feature.\nYou can still view listings in the Directory.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateMarkers(List<ListingModel> listings) {
    final newMarkers = listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getCategoryHue(listing.category),
        ),
        onTap: () {
          _showListingDetails(context, listing);
        },
      );
    }).toSet();

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  double _getCategoryHue(String category) {
    switch (category) {
      case 'Hospital':
        return BitmapDescriptor.hueRed;
      case 'Police Station':
        return BitmapDescriptor.hueBlue;
      case 'Library':
        return BitmapDescriptor.hueGreen;
      case 'Restaurant':
        return BitmapDescriptor.hueOrange;
      case 'Café':
        return BitmapDescriptor.hueViolet;
      case 'Park':
        return BitmapDescriptor.hueGreen;
      case 'Tourist Attraction':
        return BitmapDescriptor.hueYellow;
      case 'Pharmacy':
        return BitmapDescriptor.hueCyan;
      case 'Bank':
        return BitmapDescriptor.hueAzure;
      case 'School':
        return BitmapDescriptor.hueMagenta;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _refreshMarkers() {
    final provider = Provider.of<ListingProvider>(context, listen: false);
    provider.listenToAllListings();
  }

  void _showListingDetails(BuildContext context, ListingModel listing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(listing.category),
                backgroundColor: Colors.blue.shade100,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.address,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListingDetailScreen(
                              listingId: listing.id,
                            ),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _animateToLocation(listing.location);
                      },
                      child: const Text('Center Map'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _animateToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16),
    );
  }
}