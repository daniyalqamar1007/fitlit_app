import 'dart:async';
import 'dart:io';

import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Screens/Dashboard/bottomnavbar.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:fitlip_app/view/Utils/globle_variable/globle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
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
    required this.email,
    required this.gender,
    required this.name,
    required this.password,
    required this.phone,
    required this.file,
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

  // Loading state management
  String _loadingMessage = 'Sending email...';
  double _progressValue = 0.0;
  Timer? _progressTimer;
  Timer? _messageTimer;
  bool _showAvatarMessage = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _validateExistingData();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _validateExistingData() {
    final tempData = _authController.tempSignUpData;
    if (tempData.isEmpty || tempData['email'] != widget.email) {
      _authController.updateSignUpData();
    }
  }

  void _startProgressAnimation() {
    setState(() {
      _progressValue = 0.0;
      _showAvatarMessage = false;
    });

    _progressTimer?.cancel();
    _messageTimer?.cancel();

    const totalDuration = 35000;
    const interval = 350;
    const steps = totalDuration ~/ interval;
    const incrementPerStep = 0.95 / steps;

    _progressTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (_progressValue >= 0.95) {
        timer.cancel();
      } else {
        setState(() {
          _progressValue += incrementPerStep;
          if (_progressValue > 0.95) _progressValue = 0.95;
        });
      }
    });
  }

  void _completeProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_progressValue >= 1.0) {
        timer.cancel();
      } else {
        setState(() {
          _progressValue += 0.05;
          if (_progressValue > 1.0) _progressValue = 1.0;
        });
      }
    });
  }

  void _updateLoadingMessage(String message) {
    setState(() {
      _loadingMessage = message;
    });
  }

  Future<void> _verifyOtp(BuildContext context) async {
    if (_enteredOtp.isEmpty || _enteredOtp.length != 4) {
      setState(() {
        _errorMessage = 'Please enter the complete OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingMessage = 'Validating OTP...';
      _showAvatarMessage = false;
    });

    _startProgressAnimation();

    // After 5 seconds, show avatar generation message
    _messageTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _loadingMessage = 'Wait, we are generating your Avatar!';
        _showAvatarMessage = true;
      });
    });

    try {
      final result = await _authController.completeSignUp(
          _enteredOtp,
          widget.name,
          widget.email,
          widget.password,
          widget.phone,
          widget.gender,
          context,
          widget.file);
      print(result);

      _completeProgress();
      await Future.delayed(Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful'),
            backgroundColor: Colors.green,
          ),
        );
        print(result['access_token']);
        await savetoken(result['access_token']);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      _completeProgress();
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    } finally {
      _messageTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
       iconTheme: IconThemeData(color: appcolor),
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
                  otpFieldStyle: OtpFieldStyle(
                    borderColor: appcolor,       // Normal border
                    focusBorderColor: appcolor, // Green border when focused
                  ),
                  onCompleted: (pin) {
                    setState(() {
                      _enteredOtp = pin;
                      _errorMessage = null;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                          color: Colors.red, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 30.h),
                CustomButton(
                  text: "Verify OTP",
                  onPressed: _isLoading ? null : () => _verifyOtp(context),
                ),
                SizedBox(height: 20.h),
                _buildResendText(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  margin: EdgeInsets.only(left: 20,right: 20,bottom: 10),
                  padding: EdgeInsets.all(30.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                        strokeWidth: 4.w,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        _loadingMessage,
                        style: GoogleFonts.poppins(
                          color: themeController.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_showAvatarMessage) ...[
                        SizedBox(height: 20.h),
                        LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                          minHeight: 10.h,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '${(_progressValue * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            color: themeController.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
          onPressed: _isLoading
              ? null
              : () async {
            try {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
                _loadingMessage = 'Sending email...';
                _showAvatarMessage = false;
              });

              final result = await _authController.initialSignUp(widget.email, context);

              setState(() {
                _isLoading = false;
              });

              if (result['success']) {
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
              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to resend OTP: ${e.toString()}';
              });
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