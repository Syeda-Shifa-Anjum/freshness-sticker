import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/fresh_item.dart';
import '../../domain/entities/color_detection_result.dart';
import '../../domain/repositories/fresh_item_repository.dart';
import '../../core/services/color_detection_service.dart';
import '../../core/services/notification_service.dart';

class CameraProvider with ChangeNotifier {
  final FreshItemRepository _repository;
  final ColorDetectionService _colorDetectionService;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  String? _errorMessage;
  ColorDetectionResult? _detectionResult;
  int _currentCameraIndex = 0;

  CameraProvider(this._repository, this._colorDetectionService) {
    _initializeCameras();
  }

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  bool get isFlashOn => _isFlashOn;
  String? get errorMessage => _errorMessage;
  ColorDetectionResult? get detectionResult => _detectionResult;

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      _errorMessage = 'Failed to get cameras: $e';
      notifyListeners();
    }
  }

  Future<void> initializeCamera() async {
    if (_cameras == null || _cameras!.isEmpty) {
      _errorMessage = 'No cameras available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Dispose previous controller if exists
      await _cameraController?.dispose();

      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize camera: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      notifyListeners();
    } catch (e) {
      // Flash might not be supported, ignore error
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await initializeCamera();
  }

  Future<XFile?> captureImage() async {
    if (_cameraController == null || _isProcessing) return null;

    _isProcessing = true;
    notifyListeners();

    try {
      final image = await _cameraController!.takePicture();
      return image;
    } catch (e) {
      _errorMessage = 'Failed to capture image: $e';
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> analyzeImage(XFile imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      _detectionResult = _colorDetectionService.analyzeImage(imageBytes);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to analyze image: $e';
      notifyListeners();
    }
  }

  Future<void> saveDetectedItem(String name, String? notes) async {
    if (_detectionResult == null) return;

    try {
      final item = FreshItem(
        id: const Uuid().v4(),
        name: name,
        scanDate: _detectionResult!.detectionTime,
        spoilageDate: _detectionResult!.estimatedSpoilageDate,
        status: _detectionResult!.detectedStatus,
        notes: notes,
      );

      await _repository.saveItem(item);

      // Schedule notification if item will expire
      if (item.spoilageDate != null &&
          item.spoilageDate!.isAfter(DateTime.now())) {
        await NotificationService.scheduleExpirationNotification(item);
      }

      _detectionResult = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save item: $e';
      notifyListeners();
    }
  }

  void clearDetectionResult() {
    _detectionResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
