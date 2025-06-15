import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Task Pop
                // Center(
                //   child: Image.asset(
                //     'assets/images/logomobile.png',
                //     height: 180,
                //     width: 180,
                //     fit: BoxFit.contain,
                //   ),
                // ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your account to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                            // prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            border: Theme.of(context).inputDecorationTheme.border,
                            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan nama';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                            // prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.onSurface),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            border: Theme.of(context).inputDecorationTheme.border,
                            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Masukkan email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                            // prefixIcon: Icon(Icons.lock, color: Theme.of(context).colorScheme.onSurface),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            border: Theme.of(context).inputDecorationTheme.border,
                            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan password';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                      _errorMessage = null;
                                    });
                                    try {
                                      final response = await Supabase.instance.client.auth.signUp(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        data: {'name': _nameController.text},
                                      );
                                      if (response.user != null) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Register berhasil! Silakan login.'),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        setState(() {
                                          _errorMessage = 'Register gagal. Cek email/password!';
                                        });
                                      }
                                    } on AuthException catch (e) {
                                      setState(() {
                                        _errorMessage = e.message;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _errorMessage = e.toString();
                                      });
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )),
                              ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                                  ),
                                )
                              : Text(
                                  'Sign Up',
                                  style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                    ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Already have an account? Sign In',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}