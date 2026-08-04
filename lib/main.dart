import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FireSafetyApp());
}

class FireSafetyApp extends StatelessWidget {
  const FireSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Fire Safety',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
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
  final DatabaseReference testRef =
      FirebaseDatabase.instance.ref('test/value');

  int value = 0;
  bool connected = false;
  String status = 'Checking...';

  @override
  void initState() {
    super.initState();

    testRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;

        if (!mounted) return;

        setState(() {
          if (data != null) {
            value = int.tryParse(data.toString()) ?? 0;
            connected = true;
            status = 'Firebase Connected';
          }
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          connected = false;
          status = 'Firebase Connection Error';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Smart Fire Safety'),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: connected ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 35,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ESP32 Test Value',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Live Firebase Data',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                connected
                    ? 'ESP32 is sending data'
                    : 'Waiting for ESP32 data...',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}