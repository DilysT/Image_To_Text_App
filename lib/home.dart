import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String result = '';
  File? image;
  final ImagePicker imagePicker = ImagePicker(); // Đã khởi tạo sẵn

  @override
  void initState() {
    super.initState();
    requestCameraPermission(); // Yêu cầu quyền camera khi ứng dụng mở
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      print("Quyền camera bị từ chối.");
    } else if (status.isPermanentlyDenied) {
      print("Quyền camera bị từ chối vĩnh viễn. Mở cài đặt...");
      openAppSettings(); // Điều hướng người dùng vào cài đặt
    }
  }


  Future<void> pickImageFromCamera() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      XFile? pickedFile = await imagePicker.pickImage(
          source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
        performImageLabelling();
      }
    } else {
      print("Không có quyền truy cập camera.");
    }
  }

  pickImageFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      performImageLabelling();
    }
  }


  performImageLabelling() async {
    if (image == null) return;

    final InputImage inputImage = InputImage.fromFile(image!);
    final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

    final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage);

    String extractedText = '';

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        extractedText += '${line.text}\n';
      }
      extractedText += '\n'; // Xuống dòng giữa các đoạn
    }

    setState(() {
      result = extractedText;
    });

    textRecognizer.close(); // Đóng trình nhận diện để tiết kiệm bộ nhớ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(width: 200),
            Container(
              height: 450,
              width: 350,
              margin: const EdgeInsets.only(top: 70),
              padding: const EdgeInsets.only(left: 20, bottom: 5, right: 10),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    result,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/note.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, right: 140),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/pin.png',
                          height: 240,
                          width: 240,
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            pickImageFromGallery();
                          },
                          onLongPress: () {
                            pickImageFromCamera();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 25),
                            child: image != null
                                ? Image.file(
                              image!,
                              width: 140,
                              height: 192,
                              fit: BoxFit.fill,
                            )
                                : Container(
                              width: 240,
                              height: 200,
                              child: const Icon(
                                Icons.camera_enhance_sharp,
                                size: 100,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Khoảng cách giữa nút và chữ
                  const Text(
                    "Long press to take a photo", // Chữ note nhỏ
                    style: TextStyle(fontSize: 14, color: Colors.lightBlueAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
