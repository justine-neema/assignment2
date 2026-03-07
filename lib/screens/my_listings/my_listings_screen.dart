import 'package:flutter/material.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/screens/listing/add_edit_listing_screen.dart';
import 'package:assignment2/screens/listing/listing_detail_screen.dart';
import 'package:assignment2/widgets/listing_card.dart';
import 'package:assignment2/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      if (authProvider.user != null) {
        listingProvider.listenToUserListings(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditListingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ListingProvider>(
        builder: (context, authProvider, listingProvider, child) {
          if (listingProvider.isLoading) {
            return const LoadingWidget();
          }

          if (listingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    listingProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (listingProvider.userListings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_location,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No listings yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first listing to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditListingScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Listing'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listingProvider.userListings.length,
            itemBuilder: (context, index) {
              final listing = listingProvider.userListings[index];
              return ListingCard(
                listing: listing,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListingDetailScreen(
                        listingId: listing.id,
                      ),
                    ),
                  );
                },
                showEditDelete: true,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditListingScreen(
                        listing: listing,
                      ),
                    ),
                  );
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Listing'),
                      content: const Text(
                        'Are you sure you want to delete this listing?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final success = await listingProvider.deleteListing(listing.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Listing deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
