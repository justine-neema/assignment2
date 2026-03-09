import 'package:flutter/material.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/screens/map/map_directions_screen.dart';
import 'package:assignment2/services/map_service.dart';
import 'package:assignment2/widgets/loading_widget.dart';
import 'package:assignment2/widgets/map_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  ListingModel? _listing;
  bool _isLoading = true;
  final MapService _mapService = MapService();

  @override
  void initState() {
    super.initState();
    _loadListing();
  }

  Future<void> _loadListing() async {
    final provider = Provider.of<ListingProvider>(context, listen: false);
    final listing = await provider.getListingById(widget.listingId);
    if (mounted) {
      setState(() {
        _listing = listing;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call'),
        content: Text('Phone: $phone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              final Uri uri = Uri.parse('tel:$phone');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _openDirections() {
    if (_listing == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapDirectionsScreen(listing: _listing!),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Listing not found')),
      );
    }

    final listing = _listing!;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: MapWidget(
                center: listing.location,
                zoom: 15,
                markers: [
                  _mapService.createMarker(
                    id: listing.id,
                    position: listing.location,
                    label: listing.name,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(listing.category),
                    backgroundColor: Colors.blue.shade100,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.phone,
                          label: 'Call',
                          color: Colors.green,
                          onTap: () => _launchPhone(listing.contactNumber),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.directions,
                          label: 'Directions',
                          color: Colors.blue,
                          onTap: _openDirections,
                        ),
                      ),
                      if (listing.website != null)
                        ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.language,
                              label: 'Website',
                              color: Colors.purple,
                              onTap: () => _launchURL(listing.website!),
                            ),
                          ),
                        ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection('Address', Icons.location_on, listing.address),
                  const Divider(),
                  _buildSection('Contact', Icons.phone, listing.contactNumber),
                  const Divider(),
                  _buildSection('Description', Icons.description, listing.description),
                  const Divider(),
                  if (listing.email != null) ...[
                    _buildSection('Email', Icons.email, listing.email!),
                    const Divider(),
                  ],
                  _buildSection('Added on', Icons.access_time, _formatDate(listing.createdAt)),
                  const Divider(),
                  _buildSection('Created by', Icons.person, listing.createdBy),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'Directory',
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'My Listings',
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Map',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
