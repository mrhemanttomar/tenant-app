import 'package:flutter/material.dart';

void main() {
  runApp(const TenantManagementApp());
}

class TenantManagementApp extends StatelessWidget {
  const TenantManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PropManager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Navy Blue
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF0D9488),
        ),
        useMaterial3: true,
      ),
      home: const MainDashboardScreen(),
    );
  }
}

class Property {
  final String id;
  final String name;
  final String address;
  final int totalUnits;

  Property({required this.id, required this.name, required this.address, required this.totalUnits});
}

class Tenant {
  final String name;
  final String propertyName;
  final double rentAmount;
  final int dueDay;
  bool isPaid;

  Tenant({
    required this.name,
    required this.propertyName,
    required this.rentAmount,
    required this.dueDay,
    this.isPaid = false,
  });
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  bool _isSubscribed = false;
  bool _isAdmin = false;

  final List<Property> _properties = [
    Property(id: '1', name: 'Sunrise Apartments', address: 'Sector 62, Noida', totalUnits: 4),
    Property(id: '2', name: 'Green Valley Villa', address: 'Indiranagar, Bengaluru', totalUnits: 2),
  ];

  final List<Tenant> _tenants = [
    Tenant(name: 'Rahul Sharma', propertyName: 'Sunrise Apts (Unit 101)', rentAmount: 18000, dueDay: 5, isPaid: true),
    Tenant(name: 'Priya Verma', propertyName: 'Sunrise Apts (Unit 102)', rentAmount: 16500, dueDay: 5, isPaid: false),
    Tenant(name: 'Amit Patel', propertyName: 'Green Valley Villa', rentAmount: 25000, dueDay: 10, isPaid: false),
  ];

  void _addProperty(String name, String address, int units) {
    setState(() {
      _properties.add(Property(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        address: address,
        totalUnits: units,
      ));
    });
  }

  void _checkAndAddProperty() {
    if (_isAdmin || _isSubscribed || _properties.length < 2) {
      _showAddPropertyBottomSheet();
    } else {
      _showPaywallDialog();
    }
  }

  void _showPaywallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Free Limit Reached'),
          ],
        ),
        content: const Text(
          'Free landlords can manage up to 2 properties.\n\nUpgrade to Pro Plan for ₹499/month to manage unlimited properties and collect rent automatically!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              Navigator.pop(context);
              _showUpgradeModal();
            },
            child: const Text('Upgrade to Pro', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpgradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, size: 60, color: Colors.amber),
            const SizedBox(height: 10),
            const Text('Upgrade to Pro Plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Unlimited Properties • WhatsApp Reminders • Auto Invoices', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Monthly Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('₹499 / mo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                onPressed: () {
                  setState(() => _isSubscribed = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscribed Successfully! You can now add unlimited properties.')),
                  );
                },
                child: const Text('Pay with Razorpay (Demo)', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPropertyBottomSheet() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final unitsController = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Property', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Property Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: unitsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Units/Rooms', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                onPressed: () {
                  if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                    _addProperty(nameController.text, addressController.text, int.tryParse(unitsController.text) ?? 1);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Property', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCollected = _tenants.where((t) => t.isPaid).fold(0, (sum, t) => sum + t.rentAmount);
    double totalPending = _tenants.where((t) => !t.isPaid).fold(0, (sum, t) => sum + t.rentAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PropManager', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          Row(
            children: [
              const Text('Admin Mode', style: TextStyle(color: Colors.white, fontSize: 12)),
              Switch(
                value: _isAdmin,
                activeColor: Colors.amber,
                onChanged: (val) {
                  setState(() => _isAdmin = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? 'Admin Mode Activated (Bypasses Limits)' : 'Landlord Mode Activated')),
                  );
                },
              ),
            ],
          )
        ],
      ),
      body: _selectedIndex == 0 ? _buildDashboardTab(totalCollected, totalPending) : _buildTenantsTab(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _checkAndAddProperty,
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Property (${_properties.length}/2)',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.apartment), label: 'Properties'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Tenants'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(double collected, double pending) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isSubscribed && !_isAdmin)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber[700]!)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Free Plan: ${_properties.length}/2 properties used.', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(onPressed: _showUpgradeModal, child: const Text('Upgrade')),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Collected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('₹${collected.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pending Rent', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('₹${pending.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Your Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._properties.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.home, color: Colors.white)),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p.address} • ${p.totalUnits} Units'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTenantsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tenants.length,
      itemBuilder: (context, idx) {
        final t = _tenants[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: t.isPaid ? Colors.green[100] : Colors.orange[100],
              child: Icon(t.isPaid ? Icons.check : Icons.priority_high, color: t.isPaid ? Colors.green : Colors.orange),
            ),
            title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${t.propertyName}\nDue: ${t.dueDay}th of month'),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${t.rentAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => t.isPaid = !t.isPaid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: t.isPaid ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(12)),
                    child: Text(t.isPaid ? 'PAID' : 'PENDING', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
