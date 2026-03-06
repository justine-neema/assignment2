import 'package:flutter/material.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await Provider.of<AuthProvider>(context, listen: false).signOut();
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          final user = provider.user;
          final userModel = provider.userModel;

          if (user == null) {
            return const Center(
              child: Text('Not authenticated'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade200,
                      child: Text(
                        user.email?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userModel?.displayName ?? 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          if (user.emailVerified)
                            const Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Email Verified',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Email Not Verified',
                              style: TextStyle(color: Colors.orange),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preferences Section
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Notifications Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Location-based Notifications'),
                  subtitle: const Text(
                    'Receive notifications about nearby places',
                  ),
                  secondary: const Icon(Icons.notifications),
                  value: userModel?.notificationsEnabled ?? true,
                  onChanged: (value) {
                    provider.updateNotificationsPreference(value);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Member Since'),
                      subtitle: Text(
                        userModel != null
                            ? '${userModel.createdAt.day}/${userModel.createdAt.month}/${userModel.createdAt.year}'
                            : 'Unknown',
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: const Text('Total Listings'),
                      subtitle: const Text('View your statistics'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to statistics
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About Section
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('App Version'),
                      subtitle: const Text('1.0.0'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.open_in_new, size: 16),
                      onTap: () {
                        // Open privacy policy
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Open help
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}