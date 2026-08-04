import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FireSafetyApp());
}

class FireSafetyApp extends StatelessWidget {
  const FireSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fire Safety System',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int testValue = 0;
  bool connected = false;

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance.ref('test/value').onValue.listen((event) {
      final value = event.snapshot.value;

      if (value != null) {
        setState(() {
          testValue = int.tryParse(value.toString()) ?? 0;
          connected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Fire Safety System'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              connected ? 'Firebase Connected' : 'Connecting...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'ESP32 Test Value',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 15),
            Text(
              '$testValue',
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Updates every 5 seconds',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}