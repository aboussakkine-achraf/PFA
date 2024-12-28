import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(milliseconds: 20000), // 5 seconds
    receiveTimeout: Duration(milliseconds: 20000), // 3 seconds
  ));

  // URL of your Spring Boot API
  // final String apiUrl = "http://192.168.1.4:8080/api/ocr/upload";

  final String apiUrl = "http://172.20.10.6:8080/api/ocr/upload";

  // URL MDRASSA

  // Method to send an image to the API and get the extracted data
  Future<Map<String, dynamic>?> uploadImage(File file) async {
    try {
      // Check camera and storage permissions
      if (await Permission.camera.request().isGranted &&
          await Permission.storage.request().isGranted) {
        // Create FormData with the image to send
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path,
              filename: file.uri.pathSegments.last),
        });

        // Make the POST request to the API with the image file
        Response response = await _dio.post(apiUrl, data: formData);

        // If the request is successful (status 200), return the extracted data
        if (response.statusCode == 200) {
          return response.data; // Extracted data (e.g., name, ID, etc.)
        } else {
          throw Exception("Error sending image: ${response.statusMessage}");
        }
      } else {
        throw Exception('Permission denied for camera or storage access.');
      }
    } catch (e) {
      // Print error to console and return null
      debugPrint("Error: $e");
      return null;
    }
  }
}
