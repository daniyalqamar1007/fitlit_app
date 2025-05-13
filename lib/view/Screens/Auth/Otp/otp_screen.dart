import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../../../main.dart';
import '../../../../services/auth_services.dart';
import '../../../Utils/globle_variable/globle.dart';
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
          icon: Icon(Icons.arrow_back, color: appcolor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: themeController.white,
        title: Text('Verify OTP', style: GoogleFonts.poppins(color: appcolor)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display email from ValueNotifier
                ValueListenableBuilder<String?>(
                  valueListenable: _authController.email,
                  builder: (context, email, _) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'Enter the 4-digit code sent to ${email ?? 'your email'}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: themeController.black,
                        ),
                      ),
                    );
                  },
                ),

                OTPTextField(
                  controller: _otpController,
                  length: 4,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 60,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
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

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appcolor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Verify OTP',
                      style: GoogleFonts.poppins(
                        color: themeController.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: Text(
                      'Resend OTP',
                      style: GoogleFonts.poppins(
                        color: appcolor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
      print(result.toString());

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Verification successful')),
        );

        // Navigate based on the flow (signup or forgot password)
        if (first_time) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewPasswordScreen(
                      email: widget.email.toString(),
                      otp: _otpController.toString(),
                    )),
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
