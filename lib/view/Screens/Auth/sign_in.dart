// import 'package:fitlip_app/routes/App_routes.dart';
// import 'package:fitlip_app/view/Utils/Colors.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../main.dart';
// import '../../Widgets/Custom_buttons.dart';
// import '../../Widgets/Custom_textfield.dart';
//
// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});
//
//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: themeController.white,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 30),
//               Image.asset('assets/Images/splash_logo.png', scale: 10),
//               const SizedBox(height: 20),
//               _buildWelcomeText(),
//               const SizedBox(height: 20),
//               _buildFormFields(),
//
//               CustomButton(text: "Login",
//     onPressed: () async{
//               if (_formKey.currentState?.validate() ?? false) {
//                 Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
//                 // Handle sign in logic
//               }
//             },),
//               _buildCreateAccountText(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWelcomeText() {
//     return Column(
//       children: [
//         RichText(
//           text: TextSpan(
//             style: GoogleFonts.playfairDisplay(
//               fontSize: 30,
//               fontWeight: FontWeight.w700,
//               color: themeController.black,
//             ),
//             children: [
//               const TextSpan(text: 'Welcome '),
//               TextSpan(
//                 text: 'Back',
//                 style: GoogleFonts.playfairDisplay(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 30,
//                   color: appcolor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 30.0),
//           child: Text(
//             'Login to continue to your account',
//             style: GoogleFonts.poppins(
//               color: Colors.grey,
//               fontSize: 12,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFormFields() {
//     return Column(
//       children: [
//         CustomTextField(
//           hintText: 'Email',
//           fillColor: Colors.grey.shade100,
//           filled: true,
//           controller: _emailController,
//           hintStyle: GoogleFonts.poppins(color: hintextcolor),
//           validator: (value) {
//             if (value?.isEmpty ?? true) return 'Required';
//             if (!value!.contains('@')) return 'Invalid email';
//             return null;
//           },
//           keyboardType: TextInputType.emailAddress,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         const SizedBox(height: 16),
//         CustomTextField(
//           hintText: 'Password',
//           hintStyle: GoogleFonts.poppins(color: hintextcolor),
//           controller: _passwordController,
//           obscureText: _obscurePassword,
//           fillColor: Colors.grey.shade100,
//           filled: true,
//           suffixIcon: IconButton(
//             icon: Icon(
//               _obscurePassword ? Icons.visibility_off : Icons.visibility,
//               color: appcolor,
//             ),
//             onPressed: () {
//               setState(() {
//                 _obscurePassword = !_obscurePassword;
//               });
//             },
//           ),
//           validator: (value) {
//             if (value?.isEmpty ?? true) return 'Required';
//             if (value!.length < 6) return 'Minimum 6 characters';
//             return null;
//           },
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         SizedBox(
//           height: 5,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Spacer(),
//             GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(context, AppRoutes.forgot);
//                 },
//                 child: Text(
//                   "Forgot Password?",
//                   style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.w400,
//                       fontSize: 13,
//                       color: appcolor),
//                 ))
//           ],
//         )
//       ],
//     );
//   }
//
//   // Widget _buildSignInButton() {
//   //   return Padding(
//   //     padding: const EdgeInsets.only(top: 24),
//   //     child: SizedBox(
//   //       width: double.infinity,
//   //       height: 60,
//   //       child: ElevatedButton(
//   //         onPressed: () {
//   //           if (_formKey.currentState?.validate() ?? false) {
//   //             Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
//   //             // Handle sign in logic
//   //           }
//   //         },
//   //         style: ElevatedButton.styleFrom(
//   //           backgroundColor: appcolor,
//   //           shape: RoundedRectangleBorder(
//   //             borderRadius: BorderRadius.circular(14),
//   //           ),
//   //         ),
//   //         child: Text(
//   //           'Sign In',
//   //           style: GoogleFonts.poppins(
//   //             color: themeController.white,
//   //             fontSize: 16,
//   //             fontWeight: FontWeight.w700,
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildCreateAccountText() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16),
//       child: Text.rich(
//         TextSpan(
//           text: "Don't have an account? ",
//           style: GoogleFonts.poppins(),
//           children: [
//             TextSpan(
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   Navigator.pushReplacementNamed(context, AppRoutes.signup);
//                 },
//               text: 'Create one',
//               style: GoogleFonts.poppins(
//                 color: appcolor,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:fitlip_app/controllers/auth_controller.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../main.dart';
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

  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final result = await _authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Image.asset('assets/Images/splash_logo.png', scale: 10),
              const SizedBox(height: 20),
              _buildWelcomeText(),
              const SizedBox(height: 20),
              _buildFormFields(),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                text: "Login",
                onPressed: _handleSignIn,
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
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: themeController.black,
            ),
            children: [
              const TextSpan(text: 'Welcome '),
              TextSpan(
                text: 'Back',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: appcolor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            'Login to continue to your account',
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Password',
          hintStyle: GoogleFonts.poppins(color: hintextcolor),
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
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        const SizedBox(height: 5),
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
                      fontSize: 13,
                      color: appcolor),
                ))
          ],
        )
      ],
    );
  }

  Widget _buildCreateAccountText() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: GoogleFonts.poppins(),
          children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signup);
                },
              text: 'Create one',
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