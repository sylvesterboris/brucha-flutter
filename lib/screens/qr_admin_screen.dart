import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class QrAdminScreen extends StatelessWidget {
  const QrAdminScreen({super.key});

  static const _baseUrl = 'https://brucha.cafe/menu?table=';
  static const _tableCount = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BruchaColors.parch,
      appBar: AppBar(
        backgroundColor: BruchaColors.ink,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: BruchaColors.gold2, size: 18), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('QR Codes', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2)),
          Text('Table Management', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, letterSpacing: 1.5)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/kitchen'),
            icon: Icon(Icons.restaurant_outlined, color: BruchaColors.gold2, size: 18),
            label: Text('Kitchen', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.gold2)),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
            icon: Icon(Icons.bar_chart_rounded, color: BruchaColors.gold2, size: 18),
            label: Text('Analytics', style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.gold2)),
          ),
        ],
      ),
      body: Column(children: [
        Container(color: BruchaColors.ink2, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(children: [
            Icon(Icons.info_outline, color: BruchaColors.gold, size: 14),
            const SizedBox(width: 8),
            Expanded(child: Text('Print and place each QR at the corresponding table. Guests scan to order directly.',
              style: GoogleFonts.jost(fontSize: 11, color: BruchaColors.ink3))),
          ])),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.82),
          itemCount: _tableCount,
          itemBuilder: (_, i) => _QrCard(tableNumber: '${i+1}', url: '$_baseUrl${i+1}'),
        )),
      ]),
    );
  }
}

class _QrCard extends StatelessWidget {
  final String tableNumber, url;
  const _QrCard({required this.tableNumber, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: BruchaColors.cream, border: Border.all(color: BruchaColors.parch3), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Text('TABLE', style: GoogleFonts.jost(fontSize: 9, color: BruchaColors.ink3, letterSpacing: 3)),
        Text(tableNumber, style: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.w600, color: BruchaColors.ink)),
        const OrnamentDivider(),
        const SizedBox(height: 4),
        QrImageView(
          data: url, version: QrVersions.auto, size: 110,
          backgroundColor: Colors.white,
          eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: BruchaColors.ink),
          dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: BruchaColors.ink),
        ),
        const SizedBox(height: 8),
        Text('Scan to order', style: GoogleFonts.jost(fontSize: 10, color: BruchaColors.ink3, letterSpacing: 0.5)),
      ]),
    );
  }
}
