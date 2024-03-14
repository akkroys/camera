import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:photo_capture/camera_service.dart';
import 'package:photo_capture/location_service.dart';

class TakePicture extends StatefulWidget {
  const TakePicture({super.key});

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  final LocationService _locationService = LocationService();
  final CameraService _cameraService = CameraService();
  TextEditingController textEditingController = TextEditingController();
  List<CameraDescription>? cameras;
  XFile? image;
  String? latitude;
  String? longitude;
  String? commentText;

  @override
  void initState() {
    _initServices();
    super.initState();
  }

  Future<void> _initServices() async {
    cameras = await availableCameras();
    await _locationService.getCurrentLocation();
    await _cameraService.initializeCamera(cameras!);
    setState(() {});
  }

  _getLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> uploadDataToServer(
      String comment, String latitude, String longitude, File imageFile) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('https://httpbin.org/post'));

    var image = await http.MultipartFile.fromPath('image', imageFile.path);
    request.files.add(image);

    request.fields['comment'] = comment;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Данные успешно отправлены на сервер'),
        ));
    } else {
      print('Ошибка при отправке данных на сервер: ${response.reasonPhrase}');
    }
  }

  Future<void> _captureAndUpload() async {
    try {
      image = await _cameraService.takePicture();
      await uploadDataToServer(
        commentText!,
        latitude!,
        longitude!,
        File(image!.path),
      );
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Фото на сервер",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 500,
                width: 400,
                child: cameras == null || !_cameraService.isInitialized()
                    ? Center(
                        child: Text("Loading Camera..."),
                      )
                    : !_cameraService.isInitialized()
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : CameraPreview(_cameraService.controller!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textEditingController,
                  maxLines: 3,
                  onChanged: (text) {
                    commentText = text;
                  },
                  decoration: const InputDecoration(
                    suffixIcon: Icon(
                      Icons.edit,
                    ),
                    filled: true,
                    hintText: 'Введите ваш комментарий...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getLocation();
          _captureAndUpload();
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}