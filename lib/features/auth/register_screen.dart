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

  String? _token;
  String? _otpError;

  Future<void> _register() async {
    setState(() => _loading = true);

    final res = await AuthService.register(
      name: _nameCtrl.text.trim(),
      emailId: _emailCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
    );

    if (!mounted) return;

    if (res['messageCode'] == 100) {
      _token = res['token'];

      AppPopup.show(
        context,
        title: "OTP Sent",
        message: "OTP sent to your registered email",
        type: PopupType.success,
      );

      setState(() => _showOtp = true);
    } else {
      AppPopup.show(
        context,
        title: "Register Failed",
        message: res['message'] ?? "Error",
        type: PopupType.error,
      );
    }

    setState(() => _loading = false);
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

    final res = await AuthService.verifyOtp(
      emailId: _emailCtrl.text.trim(),
      token: _token!,
      otpCode: _otpCtrl.text.trim(),
    );

    if (!mounted) return;

    if (res['messageCode'] == 100) {
      AppPopup.show(
        context,
        title: "Registration Successful",
        message: "Your account has been created",
        type: PopupType.success,
      );

      // Navigate ONLY after OK click
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/main');
      });
    } else {
      AppPopup.show(
        context,
        title: "OTP Failed",
        message: res['message'],
        type: PopupType.error,
      );
    }

    setState(() => _loading = false);
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
