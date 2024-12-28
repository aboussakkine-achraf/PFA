import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ScanIdentityWidget extends StatefulWidget {
  @override
  _ScanIdentityWidgetState createState() => _ScanIdentityWidgetState();
}

class _ScanIdentityWidgetState extends State<ScanIdentityWidget> {
  File? _image; // Holds the captured image
  String _feedback =
      "Please ensure the following fields are visible: Name, ID Number, DOB, Address."; // Guidance text
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  // Pick image from the camera
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _feedback = "Processing image... Please wait.";
      });
      await _processImage(_image!);
    } else {
      setState(() {
        _feedback = "No image selected. Please try again.";
      });
    }
  }

  // Process the image and extract data
  Future<void> _processImage(File image) async {
    try {
      // Pre-process image to check quality
      if (!_isValidImage(image)) {
        setState(() {
          _feedback =
              "Image quality is insufficient. Please take a clearer picture.";
        });
        return;
      }

      final inputImage = InputImage.fromFile(image);

      // Use ML Kit to check if text is detected
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Check if text is detected
      if (recognizedText.text.isEmpty) {
        setState(() {
          _feedback =
              "No text detected in the image. Please retake the picture.";
        });
        return;
      }

      // Validate the fields
      final extractedData = _validateFields(recognizedText);

      if (extractedData.isEmpty) {
        setState(() {
          _feedback = "Some fields are missing. Please retake the picture.";
        });
      } else {
        setState(() {
          _feedback = "Successfully extracted all fields:\n${extractedData}";
        });
      }
    } catch (e) {
      setState(() {
        _feedback = "Error processing image. Please try again.";
      });
    }
  }

  // Validate the presence of required fields
  String _validateFields(RecognizedText recognizedText) {
    String name = "";
    String idNumber = "";
    String dob = "";
    String address = "";

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text.toLowerCase();

        if (text.contains("name: ")) {
          name = line.text;
        } else if (text.contains("id: ")) {
          idNumber = line.text;
        } else if (text.contains("dob: ")) {
          dob = line.text;
        } else if (text.contains("address: ")) {
          address = line.text;
        }
      }
    }

    if (name.isNotEmpty &&
        idNumber.isNotEmpty &&
        dob.isNotEmpty &&
        address.isNotEmpty) {
      return "Name: $name\nID Number: $idNumber\nDOB: $dob\nAddress: $address";
    } else {
      // Return the missing fields for the user to correct
      List<String> missingFields = [];
      if (name.isEmpty) missingFields.add("Name");
      if (idNumber.isEmpty) missingFields.add("ID Number");
      if (dob.isEmpty) missingFields.add("DOB");
      if (address.isEmpty) missingFields.add("Address");

      return "Missing fields: ${missingFields.join(', ')}";
    }
  }

  // Check if the image is valid (resolution, brightness, sharpness)
  bool _isValidImage(File image) {
    // You can customize this to perform further checks on the image
    final imageBytes = image.readAsBytesSync();
    if (imageBytes.length < 1000) {
      return false; // Simple check for image size (can be improved)
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Identity Card'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Image.file(
                      _image!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  : Text('No image selected'),
              SizedBox(height: 20),
              Text(
                _feedback,
                style: TextStyle(color: const Color.fromARGB(255, 10, 10, 10)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Scan Identity Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}
