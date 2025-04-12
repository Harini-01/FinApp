import 'package:flutter/material.dart';
import 'profile.dart';
import 'chatbot.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Light purple background
      body: SafeArea(
        child: SingleChildScrollView(
          // Add SingleChildScrollView here
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header with home icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expense Chart',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Chart container - clickable to go to dashboard
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardPage()),
                    );
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chart visualization
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildChartBar(40),
                              _buildChartBar(50),
                              _buildChartBar(80),
                              _buildChartBar(30),
                              _buildChartBar(60),
                              _buildChartBar(45),
                            ],
                          ),
                        ),
                        // Line chart overlay would be here in a real implementation
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Budget info and app features sections in a row
                Row(
                  children: [
                    // Budget info section - clickable to go to profile
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(userId: widget.userId)),
                          );
                        },
                        child: Container(
                          height: 180,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Profile picture
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),

                              // My Budget text
                              const Text(
                                'My Budget',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 7, 77, 10),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Budget amount
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFCE4EC), // Light pink
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '\$2,650',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Income
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE0F7FA), // Light blue
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Income',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // App features grid
                    // App features grid
                    // App features grid
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            // First row (Expenses and Goals)
                            Expanded(
                              child: Row(
                                children: [
                                  // Expenses feature
                                  Expanded(
                                    child: _buildFeatureItem(
                                      context,
                                      title: 'Expenses',
                                      color: const Color(0xFFFCE4EC),
                                      icon: Icons.account_balance_wallet,
                                      iconColor: Colors.orange,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ExpensesPage()),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 8), // Space between columns

                                  // Goals feature
                                  Expanded(
                                    child: _buildFeatureItem(
                                      context,
                                      title: 'Goals',
                                      color: const Color(0xFFFCE4EC),
                                      icon: Icons.track_changes,
                                      iconColor: Colors.pink,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const GoalsPage()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8), // Space between rows

                            // Second row (Chatbot and Insights)
                            Expanded(
                              child: Row(
                                children: [
                                  // Chatbot feature
                                  Expanded(
                                    child: _buildFeatureItem(
                                      context,
                                      title: 'Chatbot',
                                      color: const Color(0xFFE0F2F1),
                                      icon: Icons.extension,
                                      iconColor: Colors.green,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ChatbotPage()),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 8), // Space between columns

                                  // Insights feature
                                  Expanded(
                                    child: _buildFeatureItem(
                                      context,
                                      title: 'Insights',
                                      color: const Color(0xFFE3F2FD),
                                      icon: Icons.pie_chart,
                                      iconColor: Colors.blue,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const InsightsPage()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Settings and calculator row
                Row(
                  children: [
                    // Settings container
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsPage()),
                          );
                        },
                        child: Container(
                          height: 170,
                          decoration: BoxDecoration(
                            color: Color(0xFFE0F7FA), // Light blue
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Settings',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Profile setting
                              _buildSettingsItem('Profile'),
                              const Divider(height: 2),
                              // Notifications setting
                              _buildSettingsItem('Notifications'),
                              const Divider(height: 2),
                              // Security setting
                              _buildSettingsItem('Security'),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Calculator button
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          _showCalculator(context);
                        },
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.calculate,
                              size: 50,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Add some bottom padding for better scrolling experience
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: const Color.fromARGB(255, 188, 188, 188),
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: widget.userId),
                  ),
                );
              },
            ),
            label: 'Profile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transfer',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Block',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Helper method to build chart bars
  Widget _buildChartBar(double height) {
    return Container(
      width: 30,
      height: height,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }

  // Helper method to build feature grid items
  Widget _buildFeatureItem(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build settings items
  Widget _buildSettingsItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const Icon(Icons.chevron_right, color: Colors.blue),
        ],
      ),
    );
  }

  // Show calculator dialog
  void _showCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculator'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: Column(
            children: [
              // Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '0',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(height: 16),
              // Calculator buttons would go here
              // This is just a placeholder for demonstration
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _calcButton('7'),
                    _calcButton('8'),
                    _calcButton('9'),
                    _calcButton('÷'),
                    _calcButton('4'),
                    _calcButton('5'),
                    _calcButton('6'),
                    _calcButton('×'),
                    _calcButton('1'),
                    _calcButton('2'),
                    _calcButton('3'),
                    _calcButton('-'),
                    _calcButton('C'),
                    _calcButton('0'),
                    _calcButton('='),
                    _calcButton('+'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Calculator button
  Widget _calcButton(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// Placeholder classes for all the pages we need to navigate to
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Dashboard Page')),
    );
  }
}

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: const Center(child: Text('Expenses Page')),
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(child: Text('Goals Page')),
    );
  }
}

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: const Center(child: Text('Chatbot Page')),
    );
  }
}

class InsightsPage extends StatelessWidget {
  const InsightsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: const Center(child: Text('Insights Page')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Page')),
    );
  }
}
