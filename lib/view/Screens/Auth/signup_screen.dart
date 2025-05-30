import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import '../../../main.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Widgets/Custom_buttons.dart';
import '../../Widgets/Custom_textfield.dart';
import 'Otp/otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _profileImage;  double dropdownWidth = 0.0;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final AuthController _authController = AuthController();

  Future<void> _initiateSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate gender is selected
    if (_selectedGender == null) {
      setState(() {
        _errorMessage = 'Please select a gender';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First, store all user data in AuthController
      _authController.updateSignUpData(
        name: _nameController.text,
        phone: _phoneController.text,
        gender: _selectedGender,
        password: _passwordController.text,
        imageFile: _profileImage,
      );

      // Then initiate OTP verification process with email
      final result = await _authController.initialSignUp(_emailController.text,context);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        first_time = true;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: _emailController.text,
              name: _nameController.text,
              gender: _selectedGender.toString(),
              phone: _phoneController.text,
              password: _passwordController.text,
              file: _profileImage!,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to send OTP';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
      print('Error in _initiateSignUp: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI Code remains unchanged
    return Scaffold(
      backgroundColor: themeController.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  Image.asset('assets/Images/splash_logo.png', scale: 10.sp),
                  SizedBox(height: 10.h),
                  _buildWelcomeText(),
                  SizedBox(height: 20.h),
                  _buildFormFields(),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ),
                  SizedBox(height: 10.h),
                  CustomButton(
                    text: "Create Account",
                    onPressed: _isLoading ? null : _initiateSignUp,
                  ),
                  _buildSignInText(),
                  SizedBox(height: 20.h),
                ],
              ),
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

  Widget _buildWelcomeText() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(
              fontSize: 30.sp,
              fontWeight: FontWeight.w700,
              color: themeController.black,
            ),
            children: [
              const TextSpan(text: 'Let\'s'),
              TextSpan(
                text: ' Start',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 30.sp,
                  color: appcolor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 03.w),
          child: Text(
            'Fitlit lets you create and customize your own avatar outfits for a unique style experience',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(
          hintText: 'Name',
          fillColor: Colors.grey.shade100,
          filled: true,
          hintStyle: GoogleFonts.poppins(color: hintextcolor, fontSize: 12.sp),
          controller: _nameController,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          hintText: 'Email',
          fillColor: Colors.grey.shade100,
          filled: true,
          controller: _emailController,
          hintStyle: GoogleFonts.poppins(color: hintextcolor, fontSize: 12.sp),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (!value!.contains('@')) return 'Invalid email';
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          border: InputBorder.none,
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          hintText: 'Phone',
          fillColor: Colors.grey.shade100,
          filled: true,
          controller: _phoneController,
          hintStyle: GoogleFonts.poppins(color: hintextcolor, fontSize: 12.sp),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 8.h),
        LayoutBuilder(
        builder: (context, constraints) {
          dropdownWidth = constraints.maxWidth;
          return DropdownButtonFormField<String>(
            value: _selectedGender,
            isExpanded: true,

            // Set to true to expand to full width
            dropdownColor: Colors.grey.shade100,
            // Match your fillColor
            onChanged: (value) => setState(() => _selectedGender = value),
            decoration: InputDecoration(
              hintText: 'Select Gender',
              hintStyle: GoogleFonts.poppins(
                color: hintextcolor.withOpacity(0.2),
                fontSize: 12.sp,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12), // Adjust padding
            ),
            style: GoogleFonts.poppins(
              color: themeController.black,
              fontSize: 12.sp,
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  // Make menu items full width
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  // Add horizontal margin
                  child: Text(
                    gender,
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                ),
              );
            }).toList(),
            validator: (value) =>
            value == null
                ? 'Please select a gender'
                : null,
          );
        }),
        SizedBox(height: 8.h),
        CustomTextField(
          hintText: 'Password',
          hintStyle: GoogleFonts.poppins(color: hintextcolor, fontSize: 12.sp),
          controller: _passwordController,
          obscureText: _obscurePassword,
          fillColor: Colors.grey.shade100,
          filled: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (value!.length < 6) return 'Minimum 6 characters';
            return null;
          },
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: appcolor,
              size: 20.sp,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              
              decoration: InputDecoration(
                hintText:
                    _profileImage != null ? 'Image Selected' : 'Upload Photo',
                hintStyle:
                    GoogleFonts.poppins(color: hintextcolor, fontSize: 12.sp),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14)
                ),
                suffixIcon: _profileImage != null
                    ? Container(
                        margin: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4.sp),
                        child:
                            Icon(Icons.check, color: Colors.white, size: 16.sp),
                      )
                    : Image.asset(
                        'assets/Icons/camera_icon.png',
                        scale: 5.sp,
                      ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSignInText() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Text.rich(
        TextSpan(
          text: 'Do you have an account? ',
          style: GoogleFonts.poppins(fontSize: 12.sp),
          children: [
            TextSpan(
              text: 'Sign In',
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.signin),
              style: GoogleFonts.poppins(
                color: appcolor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: appcolor),
                title: Text('Pick from Gallery', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: appcolor),
                title: Text('Take Photo', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
