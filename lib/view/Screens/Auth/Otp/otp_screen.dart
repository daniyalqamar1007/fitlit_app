
import 'dart:io';
import 'dart:async';

import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../../../main.dart';
import '../../../Utils/responsivness.dart';
import '../../../Widgets/Custom_buttons.dart';
import '../sign_in.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String gender;
  final String name;
  final String password;
  final String phone;
  final File file;

  const OtpVerificationScreen({
    Key? key,
    required this.email, required this.gender, required this.name, required this.password, required this.phone,required this.file,

  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _enteredOtp = '';
  bool _isLoading = false;
  String? _errorMessage;
  late AuthController _authController;
  final OtpFieldController _otpController = OtpFieldController();

  // Progress tracking variables
  double _progressValue = 0.0;
  Timer? _progressTimer;
  bool _completedProgress = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    // Retrieve existing signup data (to ensure we have the complete user details)
    _validateExistingData();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _validateExistingData() {
    // Check if there's stored signup data with the email
    final tempData = _authController.tempSignUpData;

    // Debug: Print stored data
    print('Stored signup data: $tempData');

    if (tempData.isEmpty || tempData['email'] != widget.email) {
      // If no data or email mismatch, update with the current email
      _authController.updateSignUpData();
      print('Email updated in temp data: ${widget.email}');
    }
  }

  void _startProgressAnimation() {
    // Reset progress
    setState(() {
      _progressValue = 0.0;
      _completedProgress = false;
    });

    // Cancel existing timer if any
    _progressTimer?.cancel();

    // Duration of 35 seconds (average of 30-40 seconds)
    // We'll reach 95% in this time, reserving the last 5% for when we actually get a response
    const totalDuration = 35000; // 35 seconds in milliseconds
    const interval = 350; // Update every 350ms
    const steps = totalDuration ~/ interval;
    const incrementPerStep = 0.95 / steps; // Reach 95% in the given duration

    _progressTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (_progressValue >= 0.95) {
        timer.cancel();
      } else {
        setState(() {
          _progressValue += incrementPerStep;
          if (_progressValue > 0.95) _progressValue = 0.95; // Cap at 95%
        });
      }
    });
  }

  void _completeProgress() {
    _progressTimer?.cancel();

    // Complete the progress to 100% with a smooth animation
    _progressTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_progressValue >= 1.0) {
        timer.cancel();
        setState(() {
          _completedProgress = true;
        });
      } else {
        setState(() {
          _progressValue += 0.05;
          if (_progressValue > 1.0) _progressValue = 1.0;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_enteredOtp.isEmpty || _enteredOtp.length != 4) {
      setState(() {
        _errorMessage = 'Please enter the complete OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Start progress animation
    _startProgressAnimation();

    try {
      // Debug: Print before verification
      print('Attempting OTP verification with: $_enteredOtp');
      print('Current temp data before verification: ${_authController.tempSignUpData}');

      // Call the completeSignUp method to verify OTP and register the user
      final result = await _authController.completeSignUp(_enteredOtp,widget.name,widget.email,widget.password,widget.phone,widget.gender,widget.file);

      // Complete the progress animation to 100%
      _completeProgress();

      // Slight delay to allow progress animation to complete
      await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to sign in screen after successful registration
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
              (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      // Complete the progress animation to show failure
      _completeProgress();

      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
      print('Error in verification: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: themeController.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                _buildHeaderText(),
                SizedBox(height: 40.h),
                OTPTextField(
                  controller: _otpController,
                  length: 4,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 60.w,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onChanged: (pin) {
                    setState(() {
                      _enteredOtp = pin;
                      _errorMessage = null;
                    });
                  },
                  onCompleted: (pin) {
                    setState(() {
                      _enteredOtp = pin;
                      _errorMessage = null;
                    });
                    // Don't automatically verify when completed
                    // Allow user to press the button for verification
                  },
                ),
                SizedBox(height: 16.h),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 30.h),
                CustomButton(
                  text: "Verify OTP",
                  onPressed: _isLoading ? null : _verifyOtp,
                ),
                SizedBox(height: 20.h),
                _buildResendText(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Progress indicator
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      children: [
                        Text(
                          'Wait,we are generating your Avatar!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                          minHeight: 10.h,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${(_progressValue * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'OTP Verification',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30.sp,
            fontWeight: FontWeight.w700,
            color: themeController.black,
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Text(
            'Enter the verification code we just sent to ${widget.email}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code? ",
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : () async {
            try {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });

              // Start progress animation for resend
              _startProgressAnimation();

              // Re-request OTP
              final result = await _authController.initialSignUp(widget.email);

              // Complete the progress animation to 100%
              _completeProgress();

              // Slight delay to allow progress animation to complete
              await Future.delayed(Duration(milliseconds: 500));

              setState(() {
                _isLoading = false;
              });

              if (result['success']) {
                // Debug log for OTP
                print('New OTP received for testing: ${result['otp']}');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('OTP sent again'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                setState(() {
                  _errorMessage = result['message'];
                });
              }
            } catch (e) {
              // Complete the progress animation to show failure
              _completeProgress();

              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to resend OTP: ${e.toString()}';
              });
              print('Error in resend OTP: ${e.toString()}');
            }
          },
          child: Text(
            'Resend',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: _isLoading ? Colors.grey : appcolor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
