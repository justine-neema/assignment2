import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/widgets/loading_widget.dart';
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections() async {
    if (_listing == null) return;
    
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${_listing!.latitude},${_listing!.longitude}';
    await _launchURL(url);
  }

  Future<void> _openInMaps() async {
    if (_listing == null) return;
    
    final url = 'https://www.google.com/maps/search/?api=1&query=${_listing!.latitude},${_listing!.longitude}';
    await _launchURL(url);
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
        body: const Center(
          child: Text('Listing not found'),
        ),
      );
    }

    final listing = _listing!;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Preview - Temporarily Disabled
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Map Preview Disabled',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coordinates: ${listing.latitude.toStringAsFixed(6)}, ${listing.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Chip(
                    label: Text(listing.category),
                    backgroundColor: Colors.blue.shade100,
                  ),
                  const SizedBox(height: 16),

                  // Quick actions
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
                      if (listing.website != null) ...[
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

                  // Details
                  _buildSection(
                    'Address',
                    Icons.location_on,
                    listing.address,
                  ),
                  const Divider(),
                  
                  _buildSection(
                    'Contact',
                    Icons.phone,
                    listing.contactNumber,
                  ),
                  const Divider(),
                  
                  _buildSection(
                    'Description',
                    Icons.description,
                    listing.description,
                  ),
                  const Divider(),
                  
                  if (listing.email != null)
                    _buildSection(
                      'Email',
                      Icons.email,
                      listing.email!,
                    ),
                  if (listing.email != null) const Divider(),
                  
                  _buildSection(
                    'Added by',
                    Icons.person,
                    'User ID: ${listing.createdBy.substring(0, 8)}...',
                  ),
                  const Divider(),
                  
                  _buildSection(
                    'Added on',
                    Icons.access_time,
                    _formatDate(listing.createdAt),
                  ),
                  if (listing.updatedAt != listing.createdAt) ...[
                    const Divider(),
                    _buildSection(
                      'Updated on',
                      Icons.update,
                      _formatDate(listing.updatedAt),
                    ),
                  ],
                ],
              ),
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