import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wages/shared/providers/auth_provider.dart';

class OTPResetPasswordScreen extends ConsumerStatefulWidget {
  const OTPResetPasswordScreen({super.key});

  @override
  ConsumerState<OTPResetPasswordScreen> createState() =>
      _OTPResetPasswordScreenState();
}

class _OTPResetPasswordScreenState
    extends ConsumerState<OTPResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String? _successMessage;

  // 10 minutes timer
  int _remainingSeconds = 600;
  Timer? _timer;
  bool _isExpired = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 600;
      _isExpired = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isExpired = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();

      await ref.read(authNotifierProvider.notifier).sendPasswordResetOTP(
            email: email,
          );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
          _startTimer();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📧 OTP sent! Check your email.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Verify OTP via RPC before showing password fields
  /// ✅ Verify OTP - Just check format and show password fields
/// The actual verification happens in resetPasswordWithOTP
Future<void> _verifyOTP() async {
  final otp = _otpController.text.trim();

  if (otp.length != 6) {
    setState(() {
      _errorMessage = 'Please enter a valid 6-digit OTP';
    });
    return;
  }

  if (_isExpired) {
    setState(() {
      _errorMessage = 'OTP has expired. Please request a new one.';
    });
    return;
  }

  // ✅ Just show password fields - verification happens during reset
  setState(() {
    _isLoading = false;
    _otpVerified = true;
    _errorMessage = null;
    _timer?.cancel();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Enter your new password below.'),
      duration: Duration(seconds: 2),
    ),
  );
}
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final otp = _otpController.text.trim();
      final newPassword = _passwordController.text;

      // ✅ Pass all three parameters to resetPasswordWithOTP
      await ref.read(authNotifierProvider.notifier).resetPasswordWithOTP(
            email: email,
            otp: otp,
            newPassword: newPassword,
          );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = '✅ Password updated successfully!\n\nYou can now login with your new password.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Password updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _otpVerified
                            ? Colors.green.shade50
                            : _otpSent
                                ? Colors.orange.shade50
                                : Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _otpVerified
                            ? Icons.check_circle
                            : _otpSent
                                ? Icons.pin
                                : Icons.lock_reset,
                        size: 60,
                        color: _otpVerified
                            ? Colors.green.shade700
                            : _otpSent
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _otpVerified
                        ? 'Set New Password'
                        : _otpSent
                            ? 'Enter OTP Code'
                            : 'Reset Password',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    _otpVerified
                        ? 'Enter your new password below'
                        : _otpSent
                            ? 'Enter the 6-digit code sent to your email'
                            : 'Enter your email to receive a security code',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Success message (after password reset)
                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _successMessage!,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C5B92),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Go to Login'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ============================================================
                    // STEP 1: EMAIL FIELD (Before OTP sent)
                    // ============================================================
                    if (!_otpSent) ...[
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF4C5B92),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : const Text(
                                'Send OTP Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],

                    // ============================================================
                    // STEP 2: OTP FIELD (After OTP sent, before verification)
                    // ============================================================
                    if (_otpSent && !_otpVerified) ...[
                      TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: '6-Digit OTP Code',
                          prefixIcon: const Icon(Icons.pin),
                          border: const OutlineInputBorder(),
                          hintText: 'Enter 6-digit code',
                          helperText: _isExpired
                              ? '⏰ OTP Expired! Please request a new one.'
                              : '⏰ OTP expires in ${_formatTime(_remainingSeconds)}',
                          helperStyle: TextStyle(
                            color: _isExpired
                                ? Colors.red.shade700
                                : _remainingSeconds < 120
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade600,
                            fontWeight: _isExpired || _remainingSeconds < 120
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        enabled: !_isExpired,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (_isExpired) {
                            return 'OTP has expired. Please request a new one.';
                          }
                          if (value == null || value.isEmpty) {
                            return 'Please enter the OTP code';
                          }
                          if (value.length != 6) {
                            return 'OTP must be 6 digits';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _isLoading || _isExpired ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _isExpired
                              ? Colors.grey
                              : const Color(0xFF4C5B92),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : Text(
                                _isExpired ? 'OTP Expired' : 'Verify OTP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: TextButton(
                          onPressed: _sendOTP,
                          child: Text(
                            _isExpired ? 'Request New OTP' : 'Resend OTP',
                            style: TextStyle(
                              color: const Color(0xFF4C5B92),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ============================================================
                    // STEP 3: NEW PASSWORD & CONFIRM (After OTP verified)
                    // ============================================================
                    if (_otpVerified) ...[
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscurePassword,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscureConfirm,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF4C5B92),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : const Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}