import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/providers/admin_provider.dart';
import 'package:admin_app/theme/admin_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AdminTheme.navyPale,
              AdminTheme.slatePale,
              AdminTheme.navyLight.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AdminTheme.navyPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AdminTheme.navyPrimary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: Colors.white,
                      ),
                    ).animate().scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ).fadeIn(),
                    
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'Bloom IVF Admin',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Secure Admin Portal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdminTheme.textMedium,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    
                    const SizedBox(height: 48),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    Consumer<AdminProvider>(
                      builder: (context, adminProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: adminProvider.isLoading ? null : _login,
                            child: adminProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2);
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Error Message
                    Consumer<AdminProvider>(
                      builder: (context, adminProvider, child) {
                        if (adminProvider.errorMessage != null) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AdminTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AdminTheme.error),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: AdminTheme.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    adminProvider.errorMessage!,
                                    style: TextStyle(color: AdminTheme.error, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().shake().fadeIn();
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Security Notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AdminTheme.navyPale.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security, color: AdminTheme.navyDark, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Authorized access only. All login attempts are monitored.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AdminTheme.textMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
