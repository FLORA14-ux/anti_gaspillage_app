import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _selectedRole = 'consommateur';
  var _isLoading = false;

  final AuthService _authService = AuthService();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _authService.signIn(_enteredEmail, _enteredPassword);
      } else {
        await _authService.signUp(
          _enteredEmail,
          _enteredPassword,
          _selectedRole,
        );
      }
      // Navigation will be handled by the StreamBuilder in main.dart
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section avec illustration
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF27AE60), const Color(0xFF229954)],
                  ),
                ),
                child: Column(
                  children: [
                    // Logo/Icone
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: const Icon(
                        Icons.local_dining_rounded,
                        size: 45,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isLogin ? 'Bienvenue!' : 'Rejoins la communauté',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Lutter contre le gaspillage alimentaire'
                          : 'Ensemble, réduisons le gaspillage',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Form Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Adresse email',
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: Color(0xFF27AE60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF27AE60),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9F8),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF27AE60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF27AE60),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9F8),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredPassword = value!;
                        },
                      ),

                      // Role Selection (signup only)
                      if (!_isLogin) ...[
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Je suis un:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Consumer Option
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = 'consommateur';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedRole == 'consommateur'
                                        ? const Color(0xFF27AE60)
                                        : const Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedRole == 'consommateur'
                                      ? const Color(
                                          0xFF27AE60,
                                        ).withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: _selectedRole == 'consommateur'
                                          ? const Color(0xFF27AE60)
                                          : const Color(0xFF999999),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Consommateur',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_selectedRole == 'consommateur')
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF27AE60),
                                      )
                                    else
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: Color(0xFFCCCCCC),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Merchant Option
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = 'commercant';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedRole == 'commercant'
                                        ? const Color(0xFF27AE60)
                                        : const Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedRole == 'commercant'
                                      ? const Color(
                                          0xFF27AE60,
                                        ).withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.store_outlined,
                                      color: _selectedRole == 'commercant'
                                          ? const Color(0xFF27AE60)
                                          : const Color(0xFF999999),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Commerçant',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_selectedRole == 'commercant')
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF27AE60),
                                      )
                                    else
                                      const Icon(
                                        Icons.circle_outlined,
                                        color: Color(0xFFCCCCCC),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Submit Button
                      if (!_isLoading)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27AE60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _isLogin ? 'Connexion' : 'Inscription',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Loading Indicator
                      if (_isLoading)
                        const SizedBox(
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF27AE60),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Toggle Auth Mode Button
                      if (!_isLoading)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: _isLogin
                                  ? 'Pas encore de compte? '
                                  : 'Tu as déjà un compte? ',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: _isLogin
                                      ? 'Inscris-toi'
                                      : 'Connecte-toi',
                                  style: const TextStyle(
                                    color: Color(0xFF27AE60),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }
}
