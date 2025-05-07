import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:fitlip_app/view/Widgets/Custom_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../Widgets/Custom_textfield.dart';

class NewPasswordScreen extends StatefulWidget {
  final AuthService authService;

  const NewPasswordScreen({Key? key, required this.authService})
      : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        backgroundColor: themeController.white,
        title:Text('Set Your Password',style:GoogleFonts.poppins(color: appcolor,fontSize: 24,fontWeight: FontWeight.w600) ,),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.authService.isLoading,
        builder: (context, isLoading, _) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       Text(
                        'Create a new password',
                        style: GoogleFonts.poppins(fontSize: 16,fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _newPasswordController,
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintStyle: GoogleFonts.poppins(color: Colors.black54,fontWeight: FontWeight.w400,fontSize: 12),
                        hintText: 'Enter new password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter new password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Confirm password',
                        hintStyle: GoogleFonts.poppins(color: Colors.black54,fontWeight: FontWeight.w400,fontSize: 12),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                     CustomButton(text: "Reset Password", onPressed: isLoading
                         ? null
                         : () async {
                       if (_formKey.currentState?.validate() ??
                           false) {
                         final success =
                         await widget.authService.resetPassword(
                           _newPasswordController.text,
                           _confirmPasswordController.text,
                         );
                         if (success) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(
                                 content: Text(
                                     'Password reset successfully')),
                           );
                           Navigator.popUntil(
                               context, (route) => route.isFirst);
                         }
                       }
                     }),
                      ValueListenableBuilder<String?>(
                        valueListenable: widget.authService.error,
                        builder: (context, error, _) {
                          if (error != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                error,
                                style:  GoogleFonts.poppins(color: Colors.red),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}
