import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../controllers/auth_controller.dart';
import '../../../main.dart';
import '../../../routes/App_routes.dart';
import '../../Utils/Colors.dart';
import '../../Utils/responsivness.dart';
import '../../Widgets/Custom_buttons.dart';
import '../../Widgets/Custom_textfield.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _authController.init();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(BuildContext context) async {
    //Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final result = await _authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
        context

      );

      setState(() => _isLoading = false);

      if (result['success']) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      body: SingleChildScrollView(
        padding: Responsive.allPadding(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Responsive.height(30)),
              Image.asset('assets/Images/splash_logo.png', scale: 10),
              SizedBox(height: Responsive.height(20)),
              _buildWelcomeText(),
              SizedBox(height: Responsive.height(20)),
              _buildFormFields(),
              SizedBox(height: Responsive.height(10)),
              _isLoading
                  ?  LoadingAnimationWidget.fourRotatingDots(        color:appcolor,size:20)
                  : CustomButton(
                      text: "Login",
                      onPressed:() async{
                        _handleSignIn(context);
                        },
                    ),
              _buildCreateAccountText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(
              fontSize: Responsive.fontSize(30),
              fontWeight: FontWeight.w700,
              color: themeController.black,
            ),
            children: [
              const TextSpan(text: 'Welcome '),
              TextSpan(
                text: 'Back',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.fontSize(30),
                  color: appcolor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.height(8)),
        Padding(
          padding: Responsive.horizontalPadding(30),
          child: Text(
            'Login to continue to your account',
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: Responsive.fontSize(12),
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
          hintText: 'Email',
          fillColor: Colors.grey.shade100,
          filled: true,
          controller: _emailController,
          hintStyle: GoogleFonts.poppins(
            color: hintextcolor,
            fontSize: Responsive.fontSize(13),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (!value!.contains('@')) return 'Invalid email';
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(14)),
            borderSide: BorderSide.none,
          ),
        ),
        SizedBox(height: Responsive.height(12)),
        CustomTextField(
          hintText: 'Password',
          hintStyle: GoogleFonts.poppins(
            color: hintextcolor,
            fontSize: Responsive.fontSize(13),
          ),
          controller: _passwordController,
          obscureText: _obscurePassword,
          fillColor: Colors.grey.shade100,
          filled: true,
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
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (value!.length < 6) return 'Minimum 6 characters';
            return null;
          },
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(14)),
            borderSide: BorderSide.none,
          ),
        ),
        SizedBox(height: Responsive.height(5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.forgot);
              },
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: Responsive.fontSize(13),
                  color: appcolor,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildCreateAccountText() {
    return Padding(
      padding: EdgeInsets.only(top: Responsive.height(12)),
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(12),
          ),
          children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signup);
                },
              text: 'Create one',
              style: GoogleFonts.poppins(
                color: appcolor,
                fontSize: Responsive.fontSize(12),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
