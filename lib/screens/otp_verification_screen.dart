import 'package:flutter/material.dart';
import 'package:task_manager_app_assignment/screens/reset_password_screen.dart';
import '../models/api_response.dart';
import '../service/api_caller.dart';
import '../theme/theme_data.dart';
import '../utils/urls.dart';
import '../widgets/screen_background.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final otp = _otpController.text.trim();
    final ApiResponse response = await ApiCaller.getRequest(
      url: Urls.recoverVerifyOtpURL(widget.email, otp),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final data = response.responseData;
    final success =
        response.isSuccess && data is Map && data['status'] == 'success';
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email, otp: otp),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          response.errorMessage ??
              'The verification code is invalid or expired.',
        ),
      ),
    );
  }

  Future<void> _resendCode() async {
    if (_isResending || _isLoading) return;
    setState(() => _isResending = true);
    final response = await ApiCaller.getRequest(
      url: Urls.recoverVerifyEmailURL(widget.email),
    );
    if (!mounted) return;
    setState(() => _isResending = false);
    final data = response.responseData;
    final success =
        response.isSuccess && data is Map && data['status'] == 'success';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          success
              ? 'A new verification code has been sent.'
              : (response.errorMessage ?? 'Unable to resend the code.'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: kPrimary,
                          size: 31,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Check your email',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF64748B),
                          ),
                          children: [
                            const TextSpan(
                              text: 'Enter the verification code sent to ',
                            ),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: kText,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Verification code',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _verifyOtp(),
                        decoration: const InputDecoration(
                          hintText: 'Enter OTP code',
                          prefixIcon: Icon(Icons.password_rounded),
                        ),
                        validator: (value) {
                          if ((value?.trim().isEmpty ?? true)) {
                            return 'Enter the verification code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Verify code'),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: (_isResending || _isLoading)
                              ? null
                              : _resendCode,
                          child: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Didn\'t receive a code? Resend'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
