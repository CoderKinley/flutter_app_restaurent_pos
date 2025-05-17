import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:pos_system_legphel/models/settings/app_settings.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _showFetchButton = false;
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _autoSync = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    context.read<MenuApiBloc>().add(FetchMenuApi());
  }

  Future<void> _loadSettings() async {
    final showFetchButton = await AppSettings.getShowFetchButton();
    setState(() {
      _showFetchButton = showFetchButton;
    });
  }

  Future<void> _toggleFetchButton(bool value) async {
    await AppSettings.setShowFetchButton(value);
    setState(() {
      _showFetchButton = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFBBDEFB), // Very light blue
                Color(0xFF0A1F36), // Your dark blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            // Header with search
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Settings Sections
            _buildSectionHeader('Appearance'),
            _buildSettingTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark theme',
              color: const Color(0xFF5856D6), // Apple purple
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
            ),

            _buildSectionHeader('Menu Settings'),
            _buildSettingTile(
              icon: Icons.sync,
              title: 'Show Fetch Button',
              subtitle:
                  'Enable to show the fetch button for API synchronization',
              color: const Color(0xFF34C759), // Apple green
              trailing: Switch(
                value: _showFetchButton,
                onChanged: _toggleFetchButton,
              ),
            ),
            _buildSettingTile(
              icon: Icons.cloud_sync,
              title: 'Auto Sync',
              subtitle: 'Automatically sync menu data periodically',
              color: const Color(0xFF007AFF), // Apple blue
              trailing: Switch(
                value: _autoSync,
                onChanged: (value) {
                  setState(() {
                    _autoSync = value;
                  });
                },
              ),
            ),

            _buildSectionHeader('Notifications'),
            _buildSettingTile(
              icon: Icons.notifications,
              title: 'Enable Notifications',
              subtitle: 'Receive important system notifications',
              color: const Color(0xFFFF9500), // Apple orange
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),

            _buildSectionHeader('About'),
            _buildSettingTile(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.2.3',
              color: Colors.grey, // Neutral gray
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'View our privacy practices',
              color: const Color(0xFFAF52DE), // Apple pink
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Contact our support team',
              color: const Color(0xFFFF3B30), // Apple red
              onTap: () {},
            ),
          ],
        ),
      ),
      drawer: const DrawerWidget(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
