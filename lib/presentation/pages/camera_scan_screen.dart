import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/color_detection_result.dart';
import '../providers/camera_provider.dart';
import '../widgets/freshness_result_widget.dart';
import '../widgets/save_item_dialog.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraProvider>().initializeCamera();
    });
  }

  @override
  void dispose() {
    context.read<CameraProvider>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Freshness Sticker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          if (cameraProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cameraProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cameraProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      cameraProvider.initializeCamera();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (cameraProvider.cameraController == null) {
            return const Center(child: Text('Camera not available'));
          }

          return Stack(
            children: [
              // Camera Preview
              SizedBox.expand(
                child: CameraPreview(cameraProvider.cameraController!),
              ),

              // Overlay with scanning guide
              _buildScanningOverlay(context),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(context, cameraProvider),
              ),

              // Detection result overlay
              if (cameraProvider.detectionResult != null)
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: FreshnessResultWidget(
                    result: cameraProvider.detectionResult!,
                    onSave: () => _showSaveDialog(
                      context,
                      cameraProvider.detectionResult!,
                    ),
                    onDismiss: () => cameraProvider.clearDetectionResult(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanningOverlay(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Corner indicators
              ...List.generate(4, (index) {
                return Positioned(
                  top: index < 2 ? 8 : null,
                  bottom: index >= 2 ? 8 : null,
                  left: index % 2 == 0 ? 8 : null,
                  right: index % 2 == 1 ? 8 : null,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, CameraProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Position the sticker within the frame',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash toggle
              IconButton(
                onPressed: provider.toggleFlash,
                icon: Icon(
                  provider.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              // Capture button
              GestureDetector(
                onTap: provider.isProcessing
                    ? null
                    : () => _captureAndAnalyze(provider),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: provider.isProcessing
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: provider.isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),

              // Switch camera
              IconButton(
                onPressed: provider.switchCamera,
                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndAnalyze(CameraProvider provider) async {
    try {
      final image = await provider.captureImage();
      if (image != null) {
        await provider.analyzeImage(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSaveDialog(BuildContext context, ColorDetectionResult result) {
    showDialog(
      context: context,
      builder: (context) => SaveItemDialog(
        detectionResult: result,
        onSave: (name, notes) {
          // This will be handled by the provider
          context.read<CameraProvider>().saveDetectedItem(name, notes);
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Go back to home screen
        },
      ),
    );
  }
}
