import 'package:booksy_app/add_book/display_picture_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _cameraController;

  Future<void> initialize() async {
    var cameras = await availableCameras();
    _cameraController =
        CameraController(cameras.first, ResolutionPreset.medium);
    return _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar foto del libro'),
      ),
      body: FutureBuilder<void>(
        future: initialize(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Ocurrió un error: ${snapshot.error}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              color: Colors.black,
              child: Center(child: CameraPreview(_cameraController)),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tekePicture(context);
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  void _tekePicture(BuildContext context) async {
    var image = await _cameraController.takePicture();
    if (!mounted) return;
    var result = await Navigator.of(context).push<String>(MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(imagePath: image.path)));
    if (result != null && result.isNotEmpty) {
      if (!mounted) return;
      Navigator.pop(context, result);
    }
  }
}
