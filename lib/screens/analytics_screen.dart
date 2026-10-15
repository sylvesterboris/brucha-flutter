import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/order_model.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final history = app.orderHistory;

    // Aggregate data
    final Map<String, double> itemRevenue = {};
    final Map<int, int> hourCount = {};
    double totalRevenue = 0;
    int totalOrders = history.length;

    for (final order in history) {
      totalRevenue += order.total;
      final hour = order.createdAt.hour;
      hourCount[hour] = (hourCount[hour] ?? 0) + 1;
      for (final item in order.items) {
        itemRevenue[item.name] = (itemRevenue[item.name] ?? 0) + (item.price * item.quantity);
      }
    }

    final topItems = itemRevenue.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    final avgOrder = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    return Scaffold(
      backgroundColor: BruchaColors.parch,
      appBar: AppBar(
        backgroundColor: BruchaColors.ink,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: BruchaColors.gold2, size: 18), onPressed: () => Navigator.pop(context)),
        title: Text('Sales Dashboard', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ── Metric cards ───────────────────────────────────────────────────
        Row(children: [
          _MetricCard(label: 'Total Revenue', value: '₹${totalRevenue.toInt()}', icon: '💰'),
          const SizedBox(width: 10),
          _MetricCard(label: 'Total Orders', value: '$totalOrders', icon: '📋'),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _MetricCard(label: 'Avg Order', value: '₹${avgOrder.toInt()}', icon: '📊'),
          const SizedBox(width: 10),
          _MetricCard(label: 'Items Sold', value: '${history.fold(0, (s, o) => s + o.items.fold(0, (ss, i) => ss + i.quantity))}', icon: '🍽️'),
        ]),
        const SizedBox(height: 20),

        // ── Top items ──────────────────────────────────────────────────────
        Text('Top Selling Items', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
        const SizedBox(height: 12),
        if (topItems.isEmpty)
          _EmptyChart('No sales data yet')
        else
          Container(height: 200, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: BruchaColors.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: BruchaColors.parch3)),
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: topItems.first.value * 1.2,
              barGroups: topItems.take(5).toList().asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
                BarChartRodData(toY: e.value.value, color: BruchaColors.gold, width: 22, borderRadius: BorderRadius.circular(4)),
              ])).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= topItems.length) return const SizedBox.shrink();
                  final name = topItems[i].key.split(' ').first;
                  return Padding(padding: const EdgeInsets.only(top: 4), child: Text(name, style: GoogleFonts.jost(fontSize: 8, color: BruchaColors.ink3)));
                })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('₹${v.toInt()}', style: GoogleFonts.jost(fontSize: 8, color: BruchaColors.ink3)))),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(getDrawingHorizontalLine: (_) => FlLine(color: BruchaColors.parch3, strokeWidth: 1)),
              borderData: FlBorderData(show: false),
            )),
          ),
        const SizedBox(height: 20),

        // ── Orders by hour ─────────────────────────────────────────────────
        Text('Orders by Hour', style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
        const SizedBox(height: 12),
        if (hourCount.isEmpty)
          _EmptyChart('No time data yet')
        else
          Container(height: 160, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: BruchaColors.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: BruchaColors.parch3)),
            child: LineChart(LineChartData(
              gridData: FlGridData(getDrawingHorizontalLine: (_) => FlLine(color: BruchaColors.parch3, strokeWidth: 1)),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 3, getTitlesWidget: (v, _) => Text('${v.toInt()}h', style: GoogleFonts.jost(fontSize: 8, color: BruchaColors.ink3)))),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: GoogleFonts.jost(fontSize: 8, color: BruchaColors.ink3)))),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [LineChartBarData(
                spots: List.generate(24, (h) => FlSpot(h.toDouble(), (hourCount[h] ?? 0).toDouble())),
                isCurved: true,
                color: BruchaColors.gold,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: BruchaColors.gold.withOpacity(0.1)),
              )],
            )),
          ),
        const SizedBox(height: 20),

        // ── Item availability controls ──────────────────────────────────────
        const SectionHeader('Item Availability'),
        _AvailabilityPanel(),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, icon;
  const _MetricCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: BruchaColors.cream, border: Border.all(color: BruchaColors.parch3), borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 6),
      Text(label, style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3)),
      Text(value, style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
    ]),
  ));
}

class _EmptyChart extends StatelessWidget {
  final String msg;
  const _EmptyChart(this.msg);
  @override
  Widget build(BuildContext context) => Container(height: 80,
    decoration: BoxDecoration(color: BruchaColors.cream, border: Border.all(color: BruchaColors.parch3), borderRadius: BorderRadius.circular(12)),
    child: Center(child: Text(msg, style: GoogleFonts.jost(fontSize: 13, color: BruchaColors.ink3))));
}

class _AvailabilityPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Container(
      decoration: BoxDecoration(color: BruchaColors.cream, border: Border.all(color: BruchaColors.parch3), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(12),
          child: Text('Toggle to mark items sold out', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3))),
        Divider(color: BruchaColors.parch2, height: 1),
        ...List.generate(6, (i) {
          final item = kMenu[i];
          final avail = app.isAvailable(item.id);
          return Column(children: [
            ListTile(dense: true,
              leading: Text(item.emoji, style: const TextStyle(fontSize: 20)),
              title: Text(item.name, style: GoogleFonts.jost(fontSize: 13, fontWeight: FontWeight.w500, color: BruchaColors.ink)),
              subtitle: Text('₹${item.price.toInt()}', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3)),
              trailing: Switch(value: avail, onChanged: (_) => app.toggleAvailability(item.id), activeColor: BruchaColors.gold),
            ),
            if (i < 5) Divider(color: BruchaColors.parch2, height: 1, indent: 16, endIndent: 16),
          ]);
        }),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('+ ${kMenu.length - 6} more items available in full admin panel', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, fontStyle: FontStyle.italic))),
      ]),
    );
  }
}
