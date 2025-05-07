import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../Utils/globle_variable/globle.dart';
import '../Forgot_password/new_password.dart';

class OtpVerificationScreen extends StatefulWidget {
  final AuthService authService;

  const OtpVerificationScreen({Key? key,required  this.authService}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final OtpFieldController _otpController = OtpFieldController();

  @override
  void dispose() {
    // widget.authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Icon(Icons.arrow_back,color: appcolor,),
        backgroundColor: themeController.white,
        title:  Text('Verify OTP',style: GoogleFonts.poppins(color: appcolor),),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.authService.isLoading,
        builder: (context, isLoading, _) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: widget.authService.email,
                      builder: (context, email, _) {
                        return Text(
                          'Enter the 4-digit code sent to ${email ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    OTPTextField(
                      controller: _otpController,
                      length: 4,

                      width: MediaQuery.of(context).size.width,
                      fieldWidth: 60,
                      style: const TextStyle(fontSize: 20),
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldStyle: FieldStyle.box,
                      onCompleted: (pin) async {
                        print("coming");
                        // final success = await widget.authService!.verifyOtp(pin);
                        // if (success) {

                          if(first_time){
                            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                          }
                          else{
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewPasswordScreen(authService:AuthService()),
                              ),
                            );
                          }

                        // }
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(

    onPressed: isLoading
    ? null
        : () async {
    final otp = _otpController.toString();
    if (otp.length == 4) {
    await widget.authService.verifyOtp(otp);
    }},

                      style: ElevatedButton.styleFrom(
                        backgroundColor: appcolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
    ),
                      child: Text(
                        'Verify Otp',
                        style: GoogleFonts.poppins(
                          color: themeController.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        widget.authService.sendOtp(widget.authService.email.value ?? '');
                      },
                      child: const Text('Resend OTP'),
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: widget.authService.error,
                      builder: (context, error, _) {
                        if (error != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}
