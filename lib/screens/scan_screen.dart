import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/network.dart';
import '../services/ocr_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'confirm_screen.dart';

class ScanScreen extends StatefulWidget {
  final Network network;

  const ScanScreen({super.key, this.network = Network.econet});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  final _ocrService = OcrService();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _error = 'Camera permission is needed to scan a voucher.');
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera found on this device.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (e) {
      setState(() => _error = 'Could not start the camera: $e');
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      final candidates = await _ocrService.extractPinCandidates(file.path);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConfirmScreen(
            initialNetwork: widget.network,
            initialPin: candidates.isNotEmpty ? candidates.first : '',
            candidates: candidates,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Could not read the voucher. Try again or enter manually.';
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            CameraPreview(_controller!)
          else
            Container(color: AppColors.brandGreenDark),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.close,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ConfirmScreen(
                              initialNetwork: widget.network,
                              initialPin: '',
                            ),
                          ),
                        ),
                        child: const Text(
                          'Enter manually',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GlassCard(
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.ink),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Align the voucher PIN inside this frame',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _busy ? null : _capture,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white54, width: 4),
                    ),
                    child: _busy
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
