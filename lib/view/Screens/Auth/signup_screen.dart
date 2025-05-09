import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../main.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Widgets/Custom_buttons.dart';
import '../../Widgets/Custom_textfield.dart';

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
  File? _profileImage;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Initialize AuthController with the form data
        final authController = AuthController(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          gender: _selectedGender,
          password: _passwordController.text,
          imageFile: _profileImage,
        );

        // Call sign up method
        final result = await authController.signUp();

        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // If successful, set the first_time flag and navigate to OTP screen
          first_time = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'OTP sent to your email')),
          );
          Navigator.pushNamed(context, AppRoutes.otp);
        } else {
          // If not successful, show error
          setState(() {
            _errorMessage = result['message'] ?? 'Sign up failed';
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
    return Scaffold(
      backgroundColor: themeController.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Image.asset('assets/Images/splash_logo.png', scale: 10),
                  SizedBox(height: 20),
                  _buildWelcomeText(),
                  SizedBox(height: 20),
                  _buildFormFields(),

                  // Display error message if any
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  CustomButton(
                    text: "Create Account",
                    onPressed: _isLoading ? null : _handleSignUp,
                  ),
                  _buildSignInText(),
                ],
              ),
            ),
          ),

          // Loading overlay
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
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: themeController.black,
            ),
            children: [
              const TextSpan(text: 'Let \'s'),
              TextSpan(
                text: ' Start',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: appcolor, // Your highlight color
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor',
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 12,
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
          hintStyle: GoogleFonts.poppins(color: hintextcolor),
          controller: _nameController,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Email',
          fillColor: Colors.grey.shade100,
          filled: true,
          controller: _emailController,
          hintStyle: GoogleFonts.poppins(color: hintextcolor),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (!value!.contains('@')) return 'Invalid email';
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          border: InputBorder.none,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Phone',
          fillColor: Colors.grey.shade100,
          filled: true,
          controller: _phoneController,
          hintStyle: GoogleFonts.poppins(color: hintextcolor),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          onChanged: (value) {
            setState(() => _selectedGender = value);
          },
          decoration: InputDecoration(
            hintText: 'Select Gender',
            hintStyle:
            GoogleFonts.poppins(color: hintextcolor.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.poppins(color: themeController.black),
          items: _genderOptions.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          validator: (value) => value == null ? 'Please select a gender' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Password',
          hintStyle: GoogleFonts.poppins(color: hintextcolor),
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
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: appcolor,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText:
                _profileImage != null ? 'Image Selected' : 'Upload Photo',
                hintStyle: GoogleFonts.poppins(color: hintextcolor),
                filled: true,
                suffixIcon: Image.asset(
                  'assets/Icons/camera_icon.png',
                  scale: 5,
                ),
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInText() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text.rich(
        TextSpan(
          text: 'Do you have an account? ',
          style: GoogleFonts.poppins(),
          children: [
            TextSpan(
              text: 'Sign In',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signin);
                },
              style: GoogleFonts.poppins(
                color: appcolor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}