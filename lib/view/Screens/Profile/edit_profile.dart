import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:fitlip_app/controllers/profile_controller.dart';
import '../../../main.dart';
import '../../../model/profile_model.dart';
import '../../Utils/Colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController _profileController = ProfileController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Value notifiers for UI state
  final ValueNotifier<String?> _selectedGenderNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<File?> _imageFileNotifier = ValueNotifier<File?>(null);
  final ValueNotifier<String?> _imageLinkNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    // Load profile data as soon as the widget initializes
    _loadUserProfile();
  }
  void _showFullScreenImage() {
    final imageFile = _imageFileNotifier.value;
    final imageLink = _imageLinkNotifier.value;

    if (imageFile == null && (imageLink == null || imageLink.isEmpty)) {
      return; // No image to show
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
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    // Get user profile data
    await _profileController.getUserProfile();
    print(_profileController.profileNotifier.value!.profileImage);

    if (_profileController.profileNotifier.value != null) {
      final profile = _profileController.profileNotifier.value!;
      // Update all value notifiers directly instead of using setState
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _selectedGenderNotifier.value = profile.gender.toLowerCase();

      // Make sure the image link is properly set and updated in the notifier
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
      _imageFileNotifier.value = File(image.path);
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );

      return;
    }

    // Show loading on save button
    _profileController.isLoadingNotifier.value = true;

    try {
      final updatedProfile = UserProfileModel(
        id: _profileController.profileNotifier.value!.id,
        name: _nameController.text,
        email: _emailController.text,
        gender: _selectedGenderNotifier.value ?? '',
        profileImage: _profileController.profileNotifier.value!.profileImage,
      );

      final success = await _profileController.updateUserProfile(
          updatedProfile,
          _imageFileNotifier.value
      );
      print("result i s$success");

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        _profileController.isLoadingNotifier.value = false;
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
      body: ValueListenableBuilder<bool>(
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
                          enabled: false, // Email is typically not editable
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
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showFullScreenImage, // Add this line
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
          style:  GoogleFonts.poppins(fontSize: 14),
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
                :  Text(
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