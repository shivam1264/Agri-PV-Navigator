import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_pv_navigator/features/design/presentation/agri_pv_system_design_screen.dart';

void main() {
  // 200m x 200m square parcel around a Prayagraj-like coordinate
  final cLat = 25.4358;
  final cLng = 81.8463;
  const metersPerDegLat = 111320.0;
  final metersPerDegLng = metersPerDegLat * math.cos(cLat * math.pi / 180);
  final dLat = 200.0 / metersPerDegLat;
  final dLng = 200.0 / metersPerDegLng;

  List<List<double>> square() => [
        [cLat - dLat / 2, cLng - dLng / 2],
        [cLat - dLat / 2, cLng + dLng / 2],
        [cLat + dLat / 2, cLng + dLng / 2],
        [cLat + dLat / 2, cLng - dLng / 2],
      ];

  test('fits ~20 rows across a 200m parcel at 10m spacing', () {
    final layout = computeFieldRows(square(), 10.0, 40.0);
    expect(layout.rowCount, inInclusiveRange(18, 22));
    expect(layout.panelEstimate, greaterThan(0));
    for (final r in layout.rows) {
      final lats = r.map((c) => c[0]).toList();
      final lngs = r.map((c) => c[1]).toList();
      // Each band sits inside the parcel bounds
      expect(lats.reduce(math.min), greaterThanOrEqualTo(cLat - dLat / 2));
      expect(lats.reduce(math.max), lessThanOrEqualTo(cLat + dLat / 2));
      expect(lngs.reduce(math.min), greaterThanOrEqualTo(cLng - dLng / 2));
      expect(lngs.reduce(math.max), lessThanOrEqualTo(cLng + dLng / 2));
    }
  });

  test('no rows for degenerate or empty boundary', () {
    expect(computeFieldRows([], 10.0, 40.0).rowCount, 0);
    expect(
      computeFieldRows([
        [cLat, cLng],
        [cLat + dLat, cLng + dLng],
      ], 10.0, 40.0).rowCount,
      0,
    );
    final single = computeFieldRows(square(), 10.0, 0.0);
    expect(single.rowCount, 0);
    expect(single.panelEstimate, 0);
  });

  test('higher coverage changes nothing structurally but spaces bands thicker', () {
    final thin = computeFieldRows(square(), 10.0, 20.0);
    final thick = computeFieldRows(square(), 10.0, 80.0);
    expect(thin.rowCount, thick.rowCount);
    expect(thick.rows.first.first[1], thick.rows.first.first[1]);
  });
}