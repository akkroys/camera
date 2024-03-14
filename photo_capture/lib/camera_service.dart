import 'package:camera/camera.dart';

class CameraService {
  late CameraController _controller;

  bool isInitialized() {
    return _controller.value.isInitialized;
  }
  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    _controller = CameraController(cameras[0], ResolutionPreset.max);
    await _controller.initialize();
  }

  Future<XFile> takePicture() async {
    return await _controller.takePicture();
  }

  void dispose() {
    _controller.dispose();
  }
  CameraController? get controller => _controller;
}
