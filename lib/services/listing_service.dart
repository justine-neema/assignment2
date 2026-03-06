import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assignment2/core/constants/app_constants.dart';
import 'package:assignment2/models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create listing
  Future<String> createListing(ListingModel listing) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.listingsCollection)
          .doc(); // Auto-generate ID
      
      final newListing = ListingModel(
        id: docRef.id,
        name: listing.name,
        category: listing.category,
        address: listing.address,
        contactNumber: listing.contactNumber,
        description: listing.description,
        latitude: listing.latitude,
        longitude: listing.longitude,
        createdBy: listing.createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: listing.imageUrl,
        website: listing.website,
        email: listing.email,
      );

      await docRef.set(newListing.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  // Get all listings
  Stream<List<ListingModel>> getAllListings() {
    return _firestore
        .collection(AppConstants.listingsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ListingModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // Get user's listings
  Stream<List<ListingModel>> getUserListings(String userId) {
    return _firestore
        .collection(AppConstants.listingsCollection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ListingModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // Update listing
  Future<void> updateListing(ListingModel listing) async {
    try {
      await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listing.id)
          .update(listing.toMap());
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  // Delete listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listingId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  // Get single listing
  Future<ListingModel?> getListingById(String listingId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(listingId)
          .get();
      
      if (doc.exists) {
        return ListingModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get listing: $e');
    }
  }

  // Get listings by category
  Stream<List<ListingModel>> getListingsByCategory(String category) {
    return _firestore
        .collection(AppConstants.listingsCollection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ListingModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // Search listings by name
  Future<List<ListingModel>> searchListings(String query) async {
    try {
      // Note: For better search, consider using Firebase Extensions like Algolia
      final snapshot = await _firestore
          .collection(AppConstants.listingsCollection)
          .orderBy('name')
          .startAt([query]).endAt(['$query\uf8ff'])
          .get();
      
      return snapshot.docs.map((doc) {
        return ListingModel.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }
}