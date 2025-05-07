import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../Utils/globle_variable/globle.dart';
import '../../../Widgets/Custom_textfield.dart';
import '../Otp/otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: appcolor,
            )),
        backgroundColor: themeController.white,
        title: Text(
          'Forgot Password',
          style: GoogleFonts.poppins(
            color: appcolor,
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _authService.isLoading,
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
                      const Text(
                        'Enter your email to receive a verification code',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        controller: _emailController,
                        hintText: 'Enter your email',
                        hintStyle:
                            GoogleFonts.poppins(color: themeController.black),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  final success = await _authService
                                      .sendOtp(_emailController.text);
                                  if (success) {
                                    first_time = false;
                                    print(first_time);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OtpVerificationScreen(
                                                authService: _authService),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appcolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Send Otp',
                          style: GoogleFonts.poppins(
                            color: themeController.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<String?>(
                        valueListenable: _authService.error,
                        builder: (context, error, _) {
                          if (error != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                error,
                                style: GoogleFonts.poppins(color: Colors.red),
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
