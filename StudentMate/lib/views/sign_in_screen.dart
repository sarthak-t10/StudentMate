import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/responsive_layout_components.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final (success, user) = await _authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && user != null) {
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, responsive) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: responsive.screenHeight * 0.08),
                    const AppLogo(isLarge: true),
                    SizedBox(height: responsive.spacingLarge),
                    Text(
                      'StudentMate',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.purpleDark,
                            fontSize: responsive.isMediumScreen ? 40 : 32,
                          ),
                    ),
                    SizedBox(height: responsive.spacingMedium),
                    Text(
                      'Sign In to Your Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: responsive.titleFontSize,
                          ),
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
                    SizedBox(height: responsive.spacingMedium),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Password reset feature coming soon'),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: responsive.smallFontSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        onPressed: _isLoading ? () {} : _handleSignIn,
                        label: _isLoading ? 'Signing in...' : 'Sign In',
                      ),
                    ),
                    SizedBox(height: responsive.spacingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: responsive.bodyFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.screenHeight * 0.08),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
