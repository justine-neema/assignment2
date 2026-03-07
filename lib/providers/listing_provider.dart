import 'dart:async';
import 'package:flutter/material.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();
  
  List<ListingModel> _allListings = [];
  List<ListingModel> _userListings = [];
  ListingModel? _currentListing;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _allListingsSubscription;
  StreamSubscription? _userListingsSubscription;
  
  // Search and filter properties
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get userListings => _userListings;
  ListingModel? get currentListing => _currentListing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  @override
  void dispose() {
    _allListingsSubscription?.cancel();
    _userListingsSubscription?.cancel();
    super.dispose();
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Get filtered listings based on search and category
  List<ListingModel> getFilteredListings() {
    // Start with all listings
    List<ListingModel> filtered = _allListings;
    
    // Filter by category if not 'All'
    if (_selectedCategory != 'All') {
      filtered = filtered.where((listing) => 
        listing.category == _selectedCategory
      ).toList();
    }
    
    // Filter by search query if not empty
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((listing) {
        return listing.name.toLowerCase().contains(query) ||
               listing.address.toLowerCase().contains(query) ||
               listing.description.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }

  // Listen to all listings
  void listenToAllListings() {
    _allListingsSubscription?.cancel();
    _allListingsSubscription = _listingService.getAllListings().listen(
      (listings) {
        _allListings = listings;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Listen to user listings
  void listenToUserListings(String userId) {
    _userListingsSubscription?.cancel();
    _userListingsSubscription = _listingService.getUserListings(userId).listen(
      (listings) {
        _userListings = listings;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Create listing
  Future<bool> createListing(ListingModel listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _listingService.createListing(listing);
      debugPrint('Listing created with ID: $id');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating listing: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update listing
  Future<bool> updateListing(ListingModel listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _listingService.updateListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete listing
  Future<bool> deleteListing(String listingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _listingService.deleteListing(listingId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get listing by ID
  Future<ListingModel?> getListingById(String listingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final listing = await _listingService.getListingById(listingId);
      _currentListing = listing;
      _isLoading = false;
      notifyListeners();
      return listing;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Clear current listing
  void clearCurrentListing() {
    _currentListing = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}