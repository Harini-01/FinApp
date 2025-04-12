import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  // Remove goal controller and add fixed expenses list
  List<Map<String, dynamic>> _fixedExpenses = [];
  List<String> _defaultCategories = [
    'Food',
    'Rent',
    'Transport',
    'Utilities',
    'Internet'
  ];
  TextEditingController _customCategoryController = TextEditingController();
  TextEditingController _expenseAmountController = TextEditingController();

  Map<String, bool> _editingStates = {
    'name': false,
    'age': false,
    'income': false,
  };

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await AuthService.getProfile(userId: widget.userId);

      if (!mounted) return;

      setState(() {
        _nameController.text = response['profile']['name'] ?? '';
        _ageController.text = response['profile']['age']?.toString() ?? '';
        _incomeController.text =
            response['profile']['monthlyIncome']?.toString() ?? '';

        // Load fixed expenses
        if (response['profile']['fixedExpenses'] != null) {
          final Map<String, dynamic> expenses =
              response['profile']['fixedExpenses'];
          _fixedExpenses = expenses.entries
              .map((e) => {'category': e.key, 'amount': e.value})
              .toList();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _nameController.dispose(); // Changed from _usernameController
    _ageController.dispose();
    _incomeController.dispose();
    _customCategoryController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView to prevent overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                // Profile content
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 144, 198, 243),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Profile picture
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.person_outline,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildEditableField('Name', _nameController, 'name'),
                        const SizedBox(height: 12),
                        _buildEditableField('Age', _ageController, 'age',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildEditableField(
                            'Monthly Income', _incomeController, 'income',
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 20),
                        _buildFixedExpensesSection(),
                      ],
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

  Widget _buildEditableField(
      String label, TextEditingController controller, String fieldKey,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: _editingStates[fieldKey] == true
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? 'Not set' : controller.text,
                    style: TextStyle(
                      color:
                          controller.text.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(
              _editingStates[fieldKey] == true ? Icons.check : Icons.edit,
              color: Colors.purple,
            ),
            onPressed: () async {
              if (_editingStates[fieldKey] == true) {
                await _updateField(fieldKey); // Update immediately when ticking
              }
              setState(() {
                _editingStates[fieldKey] = !_editingStates[fieldKey]!;
              });
            },
          ),
        ],
      ),
    );
  }

  // Remove _buildInputField method as it's no longer needed

  Widget _buildNavBarItem(IconData icon, {bool isSelected = false}) {
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.green,
      ),
      onPressed: () {},
    );
  }

  // Modify fixed expenses section to show summary first
  Widget _buildFixedExpensesSection() {
    double totalExpenses = _fixedExpenses.fold(
        0, (sum, expense) => sum + (expense['amount'] as num));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Expenses Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fixed Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '₹$totalExpenses',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showFixedExpensesDialog(),
                child: const Text('View/Edit Details'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Add this method to show detailed fixed expenses dialog
  void _showFixedExpensesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fixed Expenses'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // List existing expenses
              ..._fixedExpenses.map((expense) => ListTile(
                    title: Text(expense['category']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${expense['amount']}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            setState(() {
                              _fixedExpenses.remove(expense);
                            });
                            await _updateField(
                                'fixedExpenses'); // Only update fixed expenses
                            Navigator.pop(context);
                            _showFixedExpensesDialog();
                          },
                        ),
                      ],
                    ),
                  )),

              // Add new expense button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddExpenseDialog();
                },
                child: const Text('Add New Expense'),
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

  // Add this method to show add expense dialog
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fixed Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [..._defaultCategories, 'Custom']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              if (_selectedCategory == 'Custom')
                TextField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Enter custom category',
                  ),
                ),
              TextField(
                controller: _expenseAmountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final category = _selectedCategory == 'Custom'
                  ? _customCategoryController.text
                  : _selectedCategory;
              final amount = double.tryParse(_expenseAmountController.text);

              if (category != null && amount != null) {
                setState(() {
                  _fixedExpenses.add({
                    'category': category,
                    'amount': amount,
                  });
                  _selectedCategory = null;
                  _expenseAmountController.clear();
                  _customCategoryController.clear();
                });
                await _updateField(
                    'fixedExpenses'); // Only update fixed expenses
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(String fieldKey) async {
    try {
      Map<String, dynamic> updateData = {};

      // Only update the specific field that changed
      switch (fieldKey) {
        case 'name':
          updateData['name'] = _nameController.text;
          break;
        case 'age':
          updateData['age'] = int.tryParse(_ageController.text);
          break;
        case 'income':
          updateData['monthlyIncome'] = double.tryParse(_incomeController.text);
          break;
        case 'fixedExpenses':
          // Convert fixed expenses list to map
          final Map<String, dynamic> fixedExpensesMap = {};
          for (var expense in _fixedExpenses) {
            fixedExpensesMap[expense['category']] = expense['amount'];
          }
          updateData['fixedExpenses'] = fixedExpensesMap;
          break;
      }

      if (updateData.isEmpty) return;

      final response = await AuthService.updateProfile(
        userId: widget.userId,
        data: updateData,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }
}
