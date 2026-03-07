import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class ListingModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy; // User ID who created the listing
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? website;
  final String? email;
  final double? rating;
  final int? reviewCount;

  static const List<String> categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Pharmacy',
    'Bank',
    'School',
  ];

  ListingModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.website,
    this.email,
    this.rating,
    this.reviewCount,
  });

  // Helper getter for LatLng (flutter_map)
  LatLng get location => LatLng(latitude, longitude);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageUrl': imageUrl,
      'website': website,
      'email': email,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  factory ListingModel.fromMap(String id, Map<String, dynamic> map) {
    return ListingModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      address: map['address'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      website: map['website'],
      email: map['email'],
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'],
    );
  }

  // Copy with method for updates
  ListingModel copyWith({
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? website,
    String? email,
    double? rating,
    int? reviewCount,
  }) {
    return ListingModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      imageUrl: imageUrl ?? this.imageUrl,
      website: website ?? this.website,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
