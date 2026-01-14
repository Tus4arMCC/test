import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../common/popup/app_popup.dart';
import '../../core/storage/auth_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      final res = await AuthService.login(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final int messageCode = res['messageCode'] ?? 0;
      final String message = res['message'] ?? 'Something went wrong';

      if (!mounted) return;

      if (messageCode == 100) {
        // Save Auth Data
        final data = res['data'];
        if (data != null) {
          final String token = data['token'] ?? "";
          final String pkToken = data['pksoft_token'] ?? "";
          final Map<String, dynamic> userModel = data['userModel'] ?? {};

          await AuthStorage.saveLoginData(
            jwt: token,
            pkToken: pkToken,
            userModel: userModel,
          );
        }

        AppPopup.show(
          context,
          title: "Success",
          message: message,
          type: PopupType.success,
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            // Navigate back to MainTabScreen and clear stack
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          }
        });
      } else {
        AppPopup.show(
          context,
          title: "Login Failed",
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
                  onPressed: () => Navigator.pushNamed(context, '/'),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),

                const SizedBox(height: 16),

                /// Top Card (still custom, brand-based)
                Container(
                  height: 220,
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
                ),

                const SizedBox(height: 28),

                Text("Welcome Back", style: theme.textTheme.titleLarge),

                const SizedBox(height: 6),

                Text(
                  "Log in to access your curated wardrobe.",
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 28),

                const Text("Email Address"),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "jane@fashion.com",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 18),

                const Text("Password"),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot'),
                    child: const Text("Forgot Password?"),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
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
                        : const Text("Log In →"),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Sign Up"),
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
