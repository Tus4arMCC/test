// import 'package:flutter/material.dart';
// import 'auth_service.dart';
// import '../../common/popup/app_popup.dart';

// class ForgetPasswordScreen extends StatefulWidget {
//   const ForgetPasswordScreen({super.key});

//   @override
//   State<ForgetPasswordScreen> createState() =>
//       _ForgetPasswordScreenState();
// }

// class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
//   final _usernameCtrl = TextEditingController();
//   final _passwordCtrl = TextEditingController();
//   bool _loading = false;

//   Future<void> _updatePassword() async {
//     setState(() => _loading = true);

//     final res = await AuthService.forgetPassword(
//       username: _usernameCtrl.text.trim(),
//       newPassword: _passwordCtrl.text.trim(),
//     );

//     if (!mounted) return;

//     if (res['messageCode'] == 100) {
//       AppPopup.show(
//         context,
//         title: "Success",
//         message: "Password updated",
//         type: PopupType.success,
//       );

//       Navigator.pop(context);
//     } else {
//       AppPopup.show(
//         context,
//         title: "Failed",
//         message: res['message'],
//         type: PopupType.error,
//       );
//     }

//     setState(() => _loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AuthBaseUI(
//       title: "Forgot Password",
//       subtitle: "Reset your password",
//       buttonText: "Update Password",
//       loading: _loading,
//       onSubmit: _updatePassword,
//       usernameCtrl: _usernameCtrl,
//       passwordCtrl: _passwordCtrl,
//     );
//   }
// }
