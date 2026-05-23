import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/animated_gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  final User? initialUser;

  const ProfileScreen({Key? key, this.initialUser}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthService _authService;
  late ThemeService _themeService;
  User? _currentUser;
  AppThemeMode _selectedTheme = AppThemeMode.light;
  bool _loadingUser = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _themeService = ThemeService();
    _initializeUser();
    _loadThemePreference();
  }

  Future<void> _initializeUser() async {
    setState(() => _loadingUser = true);
    try {
      final user = widget.initialUser ?? await _authService.getCurrentUser();
      setState(() => _currentUser = user);
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      setState(() => _loadingUser = false);
    }
  }

  void _loadThemePreference() {
    setState(() {
      _selectedTheme = _themeService.getCurrentThemeMode();
    });
  }

  Future<void> _changeTheme(AppThemeMode newTheme) async {
    // Save the theme preference
    await _themeService.setThemeMode(newTheme);

    // Update the global theme notifier to trigger app rebuild
    themeModeNotifier.value = newTheme;

    setState(() => _selectedTheme = newTheme);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/signin', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isSmallPhone;

    if (_loadingUser) {
      return AnimatedGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return AnimatedGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black26,
            elevation: 0,
            title: Text(
              'Profile',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off, size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  'No user information available',
                  style: GoogleFonts.orbitron(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.orbitron(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          elevation: 0,
          title: Text(
            'Profile & Settings',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      Colors.purple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white24,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    ProfileAvatar(
                      name: _currentUser!.fullName,
                      base64Photo: _currentUser!.userPhotoUrl,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentUser!.fullName,
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentUser!.email,
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _currentUser!.userType
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // User Details Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.school,
                      title: 'Branch',
                      value: _currentUser!.branch,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      icon: Icons.groups,
                      title: 'Section',
                      value: _currentUser!.section,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: _currentUser!.email,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Theme Settings Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Settings',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Theme',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildThemeOption(
                            title: 'Light Theme',
                            description: 'Purple and pink gradient design',
                            mode: AppThemeMode.light,
                            icon: Icons.light_mode,
                          ),
                          const SizedBox(height: 12),
                          _buildThemeOption(
                            title: 'Dark Theme',
                            description: 'Dark background with purple accents',
                            mode: AppThemeMode.dark,
                            icon: Icons.dark_mode,
                          ),
                          const SizedBox(height: 12),
                          _buildThemeOption(
                            title: 'Gold Dark Theme',
                            description:
                                'Black background with gold/yellow gradient',
                            mode: AppThemeMode.goldDark,
                            icon: Icons.star,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Logout Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _logout,
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: GoogleFonts.orbitron(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String description,
    required AppThemeMode mode,
    required IconData icon,
  }) {
    final isSelected = _selectedTheme == mode;

    return GestureDetector(
      onTap: () => _changeTheme(mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.1)
              : Colors.white.withOpacity(0.03),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: mode == AppThemeMode.light
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF2246FF),
                          Color(0xFF8a2be2),
                        ],
                      )
                    : mode == AppThemeMode.goldDark
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFFA500),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade800,
                              Colors.grey.shade700,
                            ],
                          ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFFD700),
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.white54,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
