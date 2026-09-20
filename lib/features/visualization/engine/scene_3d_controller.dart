import 'package:flutter/foundation.dart';
import 'design_configuration.dart';
import 'sun_simulation_controller.dart';
import 'camera_controller.dart';

class Scene3dController with ChangeNotifier {
  final DesignConfiguration designConfig;
  final SunSimulationController sunController;
  final Camera3dController cameraController;

  Scene3dController({
    DesignConfiguration? designConfig,
    SunSimulationController? sunController,
    Camera3dController? cameraController,
  })  : designConfig = designConfig ?? DesignConfiguration(),
        sunController = sunController ?? SunSimulationController(),
        cameraController = cameraController ?? Camera3dController() {
    this.designConfig.addListener(_onSubControllerUpdated);
    this.sunController.addListener(_onSubControllerUpdated);
    this.cameraController.addListener(_onSubControllerUpdated);
  }

  void _onSubControllerUpdated() {
    notifyListeners();
  }

  @override
  void dispose() {
    designConfig.removeListener(_onSubControllerUpdated);
    sunController.removeListener(_onSubControllerUpdated);
    cameraController.removeListener(_onSubControllerUpdated);
    super.dispose();
  }
}
