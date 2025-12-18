import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../widgets/auth_base_ui.dart';
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

  Future<void> _register() async {
  setState(() => _loading = true);

  try {
    final res = await AuthService.register(
      name: _nameCtrl.text.trim(),
      emailId: _emailCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
    );

    final int messageCode = res['messageCode'];
    final String message = res['message'] ?? 'Unknown error';

    if (!mounted) return;

    // ✅ BOTH 100 & 108 → OTP FLOW
    if (messageCode == 100 || messageCode == 108) {
      _otpToken = res['data']?['token'];

      AppPopup.show(
        context,
        title: "OTP Sent",
        message: message,
        type: PopupType.success,
      );

      setState(() => _showOtp = true);
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

  try {
    final res = await AuthService.verifyOtp(
      emailId: _emailCtrl.text.trim(),
      token: _otpToken!,
      otpCode: _otpCtrl.text.trim(),
    );

    final int messageCode = res['messageCode'];
    final String message = res['message'] ?? 'Unknown response';

    if (!mounted) return;

    if (messageCode == 100) {
      AppPopup.show(
        context,
        title: "Success",
        message: message,
        type: PopupType.success,
      );

      // ✅ Navigate ONLY after OK
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
    });
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

  @override
  Widget build(BuildContext context) {
    return AuthBaseUI(
      title: _showOtp ? "Verify OTP" : "Create Account",
      subtitle: _showOtp
          ? "Enter the 6 digit OTP"
          : "Register to get started",
      form: _showOtp ? _otpForm() : _registerForm(),
      footer: const SizedBox(),
    );
  }

  Widget _registerForm() => Column(
        children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Name")),
          const SizedBox(height: 12),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email")),
          const SizedBox(height: 12),
          TextField(controller: _mobileCtrl, decoration: const InputDecoration(labelText: "Mobile")),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _register,
            child: const Text("Register"),
          ),
        ],
      );

  Widget _otpForm() => Column(
        children: [
          TextField(
            controller: _otpCtrl,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "OTP",
              errorText: _otpError,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _verifyOtp,
            child: const Text("Verify OTP"),
          ),
        ],
      );
}
