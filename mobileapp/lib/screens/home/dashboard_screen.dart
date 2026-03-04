import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;
  String _apiResponse = '';
  bool _isLoading = false;

  final List<String> _tabs = ['Register', 'Login', 'Features', 'Session'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    '🏫 Campus Management',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete Authentication & Features Test',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Main Card
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Session Info Card
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: authProvider.isAuthenticated
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              border: Border.all(
                                color: authProvider.isAuthenticated
                                    ? Colors.green[300]!
                                    : Colors.blue[300]!,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  authProvider.isAuthenticated
                                      ? Icons.check_circle
                                      : Icons.info,
                                  color: authProvider.isAuthenticated
                                      ? Colors.green[700]
                                      : Colors.blue[700],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authProvider.isAuthenticated
                                            ? 'Logged In'
                                            : 'Not Logged In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: authProvider.isAuthenticated
                                              ? Colors.green[700]
                                              : Colors.blue[700],
                                        ),
                                      ),
                                      if (authProvider.isAuthenticated)
                                        Text(
                                          '${authProvider.user?.name} (${authProvider.user?.email})',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: authProvider.isAuthenticated
                                                ? Colors.green[600]
                                                : Colors.blue[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Tab Buttons
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  _tabs.length,
                                  (index) => _buildTabButton(index),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            // Tab Content
                            Container(
                              padding: const EdgeInsets.all(20),
                              child: _buildTabContent(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF667eea) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          _tabs[index],
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? const Color(0xFF667eea) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildRegisterTab();
      case 1:
        return _buildLoginTab();
      case 2:
        return _buildFeaturesTab();
      case 3:
        return _buildSessionTab();
      default:
        return const SizedBox();
    }
  }

  // ==================== REGISTER TAB ====================
  Widget _buildRegisterTab() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'Student';

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 60, color: Colors.green[700]),
                const SizedBox(height: 16),
                Text(
                  'Account created and logged in!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome, ${authProvider.user?.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'POST /api/v1/auth/register',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'your.email@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimum 6 characters',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Student', 'Faculty', 'Admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedRole = value;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (nameController.text.isEmpty) {
                          _showErrorDialog(context, 'Name is required');
                          return;
                        }
                        if (emailController.text.isEmpty) {
                          _showErrorDialog(context, 'Email is required');
                          return;
                        }
                        if (!emailController.text.contains('@')) {
                          _showErrorDialog(context, 'Please enter a valid email');
                          return;
                        }
                        if (passwordController.text.length < 6) {
                          _showErrorDialog(context, 'Password must be at least 6 characters');
                          return;
                        }
                        
                        final success = await authProvider.register(
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                          selectedRole,
                        );
                        if (!success && mounted) {
                          final errorMsg = authProvider.error ?? 'Registration failed';
                          print('Registration error: $errorMsg');
                          _showErrorDialog(context, errorMsg);
                        } else if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Account created successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Create Account'),
              ),
              if (authProvider.error != null) ...
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ==================== LOGIN TAB ====================
  Widget _buildLoginTab() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 60, color: Colors.green[700]),
                const SizedBox(height: 16),
                Text(
                  'Login successful!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome, ${authProvider.user?.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'POST /api/v1/auth/login',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'your.email@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (emailController.text.isEmpty) {
                          _showErrorDialog(context, 'Email is required');
                          return;
                        }
                        if (!emailController.text.contains('@')) {
                          _showErrorDialog(context, 'Please enter a valid email');
                          return;
                        }
                        if (passwordController.text.isEmpty) {
                          _showErrorDialog(context, 'Password is required');
                          return;
                        }
                        
                        final success = await authProvider.login(
                          emailController.text,
                          passwordController.text,
                        );
                        if (!success && mounted) {
                          final errorMsg = authProvider.error ?? 'Login failed';
                          print('Login error: $errorMsg');
                          _showErrorDialog(context, errorMsg);
                        } else if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Login successful!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  emailController.text = 'test123@example.com';
                  passwordController.text = 'password123';
                },
                child: const Text('Fill Test Account'),
              ),
              if (authProvider.error != null) ...
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ==================== FEATURES TAB ====================
  Widget _buildFeaturesTab() {
    const features = [
      'User Registration with role selection',
      'Secure Login with JWT authentication',
      'Session persistence (auto-login on app restart)',
      'View Announcements',
      'Browse Events',
      'Check Job Postings',
      'Manage User Profile',
      'Secure Logout',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Features',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ ',
                      style: TextStyle(
                        color: Color(0xFF667eea),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          Divider(height: 30, thickness: 2),
          Text(
            'API Endpoints',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const Text(
            'Auth:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const Text(
            'POST /api/v1/auth/register\nPOST /api/v1/auth/login',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Resources:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const Text(
            'GET /api/v1/announcements\nGET /api/v1/events\nGET /api/v1/jobs\nGET /api/v1/users/me',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SESSION TAB ====================
  Widget _buildSessionTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!authProvider.isAuthenticated)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No active session. Please login first.',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✓ Active Session',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildUserInfoRow(
                        'Name',
                        authProvider.user?.name ?? 'N/A',
                      ),
                      _buildUserInfoRow(
                        'Email',
                        authProvider.user?.email ?? 'N/A',
                      ),
                      _buildUserInfoRow(
                        'Role',
                        authProvider.user?.role ?? 'N/A',
                      ),
                      _buildUserInfoRow(
                        'User ID',
                        authProvider.user?.id ?? 'N/A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isLoading ? null : () => _checkSession(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Check Session'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isLoading ? null : () => _getAnnouncements(),
                  icon: const Icon(Icons.announcement),
                  label: const Text('Load Announcements'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isLoading ? null : () => _getEvents(),
                  icon: const Icon(Icons.event),
                  label: const Text('Load Events'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isLoading ? null : () => _getJobs(),
                  icon: const Icon(Icons.work),
                  label: const Text('Load Jobs'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
              if (_apiResponse.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _apiResponse,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== API CALLS ====================
  Future<void> _checkSession(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    setState(() {
      _isLoading = true;
      _apiResponse = 'Loading...';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/v1/users/me'),
        headers: {
          'Authorization': 'Bearer ${authProvider.user?.id}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _apiResponse = response.body;
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAnnouncements() async {
    setState(() {
      _isLoading = true;
      _apiResponse = 'Loading announcements...';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/v1/announcements'),
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _apiResponse = response.body;
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getEvents() async {
    setState(() {
      _isLoading = true;
      _apiResponse = 'Loading events...';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/v1/events'),
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _apiResponse = response.body;
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getJobs() async {
    setState(() {
      _isLoading = true;
      _apiResponse = 'Loading jobs...';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/v1/jobs'),
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _apiResponse = response.body;
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.error, color: Colors.red[700]),
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
