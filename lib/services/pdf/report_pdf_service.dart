import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../models/farm.dart';
import '../../models/agri_pv_design.dart';

class ReportPdfService {
  ReportPdfService._();

  static Future<String> generateProposalReport({
    required Farm farm,
    required AgriPvDesign design,
  }) async {
    final pdf = pw.Document(
      title: 'Agri-PV Proposal — ${farm.name}',
      author: 'Agri-PV Navigator',
    );

    // ─── Page 1: Cover Page ─────────────────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.Container(
          color: PdfColor.fromHex('#0F4C2A'),
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(48),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo area
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#16A34A'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text(
                    'AGRI-PV NAVIGATOR',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'Agri-PV System',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#86EFAC'),
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Proposal Report',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  height: 3,
                  width: 80,
                  color: PdfColor.fromHex('#22C55E'),
                ),
                pw.SizedBox(height: 24),
                pw.Row(
                  children: [
                    _infoChip('Farm', farm.name),
                    pw.SizedBox(width: 12),
                    _infoChip('Location', farm.location),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    _infoChip('Area', '${farm.areaAcres.toStringAsFixed(2)} acres'),
                    pw.SizedBox(width: 12),
                    _infoChip('Crop', farm.crop),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColor.fromHex('#166534'), thickness: 1),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Prepared by Agri-PV Navigator',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#86EFAC'),
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      _formatDate(DateTime.now()),
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#86EFAC'),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // ─── Page 2: Farm Summary + Suitability ─────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pageHeader('Farm Summary & Site Assessment'),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Farm Information'),
                      pw.SizedBox(height: 8),
                      _tableRow('Farm Name', farm.name),
                      _tableRow('Location', farm.location),
                      _tableRow('State', farm.state),
                      _tableRow('Total Area', '${farm.areaAcres.toStringAsFixed(2)} acres'),
                      _tableRow('Primary Crop', farm.crop),
                      _tableRow('Land Use', farm.currentLandUse),
                    ],
                  ),
                ),
                pw.SizedBox(width: 24),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Agronomic Data'),
                      pw.SizedBox(height: 8),
                      _tableRow('Soil Type', farm.soilType),
                      _tableRow('Land Slope', farm.slope),
                      _tableRow('Irrigation', farm.irrigation),
                      _tableRow('Grid Proximity', '${farm.gridProximityKm.toStringAsFixed(1)} km'),
                      _tableRow('Suitability Score', '${farm.suitabilityScore}/100'),
                      _tableRow('Status', farm.suitabilityLabel),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 28),
            _sectionLabel('Suitability Score Breakdown'),
            pw.SizedBox(height: 10),
            _scoreBar('Solar Resource', farm.suitabilityScore > 75 ? 85 : 65),
            _scoreBar('Land Slope', farm.suitabilityScore > 75 ? 90 : 70),
            _scoreBar('Soil Type', farm.suitabilityScore > 75 ? 82 : 62),
            _scoreBar('Water Availability', farm.suitabilityScore > 75 ? 78 : 58),
            _scoreBar('Crop Shade Tolerance', farm.suitabilityScore > 75 ? 80 : 60),
            _scoreBar('Grid Proximity', farm.suitabilityScore > 75 ? 85 : 65),
          ],
        ),
      ),
    );

    // ─── Page 3: System Design ───────────────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pageHeader('Agri-PV System Design Parameters'),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Structural Configuration'),
                      pw.SizedBox(height: 8),
                      _tableRow('Design Name', design.name),
                      _tableRow('Mounting Type', design.mountingType.label),
                      _tableRow('Panel Tilt', '${design.tiltDegrees.toInt()}°'),
                      _tableRow('Orientation', design.orientation.label),
                      _tableRow('Row Spacing', '${design.rowSpacingMeters.toStringAsFixed(1)} m'),
                      _tableRow('Panel Coverage', '${design.panelCoveragePercent.toStringAsFixed(0)}%'),
                      _tableRow('Panel Height', '${design.panelHeightMeters.toStringAsFixed(1)} m'),
                    ],
                  ),
                ),
                pw.SizedBox(width: 24),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Performance Metrics'),
                      pw.SizedBox(height: 8),
                      _tableRow('PV Capacity', '${design.pvCapacityKw.toStringAsFixed(1)} kW'),
                      _tableRow('Annual Energy', '${design.annualEnergyMwh.toStringAsFixed(1)} MWh/yr'),
                      _tableRow('Cultivable Area', '${design.cultivableAreaPercent.toStringAsFixed(1)}%'),
                      _tableRow('Crop Yield Impact', '${design.cropYieldPercent.toStringAsFixed(1)}%'),
                      _tableRow('Land Eq. Ratio', design.landEquivalentRatio.toStringAsFixed(2)),
                      _tableRow('Ground DLI', '${design.dliMolM2Day.toStringAsFixed(1)} mol/m²/day'),
                      _tableRow('Water Saved', '${(design.waterSavedLiters / 1000).toStringAsFixed(0)} kL/yr'),
                      _tableRow('Machinery', design.clearanceStatus),
                      _tableRow('CO₂ Saved', '${design.co2SavedTons.toStringAsFixed(0)} T/yr'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 28),
            // LER highlight box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F0FDF4'),
                border: pw.Border.all(color: PdfColor.fromHex('#22C55E'), width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Land Equivalent Ratio (LER) = ${design.landEquivalentRatio.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#166534'),
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'An LER > 1.0 means the Agri-PV system produces more combined output '
                          '(solar + crops) than growing crops or generating solar alone on the same land.',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#166534'),
                            fontSize: 9,
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
      ),
    );

    // ─── Page 4: Financial Projections ──────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pageHeader('Financial Projections (25-Year Analysis)'),
            pw.SizedBox(height: 20),
            // Summary cards row
            pw.Row(
              children: [
                _financialCard('Project Cost', '₹${design.projectCostCr.toStringAsFixed(2)} Cr', '#0F4C2A'),
                pw.SizedBox(width: 10),
                _financialCard('Annual Revenue', '₹${(design.pvCapacityKw * 0.05).toStringAsFixed(1)} L/yr', '#166534'),
                pw.SizedBox(width: 10),
                _financialCard('Payback Period', '${design.paybackYears.toStringAsFixed(1)} Years', '#15803D'),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                _financialCard('Net Present Value', '₹${design.npvLakhs.toStringAsFixed(1)} L', '#16A34A'),
                pw.SizedBox(width: 10),
                _financialCard('Project IRR', '${design.irrPercent.toStringAsFixed(1)}%', '#22C55E'),
                pw.SizedBox(width: 10),
                _financialCard('LCOE', '₹${design.lcoePerKwh.toStringAsFixed(2)}/kWh', '#15803D'),
              ],
            ),
            pw.SizedBox(height: 24),
            _sectionLabel('Cost Breakdown'),
            pw.SizedBox(height: 10),
            _tableRow('PV Modules (poly/mono)', '45%'),
            _tableRow('Elevated Steel Structures', '26%'),
            _tableRow('Inverters & Transformers', '14%'),
            _tableRow('Installation & Grid Interconnection', '15%'),
            _tableRow('LCOE (Levelized Cost of Energy)', '₹${design.lcoePerKwh.toStringAsFixed(2)} / kWh'),
            pw.SizedBox(height: 20),
            _sectionLabel('Revenue Streams'),
            pw.SizedBox(height: 10),
            _tableRow('Feed-in Energy Revenue (@ ₹3.15/kWh)', '76%'),
            _tableRow('Crop Sale Harvest (Annual)', '24%'),
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              color: PdfColor.fromHex('#F8FAFC'),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Assumptions',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '• Specific yield: 1,580 kWh/kWp/year (with 2.5% microclimate cooling bonus)\n'
                    '• Module degradation: 0.5% per year over 25-year project life\n'
                    '• PPA/FiT tariff: ₹3.15/kWh (domestic off-take or DISCOM)\n'
                    '• Discount rate: 8% for NPV computation\n'
                    '• Grid emission factor: 0.82 kg CO₂/kWh (India CEA 2023-24)',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // ─── Page 5: Environmental Impact ───────────────────────────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pageHeader('Environmental & Social Impact'),
            pw.SizedBox(height: 20),
            _sectionLabel('25-Year Cumulative Impact'),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                _impactStat(
                  '${(design.annualEnergyMwh * 25).toStringAsFixed(0)} MWh',
                  'Clean Energy Generated',
                ),
                pw.SizedBox(width: 12),
                _impactStat(
                  '${(design.co2SavedTons * 25).toStringAsFixed(0)} T',
                  'CO₂ Emissions Avoided',
                ),
                pw.SizedBox(width: 12),
                _impactStat(
                  '${design.landEquivalentRatio.toStringAsFixed(2)}x',
                  'Land Productivity Ratio',
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            _sectionLabel('SDG Alignment'),
            pw.SizedBox(height: 10),
            _tableRow('SDG 2 — Zero Hunger', 'Maintains ${design.cropYieldPercent.toStringAsFixed(0)}% crop yield'),
            _tableRow('SDG 7 — Clean Energy', '${design.pvCapacityKw.toStringAsFixed(0)} kW clean solar capacity'),
            _tableRow('SDG 13 — Climate Action', '${design.co2SavedTons.toStringAsFixed(0)} tons CO₂ offset annually'),
            _tableRow('SDG 15 — Life on Land', 'Dual land use preserves agricultural biodiversity'),
            pw.SizedBox(height: 24),
            _sectionLabel('Recommendations'),
            pw.SizedBox(height: 10),
            pw.Text(
              '1. Elevated stilt mounting (${design.panelHeightMeters.toStringAsFixed(1)} m) recommended for tractor clearance.\n'
              '2. South orientation at ${design.tiltDegrees.toInt()}° tilt maximizes annual solar irradiance.\n'
              '3. Maintain ${design.rowSpacingMeters.toStringAsFixed(0)} m row spacing for optimal sunlight penetration.\n'
              '4. Schedule bi-monthly panel washing to maintain >95% energy yield.\n'
              '5. Apply for PM-KUSUM (Component C) subsidy to reduce CAPEX by 30-40%.',
              style: pw.TextStyle(fontSize: 9, lineSpacing: 4, color: PdfColors.grey800),
            ),
            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 6),
            pw.Text(
              'This report was generated by Agri-PV Navigator. All projections are estimates based on '
              'standard agrivoltaic engineering formulas and regional solar data. Consult a certified '
              'energy engineer before final investment decisions.',
              style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );

    // ─── Save to documents directory ─────────────────────────────────────────
    final bytes = await pdf.save();

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: 'AgriPV_Proposal_${farm.name.replaceAll(' ', '_')}.pdf');
      return 'web_download';
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final sanitizedName = farm.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final path = '${dir.path}/AgriPV_Proposal_$sanitizedName.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }

  // ─── Helper Widgets ───────────────────────────────────────────────────────

  static pw.Widget _pageHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#0F4C2A'),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 2, width: 60, color: PdfColor.fromHex('#22C55E')),
      ],
    );
  }

  static pw.Widget _sectionLabel(String label) {
    return pw.Text(
      label,
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#166534'),
      ),
    );
  }

  static pw.Widget _tableRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 160,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoChip(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#166534'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(color: PdfColor.fromHex('#86EFAC'), fontSize: 7)),
          pw.Text(value, style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _scoreBar(String label, int score) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 130,
            child: pw.Text(label, style: pw.TextStyle(fontSize: 8)),
          ),
          pw.Expanded(
            child: pw.Stack(
              children: [
                pw.Container(height: 8, color: PdfColor.fromHex('#F1F5F9')),
                pw.Container(
                  height: 8,
                  width: score * 1.5,
                  color: score >= 80
                      ? PdfColor.fromHex('#22C55E')
                      : score >= 60
                          ? PdfColor.fromHex('#F59E0B')
                          : PdfColor.fromHex('#EF4444'),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text('$score', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _financialCard(String label, String value, String hexColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex(hexColor),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(label,
              style: pw.TextStyle(
                color: PdfColor.fromHex('#BBF7D0'),
                fontSize: 7.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _impactStat(String value, String label) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#22C55E'), width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F4C2A'),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
