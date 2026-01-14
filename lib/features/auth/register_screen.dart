import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../common/popup/app_popup.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _showOtp = false;
  bool _loading = false;

  String? _otpToken; // save token from register
  String? _otpError;

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> _register() async {
    setState(() => _loading = true);

    try {
      final res = await AuthService.register(
        name: _nameCtrl.text.trim(),
        emailId: _emailCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
      );

      final int messageCode = res['messageCode'] ?? 0;
      final String message = res['message'] ?? 'Unknown error';

      if (!mounted) return;

      // BOTH 100 & 108 -> OTP FLOW
      if (messageCode == 100 || messageCode == 108) {
        _otpToken = res['data']?['token'];

        AppPopup.show(
          context,
          title: "OTP Sent",
          message: message,
          type: PopupType.success,
        );

        setState(() => _showOtp = true);
      } else if (messageCode == 126) {
        AppPopup.show(
          context,
          title: "Already Registered",
          message: message,
          type: PopupType.error,
        );
      } else {
        AppPopup.show(
          context,
          title: "Registration Failed",
          message: message,
          type: PopupType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppPopup.show(
        context,
        title: "Error",
        message: e.toString(),
        type: PopupType.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6) {
      setState(() => _otpError = "OTP must be 6 digits");
      return;
    }

    setState(() {
      _otpError = null;
      _loading = true;
    });

    if (_otpToken == null) {
      setState(() => _otpError = "Session expired, please register again");
      return;
    }

    try {
      final res = await AuthService.verifyOtp(
        emailId: _emailCtrl.text.trim(),
        token: _otpToken!,
        otpCode: _otpCtrl.text.trim(),
      );

      final int messageCode = res['messageCode'] ?? 0;
      final String message = res['message'] ?? 'Unknown response';

      if (!mounted) return;

      if (messageCode == 100) {
        await AppPopup.show(
          context,
          title: "Success",
          message: "Login details sent to your registered email.",
          type: PopupType.success,
        );

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } else {
        AppPopup.show(
          context,
          title: "OTP Verification Failed",
          message: message,
          type: PopupType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppPopup.show(
        context,
        title: "Error",
        message: e.toString(),
        type: PopupType.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    // Back logic
                    if (_showOtp) {
                      setState(() => _showOtp = false); // Go back to reg form
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),

                const SizedBox(height: 16),

                /// Top Card
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _showOtp ? "Verify OTP" : "Create Account",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _showOtp
                                  ? "Check your email for the code"
                                  : "Join us and explore new trends",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                if (_showOtp)
                  _buildOtpForm(theme)
                else
                  _buildRegisterForm(theme, colorScheme),

                const SizedBox(height: 20),

                if (!_showOtp)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text("Log In"),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Full Name"),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: "Jane Doe",
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Email Address"),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: "jane@fashion.com",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Mobile Number"),
        const SizedBox(height: 8),
        TextField(
          controller: _mobileCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: "+1 234 567 890",
            prefixIcon: Icon(Icons.phone_android_outlined),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : const Text("Continue →"),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Enter 6-Digit Code"),
        const SizedBox(height: 8),
        TextField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: "------",
            errorText: _otpError,
            counterText: "",
            prefixIcon: const Icon(Icons.lock_clock_outlined),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _verifyOtp,
            child: _loading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : const Text("Verify & Login"),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _loading
                ? null
                : () {
                    // Resend logic if needed
                  },
            child: const Text("Resend Code"),
          ),
        ),
      ],
    );
  }
}
