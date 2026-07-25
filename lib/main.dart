import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Connects directly to your Firebase Project: tenant-app-8576c
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBw4LTLSH-zzkOdXaAr1U6HYebyr_7uD9Y",
      authDomain: "tenant-app-8576c.firebaseapp.com",
      projectId: "tenant-app-8576c",
      storageBucket: "tenant-app-8576c.firebasestorage.app",
      messagingSenderId: "812549040427",
      appId: "1:812549040427:web:851ca6df44d0d7da037d6e",
    ),
  );
  
  runApp(const TenantManagementApp());
}

class TenantManagementApp extends StatelessWidget {
  const TenantManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PropManager Cloud',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// ----------------- AUTH GATE -----------------
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainDashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// ----------------- LOGIN SCREEN -----------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  Future<void> _submitAuth() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        UserCredential creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await FirebaseFirestore.instance.collection('users').doc(creds.user!.uid).set({
          'email': _emailController.text.trim(),
          'role': 'landlord',
          'isSubscribed': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.apartment_rounded, size: 60, color: Color(0xFF1E3A8A)),
                  const SizedBox(height: 10),
                  Text(_isSignUp ? 'Create Account' : 'Landlord Login',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                            onPressed: _submitAuth,
                            child: Text(_isSignUp ? 'Sign Up' : 'Log In', style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(_isSignUp ? 'Already have an account? Log In' : 'New Landlord? Create Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- MAIN DASHBOARD -----------------
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _showAddPropertyDialog(int currentPropertyCount) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    if (currentPropertyCount >= 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Free Limit Reached (2/2)'),
          content: const Text('Free tier accounts can manage up to 2 properties. Upgrade to Pro for unlimited access.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Property'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Property Name')),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('properties').add({
                  'landlordId': _uid,
                  'name': nameCtrl.text,
                  'address': addressCtrl.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save to Firebase'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PropManager Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .where('landlordId', isEqualTo: _uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final properties = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Properties Managed:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${properties.length} / 2', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Firebase Cloud Database', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (properties.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No properties found in your database. Tap + below to save your first property to Firebase!', textAlign: TextAlign.center),
                ),
              ...properties.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.home_work, color: Color(0xFF1E3A8A)),
                    title: Text(data['name'] ?? 'Property', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['address'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => FirebaseFirestore.instance.collection('properties').doc(doc.id).delete(),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .where('landlordId', isEqualTo: _uid)
            .snapshots(),
        builder: (context, snapshot) {
          int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFF1E3A8A),
            onPressed: () => _showAddPropertyDialog(count),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Add Property ($count/2)', style: const TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}
