import 'package:flutter/material.dart';
import 'package:mosque_locator/rq_screen.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mosque Locator App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const QRCode(), // Updated to reflect the `QRCode` widget from `rq_screen.dart`
    const MosqueLocatorPage(),
    const RestaurantPage(),
    const OtherFeaturesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mosque Locator App'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Set background color of BottomNavigationBar to black
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.green,
            icon: Icon(Icons.qr_code_scanner),
            label: 'Barcode Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Mosque Locator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Others',
          ),
        ],
      ),
    );
  }
}

class MosqueLocatorPage extends StatelessWidget {
  const MosqueLocatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mosque Locator Feature'),
    );
  }
}

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Restaurant Feature'),
    );
  }
}

class OtherFeaturesPage extends StatelessWidget {
  const OtherFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Other Features'),
    );
  }
}
