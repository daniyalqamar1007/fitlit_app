// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../Utils/Colors.dart';
//
//
// class RateAppDialog extends StatefulWidget {
//   const RateAppDialog({Key? key}) : super(key: key);
//
//   @override
//   State<RateAppDialog> createState() => _RateAppDialogState();
// }
//
// class _RateAppDialogState extends State<RateAppDialog>
//     with TickerProviderStateMixin {
//   int selectedRating = 0;
//   bool isSubmitting = false;
//   late AnimationController _starAnimationController;
//   late AnimationController _submitAnimationController;
//   late Animation<double> _starScaleAnimation;
//   late Animation<double> _submitScaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _starAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _submitAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//
//     _starScaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _starAnimationController,
//       curve: Curves.elasticOut,
//     ));
//
//     _submitScaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _submitAnimationController,
//       curve: Curves.easeInOut,
//     ));
//   }
//
//   @override
//   void dispose() {
//     _starAnimationController.dispose();
//     _submitAnimationController.dispose();
//     super.dispose();
//   }
//
//   void _selectRating(int rating) {
//     setState(() {
//       selectedRating = rating;
//     });
//     _starAnimationController.forward().then((_) {
//       _starAnimationController.reverse();
//     });
//   }
//
//   Future<void> _submitRating() async {
//     if (selectedRating == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please select a rating',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       isSubmitting = true;
//     });
//
//     _submitAnimationController.forward();
//
//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));
//
//     _submitAnimationController.reverse();
//
//     setState(() {
//       isSubmitting = false;
//     });
//
//     // Show success message and close dialog
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Thank you for your feedback!',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: appcolor,
//         ),
//       );
//       Navigator.of(context).pop();
//     }
//   }
//
//   Widget _buildStar(int index) {
//     bool isSelected = index <= selectedRating;
//     return GestureDetector(
//       onTap: () => _selectRating(index),
//       child: AnimatedBuilder(
//         animation: _starScaleAnimation,
//         builder: (context, child) {
//           double scale = selectedRating == index ? _starScaleAnimation.value : 1.0;
//           return Transform.scale(
//             scale: scale,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               child: Icon(
//                 isSelected ? Icons.star : Icons.star_border,
//                 size: 40,
//                 color: isSelected ? Colors.amber : Colors.grey.shade400,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // App icon or logo
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: appcolor.withOpacity(0.1),
//               ),
//               child: Icon(
//                 Icons.favorite,
//                 size: 40,
//                 color: appcolor,
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Title
//             Text(
//               'Rate Our App',
//               style: GoogleFonts.playfairDisplay(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: appcolor,
//               ),
//             ),
//             const SizedBox(height: 8),
//
//             // Subtitle
//             Text(
//               'How was your experience with our app?',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Star rating
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(5, (index) => _buildStar(index + 1)),
//             ),
//             const SizedBox(height: 16),
//
//             // Rating text
//             if (selectedRating > 0)
//               AnimatedOpacity(
//                 opacity: selectedRating > 0 ? 1.0 : 0.0,
//                 duration: const Duration(milliseconds: 300),
//                 child: Text(
//                   _getRatingText(selectedRating),
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: _getRatingColor(selectedRating),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 24),
//
//             // Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: TextButton(
//                     onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
//                     style: TextButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         side: BorderSide(color: Colors.grey.shade300),
//                       ),
//                     ),
//                     child: Text(
//                       'Maybe Later',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: AnimatedBuilder(
//                     animation: _submitScaleAnimation,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: _submitScaleAnimation.value,
//                         child: ElevatedButton(
//                           onPressed: isSubmitting ? null : _submitRating,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: appcolor,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: isSubmitting
//                               ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                               : Text(
//                             'Submit',
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getRatingText(int rating) {
//     switch (rating) {
//       case 1:
//         return 'Poor';
//       case 2:
//         return 'Fair';
//       case 3:
//         return 'Good';
//       case 4:
//         return 'Very Good';
//       case 5:
//         return 'Excellent!';
//       default:
//         return '';
//     }
//   }
//
//   Color _getRatingColor(int rating) {
//     switch (rating) {
//       case 1:
//       case 2:
//         return Colors.red.shade600;
//       case 3:
//         return Colors.orange.shade600;
//       case 4:
//       case 5:
//         return Colors.green.shade600;
//       default:
//         return Colors.grey.shade600;
//     }
//   }
// }
//
// // Function to show the rate app dialog
// void showRateAppDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return const RateAppDialog();
//     },
//   );
// }