import 'package:flutter_test/flutter_test.dart';
import 'package:agri_pv_navigator/features/farms/presentation/my_farms_screen.dart';
import 'package:agri_pv_navigator/models/farm.dart';

void main() {
  final farms = [
    Farm(id: '1', name: 'Wheat Farm A', areaAcres: 2.35, crop: 'Wheat', location: 'Prayagraj', state: 'Uttar Pradesh', suitabilityScore: 85, soilType: 'Loamy'),
    Farm(id: '2', name: 'Rice Paddy', areaAcres: 5.0, crop: 'Rice', location: 'Varanasi', state: 'Uttar Pradesh', suitabilityScore: 55, soilType: 'Sandy'),
    Farm(id: '3', name: 'Maize Field', areaAcres: 1.2, crop: 'Maize', location: 'Patna', state: 'Bihar', suitabilityScore: 70, soilType: 'Clay'),
    Farm(id: '4', name: 'Wheat Farm B', areaAcres: 3.0, crop: 'Wheat', location: 'Kanpur', state: 'Uttar Pradesh', suitabilityScore: 90, soilType: 'Loamy'),
  ];

  List<String> ids(List<Farm> list) => [for (final f in list) f.id];

  test('search matches name/location/crop', () {
    expect(ids(filterAndSortFarms(farms, query: 'wheat')), ['1', '4']);
    expect(ids(filterAndSortFarms(farms, query: 'patna')), ['3']);
    expect(ids(filterAndSortFarms(farms, query: 'maize')), ['3']);
    expect(filterAndSortFarms(farms, query: 'zzz'), isEmpty);
  });

  test('dimension filters narrow correctly', () {
    expect(ids(filterAndSortFarms(farms, crop: 'Rice')), ['2']);
    expect(ids(filterAndSortFarms(farms, soil: 'Loamy')), ['1', '4']);
    expect(ids(filterAndSortFarms(farms, state: 'Bihar')), ['3']);
    expect(ids(filterAndSortFarms(farms, suitability: 'Moderately Suitable')), ['3']);
    expect(ids(filterAndSortFarms(farms, suitability: 'Marginal')), ['2']);
  });

  test('search combines with filters', () {
    expect(ids(filterAndSortFarms(farms, query: 'wheat', soil: 'Sandy')), isEmpty);
    expect(ids(filterAndSortFarms(farms, query: 'wheat', soil: 'Loamy')), ['1', '4']);
  });

  test('all sort orders', () {
    expect(ids(filterAndSortFarms(farms, sort: FarmSort.newest)), ['1', '2', '3', '4']);
    expect(ids(filterAndSortFarms(farms, sort: FarmSort.areaDesc)).first, '2');
    expect(ids(filterAndSortFarms(farms, sort: FarmSort.areaAsc)).first, '3');
    expect(ids(filterAndSortFarms(farms, sort: FarmSort.scoreDesc)).first, '4');
    expect(ids(filterAndSortFarms(farms, sort: FarmSort.nameAsc)).first, '3');
  });
}