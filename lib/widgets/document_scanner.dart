import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';

class DocumentScanner extends StatefulWidget {
  final Function(Map<String, String>) onScanComplete;

  const DocumentScanner({super.key, required this.onScanComplete});

  @override
  State<DocumentScanner> createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScanner> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _capturedImagePath;
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImagePath = image.path;
      });
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_capturedImagePath == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(_capturedImagePath!);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final extractedData = _parseFinancialData(recognizedText.text);

      widget.onScanComplete(extractedData);
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process document')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Map<String, String> _parseFinancialData(String text) {
    final data = <String, String>{};

    // Debug: Print the extracted text
    debugPrint('OCR Extracted Text: $text');

    // Split text into lines for line-by-line analysis
    final lines = text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    debugPrint('Lines found: ${lines.length}');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim().toLowerCase();
      debugPrint('Processing line $i: $line');

      // Look for numbers in each line
      final numberMatch = RegExp(r'(\d+[,.]?\d*)').firstMatch(line);
      if (numberMatch != null) {
        final number = numberMatch.group(1)!.replaceAll(',', '');
        debugPrint('Found number in line: $number');

        // Match keywords in the line to determine what the number represents
        if (line.contains('gross') && line.contains('profit')) {
          data['grossProfit'] = number;
          debugPrint('Matched grossProfit: $number');
        } else if (line.contains('discount') && line.contains('received')) {
          data['discountReceived'] = number;
          debugPrint('Matched discountReceived: $number');
        } else if (line.contains('interest') && line.contains('received')) {
          data['interestReceived'] = number;
          debugPrint('Matched interestReceived: $number');
        } else if (line.contains('commission') && line.contains('received')) {
          data['commissionReceived'] = number;
          debugPrint('Matched commissionReceived: $number');
        } else if (line.contains('discount') && line.contains('allowed')) {
          data['discountAllowed'] = number;
          debugPrint('Matched discountAllowed: $number');
        } else if (line.contains('rent') && !line.contains('current')) {
          data['rent'] = number;
          debugPrint('Matched rent: $number');
        } else if (line.contains('employee') && line.contains('salary')) {
          data['salary'] = number;
          debugPrint('Matched salary: $number');
        } else if (line.contains('salary') && !line.contains('employee')) {
          data['salary'] = number;
          debugPrint('Matched salary: $number');
        } else if (line.contains('depreciation')) {
          data['depreciation'] = number;
          debugPrint('Matched depreciation: $number');
        } else if (line.contains('net') && line.contains('profit')) {
          data['netProfit'] = number;
          debugPrint('Matched netProfit: $number');
        } else if (line.contains('opening') && line.contains('capital')) {
          data['openingCapital'] = number;
          debugPrint('Matched openingCapital: $number');
        } else if (line.contains('drawings')) {
          data['drawings'] = number;
          debugPrint('Matched drawings: $number');
        } else if (line.contains('opening') && line.contains('inventory')) {
          data['openingInventory'] = number;
          debugPrint('Matched openingInventory: $number');
        } else if (line.contains('closing') && line.contains('inventory')) {
          data['closingInventory'] = number;
          debugPrint('Matched closingInventory: $number');
        } else if (line.contains('inventory') &&
            !line.contains('opening') &&
            !line.contains('closing')) {
          data['inventory'] = number;
          debugPrint('Matched inventory: $number');
        } else if (line.contains('receivable')) {
          data['receivable'] = number;
          debugPrint('Matched receivable: $number');
        } else if (line.contains('bank')) {
          data['bank'] = number;
          debugPrint('Matched bank: $number');
        } else if (line.contains('payable')) {
          data['payable'] = number;
          debugPrint('Matched payable: $number');
        } else if (line.contains('loan')) {
          data['loan'] = number;
          debugPrint('Matched loan: $number');
        } else if (line.contains('equipment')) {
          data['equipment'] = number;
          debugPrint('Matched equipment: $number');
        } else if (line.contains('land')) {
          data['land'] = number;
          debugPrint('Matched land: $number');
        } else if (line.contains('vehicle')) {
          data['vehicle'] = number;
          debugPrint('Matched vehicle: $number');
        } else if (line.contains('furniture')) {
          data['furniture'] = number;
          debugPrint('Matched furniture: $number');
        } else if (line.contains('building')) {
          data['building'] = number;
          debugPrint('Matched building: $number');
        } else if (line.contains('service') && line.contains('tax')) {
          data['serviceTax'] = number;
          debugPrint('Matched serviceTax: $number');
        } else if (line.contains('carriage')) {
          data['carriageInwards'] = number;
          debugPrint('Matched carriageInwards: $number');
        } else if (line.contains('insurance')) {
          data['insurance'] = number;
          debugPrint('Matched insurance: $number');
        } else if (line.contains('wages')) {
          data['wages'] = number;
          debugPrint('Matched wages: $number');
        } else if (line.contains('sales') && !line.contains('return')) {
          data['sales'] = number;
          debugPrint('Matched sales: $number');
        } else if (line.contains('purchases') && !line.contains('return')) {
          data['purchases'] = number;
          debugPrint('Matched purchases: $number');
        }
      }
    }

    debugPrint('Total extracted data: ${data.length} items');
    debugPrint('Extracted data: $data');
    return data;
  }

  void _retakeImage() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _showScannerDialog(),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF8B5A84), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Color(0xFF8B5A84)),
              SizedBox(width: 8),
              Text(
                'Scan Document',
                style: TextStyle(
                  color: Color(0xFF8B5A84),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScannerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Document Scanner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_capturedImagePath == null) ...[
                      if (_isInitialized && _controller != null)
                        Container(
                          height: 300,
                          width: double.infinity,
                          child: CameraPreview(_controller!),
                        )
                      else
                        Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _captureImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5A84),
                                foregroundColor: Colors.white,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera),
                                  SizedBox(width: 8),
                                  Text('Capture'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.file(
                          File(_capturedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _processImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5A84),
                                foregroundColor: Colors.white,
                              ),
                              child: _isProcessing
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Processing...'),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle),
                                        SizedBox(width: 8),
                                        Text('Process'),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _retakeImage,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh),
                                  SizedBox(width: 8),
                                  Text('Retake'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Position the document clearly and ensure good lighting for better results',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
