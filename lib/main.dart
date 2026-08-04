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
      title: 'Fire Safety System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
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
  final DatabaseReference fireRef =
      FirebaseDatabase.instance.ref('fireSystem');

  String status = 'Checking...';
  int gas = 0;
  int flame = 0;
  bool fireDetected = false;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    listenToFirebase();
  }

  void listenToFirebase() {
    fireRef.onValue.listen(
      (event) {
        final value = event.snapshot.value;

        if (!mounted) return;

        if (value is Map) {
          final data = Map<String, dynamic>.from(value);

          final gasValue = data['gas'];
          final flameValue = data['flame'];
          final fireValue = data['fire'];

          setState(() {
            gas = gasValue is num
                ? gasValue.toInt()
                : int.tryParse('$gasValue') ?? 0;

            flame = flameValue is num
                ? flameValue.toInt()
                : int.tryParse('$flameValue') ?? 0;

            fireDetected = fireValue == true ||
                fireValue.toString().toLowerCase() == 'true';

            status = fireDetected
                ? '🔥 FIRE ALERT'
                : '✅ SAFE';

            connected = true;
          });
        }
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

  Color getStatusColor() {
    if (!connected) {
      return Colors.orange;
    }

    if (fireDetected) {
      return Colors.red;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🔥 Smart Fire Safety',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    fireDetected
                        ? Icons.local_fire_department
                        : connected
                            ? Icons.verified
                            : Icons.cloud_off,
                    size: 70,
                    color: statusColor,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    connected
                        ? 'Live Firebase Data'
                        : 'Waiting for Firebase...',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    title: 'Gas Sensor',
                    value: '$gas',
                    icon: Icons.gas_meter,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SensorCard(
                    title: 'Flame Sensor',
                    value: '$flame',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.warning),
                label: const Text(
                  'Emergency Response',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              connected
                  ? 'ESP32 connection active'
                  : 'ESP32 connection unavailable',
              style: TextStyle(
                fontSize: 16,
                color: connected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}