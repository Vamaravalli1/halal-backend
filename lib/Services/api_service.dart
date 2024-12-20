import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

class ApiService {
  Future<void> testApi() async {
    // Define the URL
    final url = Uri.parse("http://127.0.0.1:60098/api/lays/scan/1234567890");

    try {
      // Send the GET request
      final response = await http.get(url);

      // Check the response status
      if (response.statusCode == 200) {
        print("Response Data: ${response.body}");
      } else {
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }
}
