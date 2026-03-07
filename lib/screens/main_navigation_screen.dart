import 'package:flutter/material.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/screens/directory/directory_screen.dart';
import 'package:assignment2/screens/map/map_view_screen.dart';
import 'package:assignment2/screens/my_listings/my_listings_screen.dart';
import 'package:assignment2/screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      
      // Start listening to all listings
      listingProvider.listenToAllListings();
      
      // Load user listings
      if (authProvider.user != null) {
        listingProvider.listenToUserListings(authProvider.user!.uid);
      }
    });

    _screens = [
      const DirectoryScreen(),
      const MyListingsScreen(),
      const MapViewScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}