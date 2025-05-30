import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as https;
import 'package:fitlip_app/view/Utils/globle_variable/globle.dart';

import '../model/profile_model.dart';
import '../view/Utils/connection.dart';

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

  Future<UserProfileModel> updateUserProfile(UserProfileModel profile, File? imageFile) async {
    print("coming");
    try {
      Dio dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ));

      // If there's no image to upload, send a JSON body
      if (imageFile == null) {
        final response = await dio.patch(
          '/user/profile',
          data: {
            ...profile.toJson(),
            'onProfileChange': isNewImageSelected == true ? "yes" : "no",
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        print(response.data);
        print(response.statusCode);

        if (response.statusCode == 200) {
          return UserProfileModel.fromJson(response.data);
        } else {
          throw Exception('Failed to update profile: ${response.statusCode}');
        }
      }
      // If image is selected, use multipart form data
      else {
        print(imageFile.path);
        print("in else part");
        print("coming");
        print(isNewImageSelected);

        FormData formData = FormData.fromMap({
          'name': profile.name,
          'email': profile.email,
          'gender': profile.gender,
          'onProfileChange': isNewImageSelected.value == true ? "yes" : "no",
          'profilePicture': await MultipartFile.fromFile(imageFile.path, filename: 'profile.jpg'),
        });

        final response = await dio.patch(
          '/user/profile',
          data: formData,
        );

        print(response.statusCode);
        print(response.data);

        if (response.statusCode == 200) {
          return UserProfileModel.fromJson(response.data);
        } else {
          throw Exception('Failed to update profile: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e}');
    }}
}