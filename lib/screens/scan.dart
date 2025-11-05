import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scan_results.dart';

// Accept selections from Home (optional so existing routes still work)
class ScanPage extends StatefulWidget {
  const ScanPage({super.key, this.selectedCategory, this.selectedFood});

  final String? selectedCategory;
  final String? selectedFood;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera init error: $e')));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    if (_controller == null || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);
      await (_initializeControllerFuture ?? Future.value());

      // 1) Capture image
      final xfile = await _controller!.takePicture();
      final file = File(xfile.path);

      // 2) Crop to white grid using image package
      final bytes = await file.readAsBytes();

      // Safely decode image and fix EXIF orientation
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception('Unable to decode image bytes');
      }
      final original = img.bakeOrientation(decoded);

      // Optional: handle EXIF orientation here if needed (see notes)
      final imgWidth = original.width;
      final imgHeight = original.height;

      // White grid rectangle in painter: left/top = 15%, width/height = 70%
      final cropLeft = (imgWidth * 0.37).round();
      final cropTop = (imgHeight * 0.37).round();
      final cropWidth = (imgWidth * 0.40).round();
      final cropHeight = (imgHeight * 0.40).round();

      // Ensure crop is within bounds (defensive)
      final safeLeft = cropLeft.clamp(0, imgWidth - 1).toInt();
      final safeTop = cropTop.clamp(0, imgHeight - 1).toInt();
      final safeWidth = cropWidth.clamp(1, imgWidth - safeLeft).toInt();
      final safeHeight = cropHeight.clamp(1, imgHeight - safeTop).toInt();

      final cropped = img.copyCrop(
        original,
        x: safeLeft,
        y: safeTop,
        width: safeWidth,
        height: safeHeight,
      );

      // Save cropped image back to file (JPEG)
      final croppedBytes = img.encodeJpg(cropped, quality: 100);
      await file.writeAsBytes(croppedBytes, flush: true);

      // 3) Upload to Storage
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');
      final uid = user.uid;
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final storagePath = "users/$uid/scans/$ts.jpg";
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      // 4) Use selections passed in (fallbacks are empty)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final selCategory =
          (userDoc.data()?['selectedCategory'] as String?) ?? '';
      final selFood = (userDoc.data()?['selectedFood'] as String?) ?? '';

      // 5) Create pending scan doc to trigger Cloud Function
      final scanRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('scans')
          .doc(ts);

      await scanRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // or 'complete' when done
        'selectedCategory': selCategory,
        'selectedFood': selFood,
        'category': selCategory,
        'food': selFood,
        'imageUrl': downloadUrl,
        'storagePath': storagePath,
        'phValue': 0,
        'freshness': 'unknown',
        'hoursToConsume': 0,
        'safePhMin': 0,
        'safePhMax': 14,
      }, SetOptions(merge: true));

      // 6) Wait for function to finish (status != 'pending')
      final snap = await scanRef.snapshots().firstWhere(
        (s) => (s.data()?['status'] ?? 'pending') != 'pending',
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      final data = snap.data() ?? {};
      if ((data['status'] as String?) == 'complete') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultsScreen(
              imageUrl: downloadUrl,
              phValue: (data['phValue'] ?? 0).toDouble(),
              freshness: (data['freshness'] ?? 'unknown').toString(),
              hoursToConsume: (data['hoursToConsume'] ?? 0) as int,
              safePhMin: (data['safePhMin'] as num?)?.toDouble(),
              safePhMax: (data['safePhMax'] as num?)?.toDouble(),
              selectedFood: (data['selectedFood'] ?? '') as String?,
              isInSafeRange: data['isInSafeRange'] as bool?,
            ),
          ),
        );
      } else {
        final msg = (data['errorMessage'] ?? 'Analysis failed').toString();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e, st) {
      // Log or print as needed
      // debugPrint('Scan error: $e\n$st');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } else {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // removes the back arrow
        title: const Text(
          'Scan pH Level',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildCameraPreview(),
                      if (!_isProcessing)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: CustomPaint(
                            size: Size(
                              MediaQuery.of(context).size.width * 0.7,
                              MediaQuery.of(context).size.width * 0.7,
                            ),
                            painter: ScanFramePainter(),
                          ),
                        ),
                      if (!_isProcessing)
                        Positioned(
                          bottom: 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Center your pH strip in the frame',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Analyzing pH level...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isProcessing
                            ? Icons.hourglass_empty
                            : Icons.camera_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isProcessing ? 'Processing...' : 'Scan Now',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null || _initializeControllerFuture == null) {
      return Container(
        color: const Color(0xFFF0F0F0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// ✅ Custom painter for scan frame border
class ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.7,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
