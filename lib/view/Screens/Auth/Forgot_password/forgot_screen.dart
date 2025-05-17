import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../Utils/globle_variable/globle.dart';
import '../../../Utils/responsivness.dart';
import '../../../Widgets/Custom_textfield.dart';
import '../../../Widgets/Custom_buttons.dart';
import '../Otp/otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _authController = AuthController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authController.init();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await _authController.forgotPassword(
          _emailController.text.trim(),
        );
        print('UI received result: $result');

        setState(() => _isLoading = false);

        if (result['success'] == true && result['otp'] != null) {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => OtpVerificationScreen(
          //       email: _emailController.text,
          //     ),
          //   ),
          // );
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to send OTP';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: appcolor,
            size: Responsive.fontSize(20),
          ),
        ),
        backgroundColor: themeController.white,
        title: Text(
          'Forgot Password',
          style: GoogleFonts.playfairDisplay(
            color: appcolor,
            fontSize: Responsive.fontSize(24),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: Responsive.allPadding(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your email to receive a verification code',
                    style: TextStyle(fontSize: Responsive.fontSize(16)),
                  ),
                  SizedBox(height: Responsive.height(24)),
                  CustomTextField(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    controller: _emailController,
                    hintText: 'Enter your email',
                    hintStyle: GoogleFonts.poppins(
                      color: themeController.black,
                      fontSize: Responsive.fontSize(14),
                    ),
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
                  SizedBox(height: Responsive.height(32)),
                  CustomButton(
                    text: 'Send OTP',
                    onPressed: _isLoading ? null : _handleSendOtp,
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: Responsive.height(16)),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: Responsive.fontSize(14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
