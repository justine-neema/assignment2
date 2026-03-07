import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/screens/listing/listing_detail_screen.dart';
import 'package:assignment2/services/map_service.dart';
import 'package:assignment2/widgets/map_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapService _mapService = MapService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ListingProvider>(context, listen: false);
      provider.listenToAllListings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchLocation(String query) {
    if (query.isEmpty) return;
    
    // Search in listings
    final provider = Provider.of<ListingProvider>(context, listen: false);
    final results = provider.allListings.where((listing) {
      return listing.name.toLowerCase().contains(query.toLowerCase()) ||
             listing.address.toLowerCase().contains(query.toLowerCase()) ||
             listing.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isNotEmpty) {
      // Move to first result
      _mapController.move(results.first.location, 16);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found ${results.length} result(s)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No results found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_mapService.getDefaultLocation(), 13);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location, name, or category...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: _searchLocation,
            ),
          ),
          // Map
          Expanded(
            child: Consumer<ListingProvider>(
        builder: (context, provider, child) {
          if (provider.allListings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No listings to display on map'),
                ],
              ),
            );
          }

          _markers = provider.allListings.map((listing) {
            return _mapService.createMarker(
              id: listing.id,
              position: listing.location,
              label: listing.name,
              onTap: () => _showListingDetails(context, listing),
            );
          }).toList();

          return MapWidget(
            controller: _mapController,
            center: _mapService.getDefaultLocation(),
            markers: _markers,
          );
            },
          ),
        ),
      ],
      ),
    );
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
                        _mapController.move(listing.location, 16);
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
}
