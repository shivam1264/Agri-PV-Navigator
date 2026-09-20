import 'package:flutter/foundation.dart';

enum AgriCrop3dType {
  wheat('Wheat (Kharif/Rabi)', 'Golden stalks with awns', 0.8),
  rice('Paddy Rice', 'Lush green flooded rows', 0.6),
  mustard('Mustard', 'Yellow flowering canopies', 1.0),
  vegetables('Horticulture Vegetables', 'Raised crop beds & green shrubs', 0.5);

  final String label;
  final String description;
  final double matureHeightM;
  const AgriCrop3dType(this.label, this.description, this.matureHeightM);
}

class DesignConfiguration with ChangeNotifier {
  double _panelTilt; // 0° to 45°
  double _panelHeight; // 1.5m to 5.0m
  double _rowSpacing; // 3.0m to 12.0m
  double _orientation; // 90° (East) to 270° (West), default 180° (South)
  int _panelRows; // 2 to 6 rows
  AgriCrop3dType _cropType;
  double _farmSizeAcres;

  DesignConfiguration({
    double panelTilt = 20.0,
    double panelHeight = 3.5,
    double rowSpacing = 6.0,
    double orientation = 180.0,
    int panelRows = 3,
    AgriCrop3dType cropType = AgriCrop3dType.wheat,
    double farmSizeAcres = 2.35,
  })  : _panelTilt = panelTilt,
        _panelHeight = panelHeight,
        _rowSpacing = rowSpacing,
        _orientation = orientation,
        _panelRows = panelRows,
        _cropType = cropType,
        _farmSizeAcres = farmSizeAcres;

  double get panelTilt => _panelTilt;
  set panelTilt(double value) {
    if (_panelTilt != value) {
      _panelTilt = value.clamp(0.0, 45.0);
      notifyListeners();
    }
  }

  double get panelHeight => _panelHeight;
  set panelHeight(double value) {
    if (_panelHeight != value) {
      _panelHeight = value.clamp(1.5, 5.0);
      notifyListeners();
    }
  }

  double get rowSpacing => _rowSpacing;
  set rowSpacing(double value) {
    if (_rowSpacing != value) {
      _rowSpacing = value.clamp(3.0, 12.0);
      notifyListeners();
    }
  }

  double get orientation => _orientation;
  set orientation(double value) {
    if (_orientation != value) {
      _orientation = value.clamp(90.0, 270.0);
      notifyListeners();
    }
  }

  int get panelRows => _panelRows;
  set panelRows(int value) {
    if (_panelRows != value) {
      _panelRows = value.clamp(2, 6);
      notifyListeners();
    }
  }

  AgriCrop3dType get cropType => _cropType;
  set cropType(AgriCrop3dType value) {
    if (_cropType != value) {
      _cropType = value;
      notifyListeners();
    }
  }

  double get farmSizeAcres => _farmSizeAcres;
  set farmSizeAcres(double value) {
    if (_farmSizeAcres != value) {
      _farmSizeAcres = value.clamp(0.5, 10.0);
      notifyListeners();
    }
  }

  void resetToDefaults() {
    _panelTilt = 20.0;
    _panelHeight = 3.5;
    _rowSpacing = 6.0;
    _orientation = 180.0;
    _panelRows = 3;
    _cropType = AgriCrop3dType.wheat;
    _farmSizeAcres = 2.35;
    notifyListeners();
  }
}
