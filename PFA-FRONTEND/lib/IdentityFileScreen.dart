import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img; // Import the image package
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class IdentityFileScreen extends StatefulWidget {
  @override
  _IdentityFileScreenState createState() => _IdentityFileScreenState();
}

class _IdentityFileScreenState extends State<IdentityFileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Map<String, dynamic>? _extractedData; // Holds the extracted data
  final ApiService _apiService = ApiService(); // API service instance

  // Function to pick an image from gallery
  Future<void> _pickImageFromGallery() async {
    await _requestPermissions();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });

    if (_image != null) {
      await _processAndExtractDataFromImage(_image!);
    }
  }

  // Request permissions for storage
  Future<void> _requestPermissions() async {
    var storagePermission = await Permission.storage.request();

    if (!storagePermission.isGranted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Denied'),
          content:
              Text('Please grant storage permissions to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Process the image (convert to PNG if necessary) and extract data
  Future<void> _processAndExtractDataFromImage(XFile image) async {
    try {
      File imageFile = File(image.path);

      // Check if the image format is not PNG
      if (!_isPng(imageFile)) {
        // Convert to PNG
        imageFile = await _convertToPng(imageFile);
      }

      // Extract data from the (possibly converted) image
      final extractedData = await _apiService.uploadImage(imageFile);
      if (extractedData != null) {
        setState(() {
          _extractedData = extractedData; // Store extracted data
        });
      } else {
        throw Exception("Failed to extract data from the image.");
      }
    } catch (e) {
      print("Error: $e");
      // Show error dialog if extraction fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to extract data from image. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Check if the file is in PNG format
  bool _isPng(File file) {
    final bytes = file.readAsBytesSync();
    return bytes.isNotEmpty &&
        bytes.sublist(0, 8).join(' ') == "137 80 78 71 13 10 26 10";
  }

  // Convert image to PNG
  Future<File> _convertToPng(File imageFile) async {
    // Decode the image
    final imageBytes = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw Exception("Unable to decode the image.");
    }

    // Encode as PNG
    final pngBytes = img.encodePng(decodedImage);

    // Save the PNG file
    final pngFilePath =
        '${imageFile.parent.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final pngFile = File(pngFilePath);
    await pngFile.writeAsBytes(pngBytes);

    return pngFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Identity File"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Upload Identity File',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Display picked image if available
            _image != null
                ? Image.file(
                    File(_image!.path),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : const Text('No image selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 30),
            // Display extracted information
            _extractedData != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extracted Information:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Full Name: ${_extractedData!['fullName'] ?? 'Not Available'}'),
                      Text(
                          'ID Number: ${_extractedData!['idNumber'] ?? 'Not Available'}'),
                      Text(
                          'Date of Birth: ${_extractedData!['dateOfBirth'] ?? 'Not Available'}'),
                      Text(
                          'Address: ${_extractedData!['address'] ?? 'Not Available'}'),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
