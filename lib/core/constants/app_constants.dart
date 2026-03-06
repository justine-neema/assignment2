class AppConstants {
  static const String appName = 'Kigali City Services';
  static const String appVersion = '1.0.0';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';
  
  // Categories
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

  // Validation regex
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^[0-9]{10}$';
  
  // Pagination
  static const int listingsPerPage = 10;
  
  // Map defaults
  static const double defaultMapLatitude = -1.9441; // Kigali coordinates
  static const double defaultMapLongitude = 30.0619;
  static const double defaultMapZoom = 13.0;
}