import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../screens/reports_screen.dart';
import '../../../core/utils/money_utils.dart';

class ReportChart extends StatelessWidget {
  final List<ChartData> data;
  final ReportPeriod period;
  
  const ReportChart({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(),
                  barGroups: _getBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: _leftTitles,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: _bottomTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  double _getMaxValue() {
    if (data.isEmpty) return 100;
    final maxPay = data.map((e) => e.totalPay).reduce((a, b) => a > b ? a : b);
    return (maxPay * 1.2).ceilToDouble();
  }
  
  List<BarChartGroupData> _getBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalPay.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
  
  Widget _leftTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 10,
      color: Colors.grey.shade600,
    );
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        MoneyUtils.formatCurrency(value.toInt()),
        style: style,
      ),
    );
  }
  
  Widget _bottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontSize: 10,
      color: Colors.grey.shade600,
    );
    
    final index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const SizedBox.shrink();
    }
    
    String label = data[index].label;
    if (period == ReportPeriod.weekly) {
      label = label.substring(0, 3);
    } else if (period == ReportPeriod.monthly) {
      // Show day numbers
    } else if (period == ReportPeriod.yearly) {
      // Show month abbreviations
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        label,
        style: style,
      ),
    );
  }
}