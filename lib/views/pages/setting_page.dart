import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pos_system_legphel/bloc/menu_from_api/bloc/menu_from_api_bloc.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:pos_system_legphel/models/settings/app_settings.dart';
import 'package:pos_system_legphel/views/widgets/drawer_widget.dart';
import 'package:pos_system_legphel/views/pages/Add Items/branch_settings_page.dart';
import 'package:pos_system_legphel/views/pages/Add Items/ip_address_page.dart';
import 'package:pos_system_legphel/views/pages/privacy_policy_page.dart';
import 'package:pos_system_legphel/views/pages/help_support_page.dart';
import 'package:pos_system_legphel/providers/theme_provider.dart';
import 'package:pos_system_legphel/services/network_service.dart';
import 'package:pos_system_legphel/bloc/auth_bloc/auth_bloc.dart';
import 'package:pos_system_legphel/views/pages/settings_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _showFetchButton = false;
  bool _notificationsEnabled = true;
  bool _autoSync = false;
  bool _isServerAvailable = false;
  final NetworkService _networkService =
      NetworkService(baseUrl: 'http://119.2.105.142:3800');
  Timer? _serverStatusTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    context.read<MenuApiBloc>().add(FetchMenuApi());
    _checkServerStatus();
    // Check server status every 30 seconds
    _serverStatusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkServerStatus();
    });
  }

  @override
  void dispose() {
    _serverStatusTimer?.cancel();
    super.dispose();
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

  Future<void> _checkServerStatus() async {
    final isAvailable = await _networkService.isServerAvailable();
    if (mounted) {
      setState(() {
        _isServerAvailable = isAvailable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.isDarkMode
                  ? [theme.colorScheme.surface, theme.colorScheme.background]
                  : [const Color(0xFFBBDEFB), const Color(0xFF0A1F36)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.isDarkMode
                ? [theme.colorScheme.surface, theme.colorScheme.background]
                : [Colors.white, const Color(0xFFFFF0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  prefixIcon: Icon(Icons.search,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            _buildSectionHeader('Appearance'),
            _buildSettingTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark theme',
              color: theme.colorScheme.primary,
              trailing: _buildCustomSwitch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeColor: theme.colorScheme.primary,
              ),
            ),
            _buildSectionHeader('Menu Settings'),
            _buildSettingTile(
              icon: Icons.sync,
              title: 'Show Fetch Button',
              subtitle:
                  'Enable to show the fetch button for API synchronization',
              color: ThemeProvider.successColor,
              trailing: _buildCustomSwitch(
                value: _showFetchButton,
                onChanged: _toggleFetchButton,
                activeColor: ThemeProvider.successColor,
              ),
            ),
            _buildSettingTile(
              icon: Icons.cloud_sync,
              title: 'Auto Sync',
              subtitle: 'Automatically sync menu data periodically',
              color: theme.colorScheme.primary,
              trailing: _buildCustomSwitch(
                value: _autoSync,
                onChanged: (value) => setState(() => _autoSync = value),
                activeColor: theme.colorScheme.primary,
              ),
            ),
            _buildSectionHeader('Notifications'),
            _buildSettingTile(
              icon: Icons.notifications,
              title: 'Enable Notifications',
              subtitle: 'Receive important system notifications',
              color: const Color(0xFFFF9500),
              trailing: _buildCustomSwitch(
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
                activeColor: const Color(0xFFFF9500),
              ),
            ),
            _buildSectionHeader('System Settings'),
            _buildSettingTile(
              icon: Icons.cloud_done,
              title: 'Server Status',
              subtitle:
                  _isServerAvailable ? 'Server is online' : 'Server is offline',
              color: _isServerAvailable
                  ? ThemeProvider.successColor
                  : ThemeProvider.errorColor,
              trailing: Icon(
                _isServerAvailable ? Icons.check_circle : Icons.error,
                color: _isServerAvailable
                    ? ThemeProvider.successColor
                    : ThemeProvider.errorColor,
              ),
            ),
            _buildSettingTile(
              icon: Icons.business_rounded,
              title: 'Branch Settings',
              subtitle: 'Configure branch information and settings',
              color: ThemeProvider.errorColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BranchSettingsPage(),
                ),
              ),
            ),
            _buildSectionHeader('Security'),
            _buildSettingTile(
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Update your login credentials',
              color: theme.colorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              ),
            ),
            _buildSettingTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              color: ThemeProvider.errorColor,
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
            _buildSettingTile(
              icon: Icons.print_rounded,
              title: 'Printer IP',
              subtitle: 'Configure printer network settings',
              color: ThemeProvider.successColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IpAddressPage(),
                ),
              ),
            ),
            _buildSectionHeader('About'),
            _buildSettingTile(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.2.3',
              color: theme.colorScheme.onSurface,
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'View our privacy practices',
              color: const Color(0xFFAF52DE),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              ),
            ),
            _buildSettingTile(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Contact our support team',
              color: ThemeProvider.errorColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportPage(),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: const DrawerWidget(),
    );
  }

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Transform.scale(
      scale: 0.9,
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeColor.withOpacity(0.5),
        inactiveThumbColor: Colors.grey[300],
        inactiveTrackColor: Colors.grey[400],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: 0.5,
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            trailing: trailing,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            minVerticalPadding: 12,
          ),
        ),
      ),
    );
  }
}
