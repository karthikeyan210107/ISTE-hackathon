import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase can be unavailable in test or offline environments.
  }

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
  DatabaseReference? ref;

  String status = 'Checking...';
  int gas = 0;
  int flame = 0;

  @override
  void initState() {
    super.initState();
    _attachRealtimeListener();
  }

  void _attachRealtimeListener() {
    try {
      if (Firebase.apps.isNotEmpty) {
        ref = FirebaseDatabase.instance.ref('fireSystem');
        ref?.onValue.listen((event) {
          final value = event.snapshot.value;
          if (value is Map) {
            final data = Map<String, dynamic>.from(value);
            if (!mounted) return;

            setState(() {
              gas = (data['gas'] as num?)?.toInt() ?? 0;
              flame = (data['flame'] as num?)?.toInt() ?? 0;
              status = (data['fire'] as bool? ?? false)
                  ? '🔥 FIRE ALERT'
                  : '✅ SAFE';
            });
          }
        });
      }
    } catch (_) {
      ref = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Smart Fire Safety'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            status,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Gas Sensor: $gas',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Flame Sensor: $flame',
                    style: const TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Future: emergency actions
            },
            child: const Text('Emergency Response'),
          ),
        ],
      ),
    );
  }
}