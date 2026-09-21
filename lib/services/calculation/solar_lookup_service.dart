/// India-wide solar irradiation lookup table.
/// Values are average Global Horizontal Irradiance (GHI) in kWh/m²/day.
/// Source: based on MNRE/NIWE India Solar Atlas data.
/// No API or internet required — fully offline.
class SolarLookupService {
  SolarLookupService._();

  /// State-level average solar irradiation (kWh/m²/day)
  static const Map<String, double> _stateIrradiation = {
    // High solar zones (Rajasthan, Gujarat, MP)
    'rajasthan': 6.1,
    'gujarat': 5.9,
    'madhya pradesh': 5.6,
    'mp': 5.6,

    // Good solar zones
    'maharashtra': 5.4,
    'andhra pradesh': 5.5,
    'telangana': 5.5,
    'karnataka': 5.3,
    'tamil nadu': 5.6,
    'odisha': 5.1,
    'jharkhand': 5.0,
    'chhattisgarh': 5.2,

    // Moderate solar zones (North India)
    'uttar pradesh': 4.8,
    'up': 4.8,
    'haryana': 5.0,
    'punjab': 4.9,
    'delhi': 4.9,
    'uttarakhand': 4.6,
    'himachal pradesh': 4.5,
    'bihar': 4.8,
    'west bengal': 4.6,

    // Lower solar zones
    'assam': 4.2,
    'meghalaya': 3.9,
    'sikkim': 3.8,
    'nagaland': 4.0,
    'manipur': 4.1,
    'tripura': 4.3,
    'arunachal pradesh': 3.9,
    'mizoram': 4.0,
    'jammu & kashmir': 4.7,
    'j&k': 4.7,
    'ladakh': 5.5, // High altitude, excellent solar
    'goa': 5.0,
    'kerala': 4.8,
  };

  /// City/district-level overrides for common locations
  static const Map<String, double> _cityIrradiation = {
    // Uttar Pradesh districts
    'prayagraj': 4.9,
    'allahabad': 4.9,
    'varanasi': 4.8,
    'lucknow': 4.8,
    'agra': 5.0,
    'kanpur': 4.8,
    'mathura': 5.0,
    'meerut': 4.9,
    'phulpur': 4.9,
    'jhunsi': 4.9,
    'kaushambi': 4.9,
    'naini': 4.9,

    // Rajasthan
    'jaipur': 6.0,
    'jodhpur': 6.3,
    'udaipur': 5.9,
    'bikaner': 6.4,
    'jaisalmer': 6.5,

    // Gujarat
    'ahmedabad': 5.8,
    'surat': 5.7,
    'vadodara': 5.8,
    'bhavnagar': 5.9,

    // Maharashtra
    'pune': 5.5,
    'mumbai': 5.3,
    'nagpur': 5.5,
    'nashik': 5.4,
    'aurangabad': 5.4,

    // Punjab / Haryana
    'ludhiana': 4.9,
    'amritsar': 4.9,
    'chandigarh': 5.0,
    'gurugram': 5.0,
    'faridabad': 4.9,

    // Karnataka
    'bangalore': 5.4,
    'mysore': 5.3,
    'hubli': 5.4,
    'belgaum': 5.3,

    // Tamil Nadu
    'chennai': 5.5,
    'coimbatore': 5.7,
    'madurai': 5.8,
    'tirunelveli': 5.9,

    // Andhra Pradesh / Telangana
    'hyderabad': 5.5,
    'vizag': 5.3,
    'vijayawada': 5.4,
    'warangal': 5.4,

    // Madhya Pradesh
    'bhopal': 5.5,
    'indore': 5.6,
    'gwalior': 5.3,
    'jabalpur': 5.2,

    // Bihar
    'patna': 4.8,
    'gaya': 5.0,
    'muzaffarpur': 4.7,
  };

  /// Get solar irradiation for a given location string.
  /// Checks city name first, then falls back to state name, then returns default.
  static double getIrradiation(String location) {
    final lower = location.toLowerCase();

    // Check city-level first (more precise)
    for (final entry in _cityIrradiation.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fall back to state-level
    for (final entry in _stateIrradiation.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default: average Indian solar irradiation
    return 5.0;
  }

  /// Returns a human-readable solar zone label
  static String getSolarZoneLabel(double irradiation) {
    if (irradiation >= 6.0) return 'Excellent (Zone 1)';
    if (irradiation >= 5.5) return 'Very Good (Zone 2)';
    if (irradiation >= 5.0) return 'Good (Zone 3)';
    if (irradiation >= 4.5) return 'Moderate (Zone 4)';
    return 'Adequate (Zone 5)';
  }

  /// Crop shade tolerance values (0.0–1.0)
  static double getCropShadeTolerance(String crop) {
    final lower = crop.toLowerCase();
    if (lower.contains('wheat')) return 0.82;
    if (lower.contains('leafy') || lower.contains('spinach') || lower.contains('lettuce')) return 0.90;
    if (lower.contains('potato')) return 0.78;
    if (lower.contains('rice') || lower.contains('paddy')) return 0.72;
    if (lower.contains('mustard') || lower.contains('oilseed')) return 0.68;
    if (lower.contains('vegetable')) return 0.80;
    if (lower.contains('tomato')) return 0.75;
    if (lower.contains('brinjal') || lower.contains('eggplant')) return 0.73;
    if (lower.contains('onion') || lower.contains('garlic')) return 0.70;
    if (lower.contains('maize') || lower.contains('corn')) return 0.60;
    if (lower.contains('sunflower')) return 0.55;
    if (lower.contains('cotton')) return 0.58;
    if (lower.contains('sugarcane')) return 0.62;
    return 0.70; // default
  }

  /// Convert slope string to numeric %
  static double getSlopePercent(String slope) {
    final lower = slope.toLowerCase();
    if (lower.contains('2%') && lower.contains('5%')) return 3.5;
    if (lower.contains('< 2') || lower.contains('flat')) return 1.5;
    if (lower.contains('> 5') || lower.contains('moderate')) return 7.0;
    if (lower.contains('steep') || lower.contains('> 10')) return 12.0;
    // Try extracting a number
    final numMatch = RegExp(r'(\d+\.?\d*)').firstMatch(slope);
    if (numMatch != null) {
      return double.tryParse(numMatch.group(1) ?? '') ?? 2.0;
    }
    return 2.0;
  }

  /// Convert grid string to km
  static double getGridKm(String gridString) {
    final lower = gridString.toLowerCase();
    if (lower.contains('< 1')) return 0.8;
    if (lower.contains('> 5') || lower.contains('high')) return 6.0;
    if (lower.contains('3') && lower.contains('5')) return 4.0;
    final numMatch = RegExp(r'(\d+\.?\d*)').firstMatch(gridString);
    if (numMatch != null) {
      return double.tryParse(numMatch.group(1) ?? '') ?? 2.4;
    }
    return 2.4;
  }
}
