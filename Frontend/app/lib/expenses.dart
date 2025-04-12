import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ExpensePage extends StatefulWidget {
  final String userId;

  const ExpensePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String currentMonth =
      DateTime.now().toString().substring(0, 7); // YYYY-MM format
  List<Map<String, dynamic>> expenses = [];
  double monthlyIncome = 0;
  double totalExpenses = 0;

  final List<ExpenseCategory> categories = [
    ExpenseCategory(name: 'Food', icon: Icons.restaurant, color: Colors.orange),
    ExpenseCategory(
        name: 'Entertainment', icon: Icons.movie, color: Colors.purple),
    ExpenseCategory(
        name: 'Telephone', icon: Icons.phone_android, color: Colors.blue),
    ExpenseCategory(
        name: 'Shopping', icon: Icons.shopping_cart, color: Colors.pink),
    ExpenseCategory(
        name: 'Education', icon: Icons.school, color: Colors.indigo),
    ExpenseCategory(name: 'Beauty', icon: Icons.face, color: Colors.red),
    ExpenseCategory(
        name: 'Sport', icon: Icons.sports_soccer, color: Colors.green),
    ExpenseCategory(name: 'Social', icon: Icons.people, color: Colors.teal),
    ExpenseCategory(
        name: 'Transport', icon: Icons.directions_bus, color: Colors.amber),
    ExpenseCategory(
        name: 'Clothing', icon: Icons.checkroom, color: Colors.deepPurple),
    ExpenseCategory(
        name: 'Car', icon: Icons.directions_car, color: Colors.blue),
    ExpenseCategory(name: 'Wine', icon: Icons.wine_bar, color: Colors.red),
    ExpenseCategory(
        name: 'Cigarette', icon: Icons.smoking_rooms, color: Colors.grey),
    ExpenseCategory(
        name: 'Electronics', icon: Icons.devices, color: Colors.indigo),
    ExpenseCategory(
        name: 'Travel', icon: Icons.flight, color: Colors.lightBlue),
    ExpenseCategory(
        name: 'Health', icon: Icons.medical_services, color: Colors.red),
  ];

  String? emoji;
  List<Map<String, dynamic>> localExpenses = [];
  //var totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Keep this to get monthly income
    _loadExpenses(); // This will now just load from local array
  }

    // Check if the user logged in today
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastLoginDate = prefs.getString('lastLoginDate');
    String currentDate = DateTime.now().toIso8601String().substring(0, 10); // Get YYYY-MM-DD format

    if (lastLoginDate == currentDate) {
      setState(() {
        emoji = '😊'; // Happy face
      });
    } else {
      setState(() {
        emoji = '😞'; // Sad face
      });
      prefs.setString('lastLoginDate', currentDate); // Update last login date
}
}

  Future<void> _loadUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5001/finapp-d7e39/us-central1/getProfile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          monthlyIncome = (data['profile']['monthlyIncome'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  void _loadExpenses() {
    setState(() {
      expenses = List.from(localExpenses);
      totalExpenses = expenses.fold(
          0.0, (sum, expense) => sum + (expense['amount'] as double));
    });
  }

  Future<void> _addExpense(String category, double amount, String? note) async {
    final selectedCategory = categories.firstWhere(
      (cat) => cat.name == category,
      orElse: () => categories[0],
    );

    final newExpense = {
      'category': category,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'iconData': selectedCategory.icon.codePoint,
      'color': selectedCategory.color.value,
    };

    setState(() {
      localExpenses.insert(0, newExpense); // Add to beginning of list
      _loadExpenses(); // Update the display list
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double balance = monthlyIncome - totalExpenses;
    double expensePercentage = monthlyIncome > 0
        ? (totalExpenses / monthlyIncome).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBalance(balance, expensePercentage),
            _buildExpensesList(),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                currentMonth,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            emoji ?? '😞', // Default to sad face if emoji is null
            style: TextStyle(fontSize: 30),),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalance(double balance, double expensePercentage) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: CircleProgressPainter(
              progress: expensePercentage,
              strokeWidth: 12,
              progressColor: Colors.greenAccent,
              backgroundColor: Colors.white24,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn('Expense', totalExpenses),
              Container(width: 1, height: 40, color: Colors.white38),
              _buildInfoColumn('Income', monthlyIncome),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String title, double amount) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Add Expense Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildAddExpenseButton(),
            ),

            // Expenses List
            Expanded(
              child: expenses.isEmpty
                  ? const Center(
                      child: Text(
                        'No expenses yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final date = DateTime.parse(expense['date']);
                        final formattedDate =
                            "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                        return Card(
                          elevation: 2,
                          color: const Color.fromARGB(255, 223, 180, 237),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple[50],
                              radius: 25,
                              child: Icon(
                                categories
                                    .firstWhere(
                                      (cat) => cat.name == expense['category'],
                                      orElse: () => categories[0],
                                    )
                                    .icon,
                                color: Colors.purple,
                                size: 24,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense['category'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${expense['amount'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExpenseButton() {
    return Center(
      child: FloatingActionButton(
        onPressed: () => _showAddExpenseModal(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.block_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showAddExpenseModal() {
    String? selectedCategory;
    String calculation = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Scrollable categories section
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: Colors.purple[50],
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio:
                                  0.8, // Adjusted for larger icons
                            ),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedCategory = category.name;
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: selectedCategory == category.name
                                            ? Colors.purple
                                            : Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        category.icon,
                                        size: 28, // Increased icon size
                                        color: selectedCategory == category.name
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          // Display calculation result
                          Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              calculation.isEmpty ? '0' : calculation,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Fixed calculator section
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Calculator Grid
                      // GridView.count(
                      //   shrinkWrap: true,
                      //   physics: const NeverScrollableScrollPhysics(),
                      //   crossAxisCount: 4,
                      //   childAspectRatio: 1.3,
                      //   mainAxisSpacing: 1,
                      //   crossAxisSpacing: 1,
                      //   children: [

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        childAspectRatio: 1.3,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        children: [
                          _buildCalculatorButton('7', onPressed: () {
                            setModalState(() => calculation += '7');
                          }),
                          _buildCalculatorButton('8', onPressed: () {
                            setModalState(() => calculation += '8');
                          }),
                          _buildCalculatorButton('9', onPressed: () {
                            setModalState(() => calculation += '9');
                          }),
                          _buildCalculatorButton('⌫', onPressed: () {
                            setModalState(() {
                              if (calculation.isNotEmpty) {
                                calculation = calculation.substring(
                                    0, calculation.length - 1);
                              }
                            });
                          }),
                          _buildCalculatorButton('4', onPressed: () {
                            setModalState(() => calculation += '4');
                          }),
                          _buildCalculatorButton('5', onPressed: () {
                            setModalState(() => calculation += '5');
                          }),
                          _buildCalculatorButton('6', onPressed: () {
                            setModalState(() => calculation += '6');
                          }),
                          _buildCalculatorButton('C', onPressed: () {
                            setModalState(() => calculation = '');
                          }),
                          _buildCalculatorButton('1', onPressed: () {
                            setModalState(() => calculation += '1');
                          }),
                          _buildCalculatorButton('2', onPressed: () {
                            setModalState(() => calculation += '2');
                          }),
                          _buildCalculatorButton('3', onPressed: () {
                            setModalState(() => calculation += '3');
                          }),
                          _buildCalculatorButton('0', onPressed: () {
                            setModalState(() => calculation += '0');
                          }),
                        ],
                      ),
                      //   ],
                      // ),
                      // Add and Cancel buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (calculation.isNotEmpty &&
                                      selectedCategory != null) {
                                    try {
                                      double amount = double.parse(calculation);
                                      await _addExpense(
                                        selectedCategory!,
                                        amount,
                                        null,
                                      );
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Invalid amount')),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalculatorButton(
    String text, {
    bool isEquals = false,
    bool isOperator = false,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isEquals
              ? Colors.purple
              : isOperator
                  ? Colors.purple[50]
                  : Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isEquals ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> groupExpensesByDate() {
    final groupedExpenses = <String, List<Map<String, dynamic>>>{};

    for (var expense in expenses) {
      final date = DateTime.parse(expense['date']);
      final dateKey = "${date.day}/${date.month}/${date.year}";

      if (!groupedExpenses.containsKey(dateKey)) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(expense);
    }

    return groupedExpenses;
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
