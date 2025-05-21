import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as https;
import 'package:fitlip_app/view/Utils/globle_variable/globle.dart';

import '../model/profile_model.dart';

class ProfileService {
  // Get the user profile information
  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await https.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print("comihg");
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        return UserProfileModel.fromJson(data);

      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load profile';
        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: ${e.message}');
    } on https.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Update the user profile information
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile, File? imageFile) async {
    try {


      // If there's no image to upload, use a simple PUT request
      if (imageFile == null) {

        final response = await https.patch(
          Uri.parse('$baseUrl/user/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            ...profile.toJson(),
            'onProfileChange': isNewImageSelected==true?"yes":"no", // 👈 Add custom string attribute
          }),
        );
        print(response.body);
        print(response.statusCode);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          return UserProfileModel.fromJson(data);
        } else {

          throw Exception('Failed to update profile: ${response.statusCode}');
        }
      }
      // If there's an image to upload, use multipart request
      else {
        print(imageFile.path);
        print("in else part");
        print("coming");
        print(isNewImageSelected);
        var request = https.MultipartRequest(
          'Patch',
          Uri.parse('$baseUrl/user/profile'),
        );

        // Add authorization header
        request.headers.addAll({
          'Authorization': 'Bearer $token',
        });
        request.fields['name'] = profile.name;
        request.fields['email'] = profile.email;
        request.fields['gender'] = profile.gender;
        request.fields['onProfileChange'] = isNewImageSelected.value==true?"yes":"no";

        // Add file
        request.files.add(await https.MultipartFile.fromPath(
          'profilePicture',
          imageFile.path,
        ));
        print(request.fields);

        final streamedResponse = await request.send();
        print(streamedResponse.statusCode);
        print(streamedResponse);
        final response = await https.Response.fromStream(streamedResponse);
        print(response.body);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          return UserProfileModel.fromJson(data);
        } else {
          throw Exception('Failed to update profile: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}