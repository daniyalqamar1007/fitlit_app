import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../main.dart';
import '../../../../services/auth_services.dart';
import '../../../Utils/globle_variable/globle.dart';
import '../../../Utils/responsivness.dart';
import '../Forgot_password/new_password.dart';

class OtpVerificationScreen extends StatefulWidget {
  String? email;
  OtpVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final OtpFieldController _otpController = OtpFieldController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;
  String? _errorMessage;
  String _enteredOtp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appcolor, size: Responsive.fontSize(20)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: themeController.white,
        title: Text(
          'Verify OTP',
          style: GoogleFonts.poppins(
            color: appcolor,
            fontSize: Responsive.fontSize(18),
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: Responsive.allPadding(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Email Info
                ValueListenableBuilder<String?>(
                  valueListenable: _authController.email,
                  builder: (context, email, _) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: Responsive.height(24)),
                      child: Text(
                        'Enter the 4-digit code sent to ${email ?? 'your email'}',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontSize(16),
                          color: themeController.black,
                        ),
                      ),
                    );
                  },
                ),

                /// OTP Input
                OTPTextField(
                  controller: _otpController,
                  length: 4,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: Responsive.width(60),
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontSize(20),
                    fontWeight: FontWeight.w600,
                  ),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onChanged: (pin) {
                    _enteredOtp = pin;
                  },
                  onCompleted: (pin) {
                    _enteredOtp = pin;
                    _verifyOtp();
                  },
                ),

                /// Error Message
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: Responsive.height(16)),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: Responsive.fontSize(14),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                /// Verify Button
                Padding(
                  padding: EdgeInsets.only(top: Responsive.height(32)),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appcolor,
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.height(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.radius(14)),
                      ),
                    ),
                    child: Text(
                      'Verify OTP',
                      style: GoogleFonts.poppins(
                        color: themeController.white,
                        fontSize: Responsive.fontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                /// Resend Button
                Padding(
                  padding: EdgeInsets.only(top: Responsive.height(16)),
                  child: TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: Text(
                      'Resend OTP',
                      style: GoogleFonts.poppins(
                        color: appcolor,
                        fontSize: Responsive.fontSize(15),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Loader Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (_enteredOtp.length != 4) {
      setState(() {
        _errorMessage = 'Please enter all 4 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authController.verifySignUpOtp(_enteredOtp);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Verification successful')),
        );

        if (first_time) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewPasswordScreen(
                email: widget.email.toString(),
                otp: _otpController.toString(),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> result;

      if (first_time) {
        result = await _authController.signUp();
      } else {
        final email = _authController.email.value ?? '';
        result = await _authController.forgotPassword(email);
      }

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP resent successfully')),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to resend OTP';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }
}
