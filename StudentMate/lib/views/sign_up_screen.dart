import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';
import '../widgets/animated_gradient_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  UserType _selectedUserType = UserType.student;
  String _selectedBranch = 'CSE';
  String _selectedSection = 'A';
  bool _isLoading = false;

  final List<String> _branches = ['CSE', 'ECE', 'ME', 'EE', 'CV', 'BT'];
  final List<String> _sections = ['A', 'B', 'C'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.signUp(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      branch: _selectedBranch,
      section: _selectedSection,
      userType: _selectedUserType,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Account created successfully! Please sign in.')),
        );
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Error creating account. Email may already exist.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          elevation: 0,
          title: Text(
            'Create Account',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, responsive) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(responsive.horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: responsive.spacingLarge),
                      _buildGlassTextField(
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        controller: _fullNameController,
                        prefixIcon: Icons.person,
                      ),
                      SizedBox(height: responsive.spacingLarge),
                      _buildGlassTextField(
                        label: 'Email Address',
                        hintText: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                      ),
                      SizedBox(height: responsive.spacingLarge),
                      _buildGlassTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock,
                      ),
                      SizedBox(height: responsive.spacingLarge),
                      _buildGlassTextField(
                        label: 'Confirm Password',
                        hintText: 'Confirm your password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: Icons.lock,
                      ),
                      SizedBox(height: responsive.spacingLarge),
                      _buildFormLabel('User Type'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUserTypeButton(
                                'Student', UserType.student, responsive),
                          ),
                          SizedBox(width: responsive.spacingMedium),
                          Expanded(
                            child: _buildUserTypeButton(
                                'Faculty', UserType.faculty, responsive),
                          ),
                          SizedBox(width: responsive.spacingMedium),
                          Expanded(
                            child: _buildUserTypeButton(
                                'Admin', UserType.admin, responsive),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.spacingLarge),
                      _buildGlassDropdown(
                        label: 'Branch',
                        value: _selectedBranch,
                        items: _branches,
                        onChanged: (value) {
                          setState(
                              () => _selectedBranch = value ?? _selectedBranch);
                        },
                      ),
                      SizedBox(height: responsive.spacingLarge),
                      _buildGlassDropdown(
                        label: 'Section',
                        value: _selectedSection,
                        items: _sections,
                        onChanged: (value) {
                          setState(() =>
                              _selectedSection = value ?? _selectedSection);
                        },
                      ),
                      SizedBox(height: responsive.spacingLarge * 1.5),
                      SizedBox(
                        width: double.infinity,
                        child: _buildGoldenButton(
                          onPressed: _isLoading ? () {} : _handleSignUp,
                          label: _isLoading ? 'Creating Account...' : 'Sign Up',
                          isLoading: _isLoading,
                        ),
                      ),
                      SizedBox(height: responsive.spacingLarge),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.orbitron(
                              fontSize: responsive.bodyFontSize,
                              color: Colors.white70,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/signin');
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.orbitron(
                                fontSize: responsive.bodyFontSize,
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.spacingLarge),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.orbitron(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGlassTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1),
            color: Colors.white.withOpacity(0.08),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.orbitron(
                color: Colors.white54,
                fontSize: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.white54, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1),
            color: Colors.white.withOpacity(0.08),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.orbitron(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            dropdownColor: Colors.grey[800],
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 14,
            ),
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeButton(
      String label, UserType userType, ResponsiveHelper responsive) {
    final isSelected = _selectedUserType == userType;
    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = userType),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: responsive.spacingMedium,
          horizontal: responsive.spacingSmall,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                )
              : LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            color: isSelected ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGoldenButton({
    required VoidCallback onPressed,
    required String label,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black.withOpacity(0.7),
                        ),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
