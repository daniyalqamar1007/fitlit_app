// // import 'dart:io';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:fitlip_app/routes/App_routes.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:fitlip_app/view/Utils/Constants.dart';
// // import 'package:fitlip_app/controllers/profile_controller.dart';
// // import '../../../main.dart';
// // import '../../../model/profile_model.dart';
// // import '../../Utils/Colors.dart';
// //
// // class EditProfileScreen extends StatefulWidget {
// //   const EditProfileScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<EditProfileScreen> createState() => _EditProfileScreenState();
// // }
// //
// // class _EditProfileScreenState extends State<EditProfileScreen> {
// //   final ProfileController _profileController = ProfileController();
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _emailController = TextEditingController();
// //   final ValueNotifier<bool?> _isimagesend = ValueNotifier<bool?>(false);
// //
// //   // Value notifiers for UI state
// //   final ValueNotifier<String?> _selectedGenderNotifier = ValueNotifier<String?>(null);
// //   final ValueNotifier<File?> _imageFileNotifier = ValueNotifier<File?>(null);
// //   final ValueNotifier<String?> _imageLinkNotifier = ValueNotifier<String?>(null);
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load profile data as soon as the widget initializes
// //     _loadUserProfile();
// //   }
// //   void _showFullScreenImage() {
// //     final imageFile = _imageFileNotifier.value;
// //     final imageLink = _imageLinkNotifier.value;
// //
// //     if (imageFile == null && (imageLink == null || imageLink.isEmpty)) {
// //       return; // No image to show
// //     }
// //
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => Scaffold(
// //           backgroundColor: Colors.black,
// //           appBar: AppBar(
// //             backgroundColor: Colors.transparent,
// //             elevation: 0,
// //             iconTheme: const IconThemeData(color: Colors.white),
// //           ),
// //           body: Center(
// //             child: InteractiveViewer(
// //               panEnabled: true,
// //               minScale: 0.5,
// //               maxScale: 3.0,
// //               child: imageFile != null
// //                   ? Image.file(
// //                 imageFile,
// //                 fit: BoxFit.contain,
// //               )
// //                   : CachedNetworkImage(
// //                 imageUrl: imageLink!,
// //                 fit: BoxFit.contain,
// //                 placeholder: (context, url) =>
// //                 const CircularProgressIndicator(color: Colors.white),
// //                 errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _emailController.dispose();
// //     _selectedGenderNotifier.dispose();
// //     _imageFileNotifier.dispose();
// //     _imageLinkNotifier.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _loadUserProfile() async {
// //     // Get user profile data
// //     await _profileController.getUserProfile();
// //     print(_profileController.profileNotifier.value!.profileImage);
// //
// //     if (_profileController.profileNotifier.value != null) {
// //       final profile = _profileController.profileNotifier.value!;
// //       // Update all value notifiers directly instead of using setState
// //       _nameController.text = profile.name;
// //       _emailController.text = profile.email;
// //       _selectedGenderNotifier.value = profile.gender.toLowerCase();
// //
// //       // Make sure the image link is properly set and updated in the notifier
// //       if (profile.profileImage != null && profile.profileImage.isNotEmpty) {
// //         _imageLinkNotifier.value = profile.profileImage;
// //         debugPrint("Profile image loaded: ${_imageLinkNotifier.value}");
// //       }
// //     }
// //   }
// //
// //   Future<void> _pickImage() async {
// //     final ImagePicker picker = ImagePicker();
// //     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// //
// //     if (image != null) {
// //       _imageFileNotifier.value = File(image.path);
// //     }
// //   }
// //
// //   Future<void> _updateProfile() async {
// //     if (_nameController.text.trim().isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Name cannot be empty')),
// //       );
// //
// //       return;
// //     }
// //
// //     // Show loading on save button
// //     _profileController.isLoadingNotifier.value = true;
// //
// //     try {
// //       final updatedProfile = UserProfileModel(
// //         id: _profileController.profileNotifier.value!.id,
// //         name: _nameController.text,
// //         email: _emailController.text,
// //         gender: _selectedGenderNotifier.value ?? '',
// //         profileImage: _profileController.profileNotifier.value!.profileImage,
// //       );
// //
// //       final success = await _profileController.updateUserProfile(
// //           updatedProfile,
// //           _imageFileNotifier.value
// //       );
// //       print("result i s$success");
// //
// //       if (success && mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Profile updated successfully')),
// //         );
// //         Navigator.pop(context, true);
// //       }
// //     } finally {
// //       if (mounted) {
// //         _profileController.isLoadingNotifier.value = false;
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: themeController.white,
// //       appBar: AppBar(
// //         backgroundColor: themeController.white,
// //         elevation: 0,
// //         leading: GestureDetector(
// //           onTap: () {
// //             Navigator.pop(context);
// //           },
// //           child: const BackButton(color: Color(0xFFAA8A00)),
// //         ),
// //         centerTitle: true,
// //         title: Text(
// //           'Edit Profile',
// //           style: GoogleFonts.playfairDisplay(
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFFAA8A00),
// //             fontSize: 20,
// //           ),
// //         ),
// //       ),
// //       body: ValueListenableBuilder<bool>(
// //           valueListenable: _profileController.isLoadingNotifier,
// //           builder: (context, isLoading, _) {
// //             if (isLoading && _profileController.profileNotifier.value == null) {
// //               return const Center(child: CircularProgressIndicator(color: Color(0xFFAA8A00)));
// //             }
// //
// //             return ValueListenableBuilder<UserProfileModel?>(
// //                 valueListenable: _profileController.profileNotifier,
// //                 builder: (context, userProfile, _) {
// //                   if (userProfile == null) {
// //                     return const Center(child: Text('Failed to load profile data'));
// //                   }
// //
// //                   return SingleChildScrollView(
// //                     padding: const EdgeInsets.all(20),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: [
// //                         _buildProfileImagePicker(),
// //                         const SizedBox(height: 24),
// //                         _buildTextField(
// //                           label: 'Name',
// //                           controller: _nameController,
// //                           icon: Icons.person_outline,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildTextField(
// //                           label: 'Email',
// //                           controller: _emailController,
// //                           icon: Icons.email_outlined,
// //                           enabled: false, // Email is typically not editable
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildGenderSelector(),
// //                         const SizedBox(height: 40),
// //                         _buildSaveButton(),
// //                       ],
// //                     ),
// //                   );
// //                 }
// //             );
// //           }
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProfileImagePicker() {
// //     return Center(
// //       child: Stack(
// //         children: [
// //           GestureDetector(
// //             onTap: _showFullScreenImage, // Add this line
// //             child: ValueListenableBuilder<File?>(
// //               valueListenable: _imageFileNotifier,
// //               builder: (context, imageFile, _) {
// //                 return ValueListenableBuilder<String?>(
// //                   valueListenable: _imageLinkNotifier,
// //                   builder: (context, imageLink, _) {
// //                     return Container(
// //                       height: 100,
// //                       width: 100,
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         border: Border.all(
// //                           color: Colors.grey.withOpacity(0.5),
// //                           width: 0.5,
// //                         ),
// //                       ),
// //                       child: ClipOval(
// //                         child: imageFile != null
// //                             ? Image.file(
// //                           imageFile,
// //                           fit: BoxFit.fitWidth,
// //                           alignment: const Alignment(0, -0.2),
// //                         )
// //                             : (imageLink != null && imageLink.isNotEmpty)
// //                             ? Image.network(
// //                           imageLink,
// //                           fit: BoxFit.cover,
// //                           alignment: const Alignment(0, -1),
// //                           loadingBuilder: (context, child, loadingProgress) {
// //                             if (loadingProgress == null) return child;
// //                             return Center(
// //                               child: CircularProgressIndicator(
// //                                 value: loadingProgress.expectedTotalBytes != null
// //                                     ? loadingProgress.cumulativeBytesLoaded /
// //                                     loadingProgress.expectedTotalBytes!
// //                                     : null,
// //                               ),
// //                             );
// //                           },
// //                           errorBuilder: (context, error, stackTrace) {
// //                             debugPrint("Error loading image: $error");
// //                             return Image.asset(
// //                               'assets/Images/circle_image.png',
// //                               fit: BoxFit.cover,
// //                             );
// //                           },
// //                         )
// //                             : Image.asset(
// //                           'assets/Images/circle_image.png',
// //                           fit: BoxFit.cover,
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //           Positioned(
// //             bottom: 0,
// //             right: 0,
// //             child: GestureDetector(
// //               onTap: _pickImage,
// //               child: Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   color: Colors.white,
// //                   border: Border.all(
// //                       color: Colors.grey.withOpacity(0.5), width: 0.5),
// //                 ),
// //                 child: const Icon(
// //                   Icons.camera_alt_outlined,
// //                   size: 20,
// //                   color: Color(0xFFAA8A00),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //   Widget _buildTextField({
// //     required String label,
// //     required TextEditingController controller,
// //     required IconData icon,
// //     bool enabled = true,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: GoogleFonts.poppins(
// //             color: Colors.grey.shade800,
// //             fontWeight: FontWeight.w600,
// //             fontSize: 14,
// //           ),
// //         ),
// //         const SizedBox(height: 6),
// //         TextFormField(
// //           controller: controller,
// //           enabled: enabled,
// //           style:  GoogleFonts.poppins(fontSize: 14),
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(icon, color: const Color(0xFFAA8A00)),
// //             contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
// //             filled: true,
// //             fillColor: Colors.grey.shade100,
// //             enabledBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(12),
// //               borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
// //             ),
// //             focusedBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(12),
// //               borderSide: const BorderSide(color: Color(0xFFAA8A00)),
// //             ),
// //             disabledBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(12),
// //               borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildGenderSelector() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Gender',
// //           style: GoogleFonts.poppins(
// //             color: Colors.grey.shade800,
// //             fontWeight: FontWeight.w600,
// //             fontSize: 14,
// //           ),
// //         ),
// //         const SizedBox(height: 6),
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 16),
// //           decoration: BoxDecoration(
// //             color: Colors.grey.shade100,
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.grey.withOpacity(0.3)),
// //           ),
// //           child: DropdownButtonHideUnderline(
// //             child: ValueListenableBuilder<String?>(
// //                 valueListenable: _selectedGenderNotifier,
// //                 builder: (context, selectedGender, _) {
// //                   return DropdownButton<String>(
// //                     value: selectedGender,
// //                     hint: const Text('Select Gender'),
// //                     isExpanded: true,
// //                     items: const [
// //                       DropdownMenuItem(value: 'male', child: Text('Male')),
// //                       DropdownMenuItem(value: 'female', child: Text('Female')),
// //                       DropdownMenuItem(value: 'other', child: Text('Other')),
// //                     ],
// //                     onChanged: (value) {
// //                       _selectedGenderNotifier.value = value;
// //                     },
// //                   );
// //                 }
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildSaveButton() {
// //     return ValueListenableBuilder<bool>(
// //       valueListenable: _profileController.isLoadingNotifier,
// //       builder: (context, isLoading, _) {
// //         return SizedBox(
// //           width: double.infinity,
// //           height: 50,
// //           child: ElevatedButton(
// //             onPressed: isLoading ? null : _updateProfile,
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: const Color(0xFFAA8A00),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //             child: isLoading
// //                 ? const SizedBox(
// //               width: 24,
// //               height: 24,
// //               child: CircularProgressIndicator(
// //                 strokeWidth: 3,
// //                 color: Colors.white,
// //               ),
// //             )
// //                 :  Text(
// //               'Save Changes',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:fitlip_app/routes/App_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:fitlip_app/view/Utils/Constants.dart';
// import 'package:fitlip_app/controllers/profile_controller.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../../main.dart';
// import '../../../model/profile_model.dart';
// import '../../Utils/Colors.dart';
// import '../../Utils/globle_variable/globle.dart';
// import 'package:image/image.dart' as img;
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final ProfileController _profileController = ProfileController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//
//   final ValueNotifier<String?> _selectedGenderNotifier = ValueNotifier<String?>(null);
//   final ValueNotifier<File?> _imageFileNotifier = ValueNotifier<File?>(null);
//   final ValueNotifier<String?> _imageLinkNotifier = ValueNotifier<String?>(null);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }
//
//   void _showFullScreenImage() {
//     final imageFile = _imageFileNotifier.value;
//     final imageLink = _imageLinkNotifier.value;
//
//     if (imageFile == null && (imageLink == null || imageLink.isEmpty)) {
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => Scaffold(
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//           body: Center(
//             child: InteractiveViewer(
//               panEnabled: true,
//               minScale: 0.5,
//               maxScale: 3.0,
//               child: imageFile != null
//                   ? Image.file(
//                 imageFile,
//                 fit: BoxFit.contain,
//               )
//                   : CachedNetworkImage(
//                 imageUrl: imageLink!,
//                 fit: BoxFit.contain,
//                 placeholder: (context, url) =>
//                 const CircularProgressIndicator(color: Colors.white),
//                 errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _selectedGenderNotifier.dispose();
//     _imageFileNotifier.dispose();
//     _imageLinkNotifier.dispose();
//     isNewImageSelected.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadUserProfile() async {
//     await _profileController.getUserProfile();
//     print(_profileController.profileNotifier.value!.profileImage);
//
//     if (_profileController.profileNotifier.value != null) {
//       final profile = _profileController.profileNotifier.value!;
//       _nameController.text = profile.name;
//       _emailController.text = profile.email;
//       _selectedGenderNotifier.value = profile.gender.toLowerCase();
//
//       if (profile.profileImage != null && profile.profileImage.isNotEmpty) {
//         _imageLinkNotifier.value = profile.profileImage;
//         debugPrint("Profile image loaded: ${_imageLinkNotifier.value}");
//       }
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//     if (image != null) {
//       // Show loading indicator
//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFFAA8A00)),
//             );
//           },
//         );
//       }
//
//       try {
//         // Convert the image to PNG format
//         final File pngFile = await _convertImageToPng(File(image.path));
//
//         // Update the image file notifier with the PNG file
//         _imageFileNotifier.value = pngFile;
//         isNewImageSelected.value = true;
//         print(isNewImageSelected.value);
//       } catch (e) {
//         debugPrint('Error converting image: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to process image')),
//         );
//       } finally {
//         // Close loading dialog
//         if (mounted && Navigator.canPop(context)) {
//           Navigator.pop(context);
//         }
//       }
//     }
//   }
//   Future<File> _convertImageToPng(File imageFile) async {
//     // Read the image file
//     final bytes = await imageFile.readAsBytes();
//     final originalImage = img.decodeImage(bytes);
//
//     if (originalImage == null) {
//       throw Exception('Could not decode image');
//     }
//
//     // Encode as PNG
//     final pngBytes = img.encodePng(originalImage);
//
//     // Get temporary directory
//     final tempDir = await getTemporaryDirectory();
//     final tempPath = tempDir.path;
//
//     // Create a new file in the temp directory with a unique name
//     final outputFile = File('$tempPath/profile_image_${DateTime.now().millisecondsSinceEpoch}.png');
//
//     // Write the PNG bytes to the file
//     await outputFile.writeAsBytes(pngBytes);
//
//     debugPrint('Image converted to PNG: ${outputFile.path}');
//     return outputFile;
//   }
//   Future<void> _updateProfile() async {
//     if (_nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Name cannot be empty')),
//       );
//       return;
//     }
//
//     _profileController.isLoadingNotifier.value = true;
//
//     try {
//       final updatedProfile = UserProfileModel(
//         id: _profileController.profileNotifier.value!.id,
//         name: _nameController.text,
//         email: _emailController.text,
//         gender: _selectedGenderNotifier.value ?? '',
//         profileImage: _profileController.profileNotifier.value!.profileImage,
//       );
//
//       // Use the PNG file that was created in _pickImage()
//       final File? imageToSend = _imageFileNotifier.value;
//
//       final success = await _profileController.updateUserProfile(
//           updatedProfile,
//           imageToSend
//       );
//
//       debugPrint("Profile update result: $success");
//
//       if (success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//         Navigator.pop(context, true);
//       }
//     } finally {
//       if (mounted) {
//         _profileController.isLoadingNotifier.value = false;
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: themeController.white,
//       appBar: AppBar(
//         backgroundColor: themeController.white,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: const BackButton(color: Color(0xFFAA8A00)),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Edit Profile',
//           style: GoogleFonts.playfairDisplay(
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFFAA8A00),
//             fontSize: 20,
//           ),
//         ),
//       ),
//       body: ValueListenableBuilder<bool>(
//           valueListenable: _profileController.isLoadingNotifier,
//           builder: (context, isLoading, _) {
//             if (isLoading && _profileController.profileNotifier.value == null) {
//               return const Center(child: CircularProgressIndicator(color: Color(0xFFAA8A00)));
//             }
//
//             return ValueListenableBuilder<UserProfileModel?>(
//                 valueListenable: _profileController.profileNotifier,
//                 builder: (context, userProfile, _) {
//                   if (userProfile == null) {
//                     return const Center(child: Text('Failed to load profile data'));
//                   }
//
//                   return SingleChildScrollView(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         _buildProfileImagePicker(),
//                         const SizedBox(height: 24),
//                         _buildTextField(
//                           label: 'Name',
//                           controller: _nameController,
//                           icon: Icons.person_outline,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           label: 'Email',
//                           controller: _emailController,
//                           icon: Icons.email_outlined,
//                           enabled: false,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildGenderSelector(),
//                         const SizedBox(height: 40),
//                         _buildSaveButton(),
//                       ],
//                     ),
//                   );
//                 }
//             );
//           }
//       ),
//     );
//   }
//
//   Widget _buildProfileImagePicker() {
//     return Center(
//       child: Stack(
//         children: [
//           GestureDetector(
//             onTap: _showFullScreenImage,
//             child: ValueListenableBuilder<File?>(
//               valueListenable: _imageFileNotifier,
//               builder: (context, imageFile, _) {
//                 return ValueListenableBuilder<String?>(
//                   valueListenable: _imageLinkNotifier,
//                   builder: (context, imageLink, _) {
//                     return Container(
//                       height: 100,
//                       width: 100,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.grey.withOpacity(0.5),
//                           width: 0.5,
//                         ),
//                       ),
//                       child: ClipOval(
//                         child: imageFile != null
//                             ? Image.file(
//                           imageFile,
//                           fit: BoxFit.fitWidth,
//                           alignment: const Alignment(0, -0.2),
//                         )
//                             : (imageLink != null && imageLink.isNotEmpty)
//                             ? Image.network(
//                           imageLink,
//                           fit: BoxFit.cover,
//                           alignment: const Alignment(0, -1),
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 value: loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded /
//                                     loadingProgress.expectedTotalBytes!
//                                     : null,
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             debugPrint("Error loading image: $error");
//                             return Image.asset(
//                               'assets/Images/circle_image.png',
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         )
//                             : Image.asset(
//                           'assets/Images/circle_image.png',
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: GestureDetector(
//               onTap: _pickImage,
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white,
//                   border: Border.all(
//                       color: Colors.grey.withOpacity(0.5), width: 0.5),
//                 ),
//                 child: const Icon(
//                   Icons.camera_alt_outlined,
//                   size: 20,
//                   color: Color(0xFFAA8A00),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     bool enabled = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             color: Colors.grey.shade800,
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           enabled: enabled,
//           style: GoogleFonts.poppins(fontSize: 14),
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon, color: const Color(0xFFAA8A00)),
//             contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//             filled: true,
//             fillColor: Colors.grey.shade100,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFAA8A00)),
//             ),
//             disabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Widget _buildGenderSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Gender',
//           style: GoogleFonts.poppins(
//             color: Colors.grey.shade800,
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.withOpacity(0.3)),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: ValueListenableBuilder<String?>(
//                 valueListenable: _selectedGenderNotifier,
//                 builder: (context, selectedGender, _) {
//                   return DropdownButton<String>(
//                     value: selectedGender,
//                     hint: const Text('Select Gender'),
//                     isExpanded: true,
//                     items: const [
//                       DropdownMenuItem(value: 'male', child: Text('Male')),
//                       DropdownMenuItem(value: 'female', child: Text('Female')),
//                       DropdownMenuItem(value: 'other', child: Text('Other')),
//                     ],
//                     onChanged: (value) {
//                       _selectedGenderNotifier.value = value;
//                     },
//                   );
//                 }
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Widget _buildSaveButton() {
//     return ValueListenableBuilder<bool>(
//       valueListenable: _profileController.isLoadingNotifier,
//       builder: (context, isLoading, _) {
//         return SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: isLoading ? null : _updateProfile,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFAA8A00),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: isLoading
//                 ? const SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 color: Colors.white,
//               ),
//             )
//                 : Text(
//               'Save Changes',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:fitlip_app/controllers/profile_controller.dart';
import 'package:path_provider/path_provider.dart';
import '../../../main.dart';
import '../../../model/profile_model.dart';
import '../../Utils/Colors.dart';
import '../../Utils/globle_variable/globle.dart';
import 'package:image/image.dart' as img;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController _profileController = ProfileController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ValueNotifier<String?> _selectedGenderNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<File?> _imageFileNotifier = ValueNotifier<File?>(null);
  final ValueNotifier<String?> _imageLinkNotifier = ValueNotifier<String?>(null);

  // Progress tracking variables for loading overlay
  final ValueNotifier<double> _progressValue = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _showLoadingOverlay = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _showFullScreenImage() {
    final imageFile = _imageFileNotifier.value;
    final imageLink = _imageLinkNotifier.value;

    if (imageFile == null && (imageLink == null || imageLink.isEmpty)) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: imageFile != null
                  ? Image.file(
                imageFile,
                fit: BoxFit.contain,
              )
                  : CachedNetworkImage(
                imageUrl: imageLink!,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                const CircularProgressIndicator(color: Colors.white),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _selectedGenderNotifier.dispose();
    _imageFileNotifier.dispose();
    _imageLinkNotifier.dispose();
    isNewImageSelected.dispose();
    _progressValue.dispose();
    _showLoadingOverlay.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    await _profileController.getUserProfile();
    print(_profileController.profileNotifier.value!.profileImage);

    if (_profileController.profileNotifier.value != null) {
      final profile = _profileController.profileNotifier.value!;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _selectedGenderNotifier.value = profile.gender.toLowerCase();

      if (profile.profileImage != null && profile.profileImage.isNotEmpty) {
        _imageLinkNotifier.value = profile.profileImage;
        debugPrint("Profile image loaded: ${_imageLinkNotifier.value}");
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFAA8A00)),
            );
          },
        );
      }

      try {
        // Convert the image to PNG format
        final File pngFile = await _convertImageToPng(File(image.path));

        // Update the image file notifier with the PNG file
        _imageFileNotifier.value = pngFile;
        isNewImageSelected.value = true;
        print(isNewImageSelected.value);
      } catch (e) {
        debugPrint('Error converting image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process image')),
        );
      } finally {
        // Close loading dialog
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<File> _convertImageToPng(File imageFile) async {
    // Read the image file
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Could not decode image');
    }

    // Encode as PNG
    final pngBytes = img.encodePng(originalImage);

    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    // Create a new file in the temp directory with a unique name
    final outputFile = File('$tempPath/profile_image_${DateTime.now().millisecondsSinceEpoch}.png');

    // Write the PNG bytes to the file
    await outputFile.writeAsBytes(pngBytes);

    debugPrint('Image converted to PNG: ${outputFile.path}');
    return outputFile;
  }

  // Animation for progress bar
  void _startProgressAnimation() {
    _progressValue.value = 0.0;
    _showLoadingOverlay.value = true;

    const totalDuration = 2000; // 2 seconds in milliseconds for profile update
    const interval = 50; // Update every 50ms
    const steps = totalDuration ~/ interval;
    const incrementPerStep = 0.95 / steps; // Reach 95% in the given duration

    // Use a ticker or timer to update progress
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: interval));
      if (_progressValue.value >= 0.95) {
        return false;
      } else {
        _progressValue.value += incrementPerStep;
        if (_progressValue.value > 0.95) _progressValue.value = 0.95; // Cap at 95%
        return true;
      }
    });
  }

  void _completeProgress() {
    // Complete the progress to 100% with a smooth animation
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 50));
      if (_progressValue.value >= 1.0) {
        _showLoadingOverlay.value = false;
        return false;
      } else {
        _progressValue.value += 0.05;
        if (_progressValue.value > 1.0) _progressValue.value = 1.0;
        return true;
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    // Start the loading overlay with progress animation
    _startProgressAnimation();

    // Keep original loading state for button
    _profileController.isLoadingNotifier.value = true;

    try {
      final updatedProfile = UserProfileModel(
        id: _profileController.profileNotifier.value!.id,
        name: _nameController.text,
        email: _emailController.text,
        gender: _selectedGenderNotifier.value ?? '',
        profileImage: _profileController.profileNotifier.value!.profileImage,
      );

      // Use the PNG file that was created in _pickImage()
      final File? imageToSend = _imageFileNotifier.value;

      final success = await _profileController.updateUserProfile(
          updatedProfile,
          imageToSend
      );

      debugPrint("Profile update result: $success");

      // Complete the progress animation
      _completeProgress();

      // Slight delay to allow progress animation to complete
      await Future.delayed(Duration(milliseconds: 200));

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        _profileController.isLoadingNotifier.value = false;
        // If we're still here, ensure the loading overlay is dismissed
        if (_showLoadingOverlay.value) {
          _showLoadingOverlay.value = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        backgroundColor: themeController.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const BackButton(color: Color(0xFFAA8A00)),
        ),
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFAA8A00),
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: _profileController.isLoadingNotifier,
              builder: (context, isLoading, _) {
                if (isLoading && _profileController.profileNotifier.value == null) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFAA8A00)));
                }

                return ValueListenableBuilder<UserProfileModel?>(
                    valueListenable: _profileController.profileNotifier,
                    builder: (context, userProfile, _) {
                      if (userProfile == null) {
                        return const Center(child: Text('Failed to load profile data'));
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProfileImagePicker(),
                            const SizedBox(height: 24),
                            _buildTextField(
                              label: 'Name',
                              controller: _nameController,
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Email',
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            _buildGenderSelector(),
                            const SizedBox(height: 40),
                            _buildSaveButton(),
                          ],
                        ),
                      );
                    }
                );
              }
          ),

          // Loading overlay with progress bar
          ValueListenableBuilder<bool>(
            valueListenable: _showLoadingOverlay,
            builder: (context, showOverlay, _) {
              if (!showOverlay) return const SizedBox.shrink();

              return ValueListenableBuilder<double>(
                valueListenable: _progressValue,
                builder: (context, progressValue, _) {
                  return Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              Text(
                                'Updating your profile...',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFAA8A00)),
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(progressValue * 100).toInt()}%',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showFullScreenImage,
            child: ValueListenableBuilder<File?>(
              valueListenable: _imageFileNotifier,
              builder: (context, imageFile, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: _imageLinkNotifier,
                  builder: (context, imageLink, _) {
                    return Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: ClipOval(
                        child: imageFile != null
                            ? Image.file(
                          imageFile,
                          fit: BoxFit.fitWidth,
                          alignment: const Alignment(0, -0.2),
                        )
                            : (imageLink != null && imageLink.isNotEmpty)
                            ? Image.network(
                          imageLink,
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -1),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint("Error loading image: $error");
                            return Image.asset(
                              'assets/Images/circle_image.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : Image.asset(
                          'assets/Images/circle_image.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.5), width: 0.5),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 20,
                  color: Color(0xFFAA8A00),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFAA8A00)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            filled: true,
            fillColor: Colors.grey.shade100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFAA8A00)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: ValueListenableBuilder<String?>(
                valueListenable: _selectedGenderNotifier,
                builder: (context, selectedGender, _) {
                  return DropdownButton<String>(
                    value: selectedGender,
                    hint: const Text('Select Gender'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      _selectedGenderNotifier.value = value;
                    },
                  );
                }
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _profileController.isLoadingNotifier,
      builder: (context, isLoading, _) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAA8A00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
                : Text(
              'Save Changes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}