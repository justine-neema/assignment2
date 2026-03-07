import 'package:flutter/material.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/screens/listing/listing_detail_screen.dart';
import 'package:assignment2/widgets/listing_card.dart';
import 'package:assignment2/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
void initState() {
  super.initState();
}

@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search listings...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  onChanged: (value) {
                    Provider.of<ListingProvider>(context, listen: false)
                        .setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 8),
                // Category filter
                Consumer<ListingProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: provider.selectedCategory == 'All',
                            onSelected: (selected) {
                              provider.setCategory('All');
                            },
                          ),
                          const SizedBox(width: 8),
                          ...ListingModel.categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: provider.selectedCategory == category,
                                onSelected: (selected) {
                                  provider.setCategory(category);
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
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
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final filteredListings = provider.getFilteredListings();

          if (filteredListings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.list_alt,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No listings found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Be the first to add a listing!'
                        : 'Try adjusting your search or filters',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredListings.length,
            itemBuilder: (context, index) {
              final listing = filteredListings[index];
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
              );
            },
          );
        },
      ),
    );
  }
}