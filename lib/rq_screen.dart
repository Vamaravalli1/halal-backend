import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:http/http.dart' as http;

class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String scannedCode = '';
  Map<String, dynamic>? barcodeDetails;
  bool isLoading = false;
  bool? userHalalPreference; // null for no preference, true for agree, false for disagree
  int agreeCount = 0;
  int disagreeCount = 0;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final code = scanData.code ?? '';
      setState(() {
        scannedCode = code;
      });

      if (code.isNotEmpty) {
        await fetchBarcodeDetails(code);
      }
    });
  }

  Future<void> fetchBarcodeDetails(String code) async {
    setState(() {
      isLoading = true;
      barcodeDetails = null;
    });

    final url = Uri.parse("http://192.168.0.58:60098/api/lays/scan/$code");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data.isNotEmpty) {
          setState(() {
            barcodeDetails = data;
            agreeCount = data['agreeCount'] ?? 0;
            disagreeCount = data['disagreeCount'] ?? 0;
          });
          _showDetailsDialog(data);
        } else {
          setState(() {
            barcodeDetails = {'message': 'No data available for this code'};
          });
        }
      } else {
        setState(() {
          barcodeDetails = {'message': 'Failed to fetch details. Try again.'};
        });
      }
    } catch (e) {
      setState(() {
        barcodeDetails = {'message': 'An error occurred. Check your connection.'};
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updatePreference(bool agree) async {
    if (scannedCode.isEmpty) return;

    final url = Uri.parse("http://192.168.0.58:60098/api/lays/$scannedCode/vote?agree=$agree&undo=false");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Parse the updated response to get the new counts
        final updatedData = jsonDecode(response.body);

        setState(() {
          userHalalPreference = agree;
          agreeCount = updatedData['agreeCount'];
          disagreeCount = updatedData['disagreeCount'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update preference. Try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Check your connection.')),
      );
    }
  }

  // Optimize this function for faster performance
  void _showDetailsDialog(Map<String, dynamic> details) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Barcode Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details['productName'] != null)
                  Text('Product Name: ${details['productName']}', style: const TextStyle(fontSize: 16)),
                if (details['brand'] != null)
                  Text('Brand: ${details['brand']}', style: const TextStyle(fontSize: 16)),
                if (details['nutritionalInformation'] != null)
                  Text('Nutritional Information: ${details['nutritionalInformation']}', style: const TextStyle(fontSize: 16)),
                if (details['ingredients'] != null)
                  Text('Ingredients: ${details['ingredients']}', style: const TextStyle(fontSize: 16)),
                if (details['countryOfOrigin'] != null)
                  Text('Country of Origin: ${details['countryOfOrigin']}', style: const TextStyle(fontSize: 16)),
                if (details['halal'] != null)
                  Text('Halal: ${details['halal'] ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
                if (details['vegan'] != null)
                  Text('Vegan: ${details['vegan'] ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
                if (details['glutenFree'] != null)
                  Text('Gluten Free: ${details['glutenFree'] ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                if (details.containsKey('halal'))
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: userHalalPreference == true ? Colors.green : Colors.grey,
                              size: 48,
                            ),
                            onPressed: () => updatePreference(true), // Always allow thumbs up
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              Icons.thumb_down,
                              color: userHalalPreference == false ? Colors.red : Colors.grey,
                              size: 48,
                            ),
                            onPressed: () => updatePreference(false), // Always allow thumbs down
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Agree: $agreeCount', style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 20),
                          Text('Disagree: $disagreeCount', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  scannedCode = '';
                  barcodeDetails = null;
                });
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR CODE SCANNER"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          height: 500,
          width: 530,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Place the QR inside the frame',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                flex: 8,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Scanned Code:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          scannedCode.isEmpty
                              ? 'No code scanned yet'
                              : scannedCode,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (isLoading)
                          const CircularProgressIndicator(),
                        if (!isLoading && barcodeDetails != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              barcodeDetails!['message'] ?? 'Details fetched successfully',
                              style: TextStyle(
                                fontSize: 16,
                                color: barcodeDetails!['message']?.startsWith('Failed') ??
                                    barcodeDetails!['message']?.startsWith('An error')
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              textAlign: TextAlign.center,
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
      ),
    );
  }
}