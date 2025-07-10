import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart'; // Add this import
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
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
  
  // Replace String? _selectedGender with ValueNotifier
  final ValueNotifier<String?> _selectedGenderNotifier = ValueNotifier<String?>(null);
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _profileImage;
  double dropdownWidth = 0.0;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final AuthController _authController = AuthController();

  Future<void> _initiateSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // // Validate gender is selected using ValueNotifier
    // if (_selectedGenderNotifier.value == null) {
    //   setState(() {
    //     _errorMessage = 'Please select a gender';
    //   });
    //   return;
    // }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First, store all user data in AuthController
      _authController.updateSignUpData(
        name: _nameController.text,
        phone: _phoneController.text,
        // gender: _selectedGenderNotifier.value, // Use ValueNotifier value
        gender: "Other",
        password: _passwordController.text,
        imageFile: _profileImage,
      );

      // Then initiate OTP verification process with email
      final result = await _authController.initialSignUp(_emailController.text, context);

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
              gender: _selectedGenderNotifier.value.toString(), // Use ValueNotifier value
              phone: "00000000000",
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
    _selectedGenderNotifier.dispose(); // Dispose ValueNotifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: appcolor,
                  size: 20,
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
        // CustomTextField(
        //   hintText: 'Phone',
        //   fillColor: Colors.grey.shade100,
        //   filled: true,
        //   controller: _phoneController,
        //   hintStyle: GoogleFonts.poppins(color: hintextcolor, fontSize: 12.sp),
        //   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        //   keyboardType: TextInputType.phone,
        // ),
        // SizedBox(height: 8.h),
        // Use your custom gender selector
        // _buildCustomGenderSelector(),
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
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: _profileImage != null ? 'Image Selected' : 'Upload Photo',
                hintStyle: GoogleFonts.poppins(color: hintextcolor, fontSize: 12.sp),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: _profileImage != null
                    ? Container(
                        margin: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4.sp),
                        child: Icon(Icons.check, color: Colors.white, size: 16.sp),
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

  // Your custom gender selector widget
  Widget _buildCustomGenderSelector() {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   localizations.gender,
        //   style: GoogleFonts.poppins(
        //     color: Colors.grey.shade800,
        //     fontWeight: FontWeight.w600,
        //     fontSize: 14,
        //   ),
        // ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: ValueListenableBuilder<String?>(
            valueListenable: _selectedGenderNotifier,
            builder: (context, selectedGender, _) {
              return DropdownButtonFormField2<String>(
                value: selectedGender,
                hint: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: const Color(0xFFAA8A00),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localizations.selectGender,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                isExpanded: true,
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  elevation: 8,
                  offset: const Offset(0, 8), // Position dropdown lower
                  maxHeight: 200,
                  width: null, // This makes it match the button width
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: const Color(0xFFAA8A00),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Row(
                      children: [
                        Icon(Icons.male, color: const Color(0xFFAA8A00), size: 18),
                        const SizedBox(width: 12),
                        Text(localizations.male, style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Row(
                      children: [
                        Icon(Icons.female, color: const Color(0xFFAA8A00), size: 18),
                        const SizedBox(width: 12),
                        Text(localizations.female, style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Row(
                      children: [
                        Icon(Icons.transgender, color: const Color(0xFFAA8A00), size: 18),
                        const SizedBox(width: 12),
                        Text("Other", style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  _selectedGenderNotifier.value = value;
                },
                // Add validation for the dropdown
                validator: (value) => value == null ? 'Please select a gender' : null,
              );
            },
          ),
        ),
        // const SizedBox(height: 50), 
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
                ..onTap = () => Navigator.pushReplacementNamed(context, AppRoutes.signin),
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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
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
