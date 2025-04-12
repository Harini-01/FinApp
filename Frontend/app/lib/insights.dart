import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({Key? key}) : super(key: key);

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final List<MonthlyExpense> monthlyExpenses = [
    MonthlyExpense(month: 'May', amount: 750, color: Colors.purple.shade100),
    MonthlyExpense(month: 'June', amount: 900, color: Colors.blue.shade200),
    MonthlyExpense(month: 'July', amount: 1200, color: Colors.green.shade200),
    MonthlyExpense(month: 'Aug', amount: 1000, color: Colors.blue.shade300),
    MonthlyExpense(month: 'Sept', amount: 850, color: Colors.red.shade100),
  ];

  final List<List<int>> heatmapData = [
    [3, 5, 7, 9, 5, 3, 8],
    [4, 6, 8, 5, 7, 9, 4],
    [9, 5, 3, 6, 8, 4, 7],
    [5, 7, 9, 4, 3, 6, 8],
    [6, 8, 4, 7, 9, 5, 3],
    [3, 5, 7, 9, 4, 6, 8],
  ];

  final List<String> daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.home, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Monthly Expense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 1500,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '\$${monthlyExpenses[groupIndex].amount}',
                                    const TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value >= 0 &&
                                        value < monthlyExpenses.length) {
                                      return Text(
                                        monthlyExpenses[value.toInt()].month,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            barGroups: List.generate(
                              monthlyExpenses.length,
                              (index) => BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: monthlyExpenses[index]
                                        .amount
                                        .toDouble(),
                                    color: monthlyExpenses[index].color,
                                    width: 25,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Expense Discipline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F3D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: daysOfWeek
                                  .map((day) => Expanded(
                                        child: Center(
                                          child: Text(
                                            day,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: List.generate(
                                heatmapData.length,
                                (rowIndex) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: List.generate(
                                      7,
                                      (colIndex) {
                                        final score =
                                            heatmapData[rowIndex][colIndex];
                                        Color dotColor;
                                        if (score <= 3) {
                                          dotColor = const Color.fromARGB(
                                              255, 150, 236, 194);
                                        } else if (score <= 6) {
                                          dotColor = const Color.fromARGB(
                                              255, 83, 231, 150);
                                        } else {
                                          dotColor = const Color.fromARGB(
                                              255, 44, 152, 48);
                                        }
                                        return Expanded(
                                          child: Center(
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: dotColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 8, // horizontal spacing
                        runSpacing: 8, // vertical spacing between rows
                        alignment: WrapAlignment.start,
                        children: [
                          _buildLegendItem(
                            const Color.fromARGB(255, 150, 236, 194),
                            'Overspent',
                          ),
                          _buildLegendItem(
                            const Color.fromARGB(255, 83, 231, 150),
                            'Close to budget',
                          ),
                          _buildLegendItem(
                            const Color.fromARGB(255, 44, 152, 48),
                            'Within budget',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Today's Smart Tip by Finora",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Always check your fridge before ordering in—leftovers save both cash and effort',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber.shade800,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.person_outline),
            _buildNavBarItem(Icons.currency_exchange, selected: true),
            _buildNavBarItem(Icons.do_not_disturb),
            _buildNavBarItem(Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildNavBarItem(IconData icon, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? Colors.teal.shade200 : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: selected ? Colors.teal.shade700 : Colors.grey,
        size: 28,
      ),
    );
  }
}

class MonthlyExpense {
  final String month;
  final double amount;
  final Color color;

  MonthlyExpense(
      {required this.month, required this.amount, required this.color});
}
