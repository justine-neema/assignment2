import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:assignment2/core/utils/validators.dart';
import 'package:assignment2/models/listing_model.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:assignment2/widgets/custom_textfield.dart';
import 'package:assignment2/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class AddEditListingScreen extends StatefulWidget {
  final ListingModel? listing;

  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  String _selectedCategory = ListingModel.categories[0];
  LatLng? _selectedLocation;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) {
      // Edit mode - populate fields
      _nameController.text = widget.listing!.name;
      _addressController.text = widget.listing!.address;
      _contactController.text = widget.listing!.contactNumber;
      _descriptionController.text = widget.listing!.description;
      _websiteController.text = widget.listing!.website ?? '';
      _emailController.text = widget.listing!.email ?? '';
      _selectedCategory = widget.listing!.category;
      _latitudeController.text = widget.listing!.latitude.toString();
      _longitudeController.text = widget.listing!.longitude.toString();
      _selectedLocation = LatLng(
        widget.listing!.latitude,
        widget.listing!.longitude,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location captured successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Get coordinates from text fields or selected location
    double? latitude;
    double? longitude;
    
    if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty) {
      latitude = double.tryParse(_latitudeController.text);
      longitude = double.tryParse(_longitudeController.text);
    } else if (_selectedLocation != null) {
      latitude = _selectedLocation!.latitude;
      longitude = _selectedLocation!.longitude;
    }
    
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid coordinates or select location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a listing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isEditing = widget.listing != null;
    
    final listing = ListingModel(
      id: widget.listing?.id ?? '', // Will be auto-generated by service for new listings
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      createdBy: authProvider.user!.uid,
      createdAt: widget.listing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: widget.listing?.imageUrl,
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    bool success;
    if (isEditing) {
      success = await listingProvider.updateListing(listing);
    } else {
      success = await listingProvider.createListing(listing);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Listing updated successfully'
                : 'Listing created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.listing != null;
    final listingProvider = Provider.of<ListingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add Listing'),
      ),
      body: listingProvider.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Place/Service Name',
                      prefixIcon: Icons.place,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ListingModel.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Manual Coordinate Entry
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _latitudeController,
                            label: 'Latitude',
                            prefixIcon: Icons.location_on,
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextField(
                            controller: _longitudeController,
                            label: 'Longitude',
                            prefixIcon: Icons.location_on,
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Default Kigali: -1.9441, 30.0619',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Use Current Location Button
                    OutlinedButton.icon(
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                      icon: _isGettingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isGettingLocation
                            ? 'Getting Location...'
                            : 'Use Current Location',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      prefixIcon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) => Validators.validateNotEmpty(value, 'Address'),
                    ),
                    const SizedBox(height: 16),

                    // Contact
                    CustomTextField(
                      controller: _contactController,
                      label: 'Contact Number',
                      prefixIcon: Icons.phone,
                      validator: (value) => Validators.validateNotEmpty(value, 'Contact number'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Website (optional)
                    CustomTextField(
                      controller: _websiteController,
                      label: 'Website (optional)',
                      prefixIcon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),

                    // Email (optional)
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email (optional)',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                      validator: (value) => Validators.validateNotEmpty(value, 'Description'),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: _saveListing,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(isEditing ? 'Update Listing' : 'Create Listing'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}