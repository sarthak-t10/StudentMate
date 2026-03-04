import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: const AppLogo(),
        title: const Text('Create Account'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, responsive) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      controller: _fullNameController,
                      prefixIcon: Icons.person,
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    CustomTextField(
                      label: 'Email Address',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    CustomTextField(
                      label: 'Confirm Password',
                      hintText: 'Confirm your password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Type',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimaryColor,
                                    fontSize: responsive.bodyFontSize,
                                  ),
                        ),
                        SizedBox(height: responsive.spacingSmall),
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
                      ],
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branch',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimaryColor,
                                    fontSize: responsive.bodyFontSize,
                                  ),
                        ),
                        SizedBox(height: responsive.spacingSmall),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBranch,
                          onChanged: (value) {
                            setState(() =>
                                _selectedBranch = value ?? _selectedBranch);
                          },
                          items: _branches
                              .map((branch) => DropdownMenuItem(
                                    value: branch,
                                    child: Text(branch),
                                  ))
                              .toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  responsive.radiusMedium),
                              borderSide: BorderSide(
                                color: AppColors.purpleDark.withOpacity(0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  responsive.radiusMedium),
                              borderSide: BorderSide(
                                color: AppColors.purpleDark.withOpacity(0.2),
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Section',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimaryColor,
                                    fontSize: responsive.bodyFontSize,
                                  ),
                        ),
                        SizedBox(height: responsive.spacingSmall),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSection,
                          onChanged: (value) {
                            setState(() =>
                                _selectedSection = value ?? _selectedSection);
                          },
                          items: _sections
                              .map((section) => DropdownMenuItem(
                                    value: section,
                                    child: Text(section),
                                  ))
                              .toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  responsive.radiusMedium),
                              borderSide: BorderSide(
                                color: AppColors.purpleDark.withOpacity(0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  responsive.radiusMedium),
                              borderSide: BorderSide(
                                color: AppColors.purpleDark.withOpacity(0.2),
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        onPressed: _isLoading ? () {} : _handleSignUp,
                        label: _isLoading ? 'Creating Account...' : 'Sign Up',
                      ),
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/signin');
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: responsive.bodyFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                ),
          borderRadius: BorderRadius.circular(responsive.radiusMedium),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.purpleDark.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: responsive.smallFontSize,
          ),
        ),
      ),
    );
  }
}
