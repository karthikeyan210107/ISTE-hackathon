import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref('fireSystem');

  int gas = 0;
  int flame = 0;
  bool fire = false;
  bool buzzer = false;

  @override
  void initState() {
    super.initState();

    ref.onValue.listen((event) {
      final value = event.snapshot.value;

      if (value is Map) {
        final data = Map<String, dynamic>.from(value);

        if (!mounted) return;

        setState(() {
          gas = (data['gas'] as num?)?.toInt() ?? 0;
          flame = (data['flame'] as num?)?.toInt() ?? 0;
          fire = data['fire'] == true;
          buzzer = data['buzzer'] == true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Smart Fire Safety'),
        actions: [
          IconButton(
            tooltip: 'Admin',
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: fire
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        fire
                            ? Icons.warning_rounded
                            : Icons.check_circle,
                        size: 75,
                        color: fire
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        fire
                            ? '🔥 FIRE ALERT'
                            : '✅ SYSTEM SAFE',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: fire
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: _sensorCard(
                        'Gas Sensor',
                        gas.toString(),
                        Icons.gas_meter,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _sensorCard(
                        'Flame Sensor',
                        flame.toString(),
                        Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: buzzer
                        ? Colors.red.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        buzzer
                            ? Icons.volume_up
                            : Icons.volume_off,
                        size: 40,
                        color: buzzer
                            ? Colors.red
                            : Colors.grey,
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Buzzer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            buzzer ? 'ON' : 'OFF',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: buzzer
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/admin',
                    );
                  },
                  icon: const Icon(
                    Icons.admin_panel_settings,
                  ),
                  label: const Text('ADMIN PANEL'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sensorCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Icon(
              icon,
              size: 45,
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

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref('fireSystem');

  final TextEditingController passwordController =
      TextEditingController();

  bool loggedIn = false;

  int gas = 0;
  int flame = 0;
  bool fire = false;
  bool buzzer = false;
  bool buzzerTest = false;

  @override
  void initState() {
    super.initState();

    ref.onValue.listen((event) {
      final value = event.snapshot.value;

      if (value is Map) {
        final data = Map<String, dynamic>.from(value);

        if (!mounted) return;

        setState(() {
          gas = (data['gas'] as num?)?.toInt() ?? 0;
          flame = (data['flame'] as num?)?.toInt() ?? 0;
          fire = data['fire'] == true;
          buzzer = data['buzzer'] == true;
          buzzerTest = data['buzzerTest'] == true;
        });
      }
    });
  }

  void login() {
    if (passwordController.text == 'admin123') {
      setState(() {
        loggedIn = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password'),
        ),
      );
    }
  }

  Future<void> testBuzzer() async {
    await ref.update({
      'buzzerTest': true,
    });
  }

  Future<void> stopBuzzer() async {
    await ref.update({
      'buzzerTest': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return _loginPage();
    }

    return _adminDashboard();
  }

  Widget _loginPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: Card(
            margin: const EdgeInsets.all(25),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 75,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ADMIN LOGIN',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    onSubmitted: (_) => login(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: login,
                      child: const Text('LOGIN'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠 Admin Panel'),
        actions: [
          IconButton(
            tooltip: 'Main Dashboard',
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
              children: [
                const Text(
                  'SYSTEM MAINTENANCE',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Monitor and test the fire safety system',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                _statusCard(
                  'Gas Sensor',
                  gas.toString(),
                  Icons.gas_meter,
                  gas > 1800,
                ),

                _statusCard(
                  'Flame Sensor',
                  flame.toString(),
                  Icons.local_fire_department,
                  false,
                ),

                _statusCard(
                  'Fire Detection',
                  fire
                      ? 'FIRE DETECTED'
                      : 'SYSTEM SAFE',
                  Icons.warning,
                  fire,
                ),

                _statusCard(
                  'Buzzer',
                  buzzer ? 'ON' : 'OFF',
                  buzzer
                      ? Icons.volume_up
                      : Icons.volume_off,
                  buzzer,
                ),

                const SizedBox(height: 25),

                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.volume_up,
                          size: 65,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'BUZZER TEST',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Test the physical buzzer connected to the ESP32.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: buzzerTest
                                ? stopBuzzer
                                : testBuzzer,
                            icon: Icon(
                              buzzerTest
                                  ? Icons.stop
                                  : Icons.volume_up,
                            ),
                            label: Text(
                              buzzerTest
                                  ? 'STOP BUZZER'
                                  : 'TEST BUZZER',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Card(
                  child: ListTile(
                    leading: Icon(
                      buzzer
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: buzzer
                          ? Colors.green
                          : Colors.grey,
                      size: 35,
                    ),
                    title: const Text(
                      'Physical Buzzer',
                    ),
                    subtitle: Text(
                      buzzer
                          ? 'Buzzer is currently ON'
                          : 'Buzzer is currently OFF',
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Card(
                  child: ListTile(
                    leading: Icon(
                      fire
                          ? Icons.warning
                          : Icons.check_circle,
                      color: fire
                          ? Colors.red
                          : Colors.green,
                      size: 35,
                    ),
                    title: const Text(
                      'Fire Detection',
                    ),
                    subtitle: Text(
                      fire
                          ? 'ALERT: Possible fire detected'
                          : 'No fire detected',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(
    String title,
    String value,
    IconData icon,
    bool alert,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Icon(
          icon,
          size: 42,
          color: alert
              ? Colors.red
              : Colors.green,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          alert
              ? Icons.warning
              : Icons.check_circle,
          color: alert
              ? Colors.red
              : Colors.green,
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}