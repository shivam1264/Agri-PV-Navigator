import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;
import 'design_configuration.dart';
import 'sun_simulation_controller.dart';

class Polygon3d {
  final List<v64.Vector3> vertices;
  final v64.Vector3 normal;
  final Color baseColor;
  final bool isPanel;
  final bool isShadow;
  final bool isMetallic;
  final bool isCrop;
  final bool isWater;
  final bool isGlass;
  double avgDepth = 0.0;

  Polygon3d({
    required this.vertices,
    required this.normal,
    required this.baseColor,
    this.isPanel = false,
    this.isShadow = false,
    this.isMetallic = false,
    this.isCrop = false,
    this.isWater = false,
    this.isGlass = false,
  });
}

class FarmModelController {
  static List<Polygon3d> buildSceneGeometry({
    required DesignConfiguration config,
    required SunSimulationController sun,
  }) {
    final List<Polygon3d> polygons = [];

    const double scale = 16.0;
    final double terrainWidth = 26.0 * scale;
    final double terrainLength = 30.0 * scale;
    final double halfW = terrainWidth / 2.0;
    final double halfL = terrainLength / 2.0;

    final sunShadowFactor = sun.groundShadowProjectionFactor;

    // -------------------------------------------------------------
    // 1. TERRAIN (Now rendered via Photorealistic Satellite Image in Viewport)
    // -------------------------------------------------------------
    // Generic solid polygons removed to reveal the satellite texture.

    // -------------------------------------------------------------
    // 2. ACCESS ROAD & IRRIGATION SYSTEM
    // -------------------------------------------------------------
    // Dirt Farm Track
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(-halfW * 0.98, 0.2, -halfL * 0.96),
        v64.Vector3(-halfW * 0.76, 0.2, -halfL * 0.96),
        v64.Vector3(-halfW * 0.76, 0.2, halfL * 0.96),
        v64.Vector3(-halfW * 0.98, 0.2, halfL * 0.96),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0xFF8D6E63), // Compacted dirt road
    ));

    // Irrigation Canal Basin & Water
    final canalX = halfW * 0.82;
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(canalX - 18.0, 0.1, -halfL * 0.92),
        v64.Vector3(canalX + 18.0, 0.1, -halfL * 0.92),
        v64.Vector3(canalX + 18.0, 0.1, halfL * 0.92),
        v64.Vector3(canalX - 18.0, 0.1, halfL * 0.92),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0xFF0288D1), // Shimmering water canal
      isWater: true,
    ));

    // Concrete Canal Embankment Edges
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(canalX - 22.0, 0.25, -halfL * 0.92),
        v64.Vector3(canalX - 18.0, 0.25, -halfL * 0.92),
        v64.Vector3(canalX - 18.0, 0.25, halfL * 0.92),
        v64.Vector3(canalX - 22.0, 0.25, halfL * 0.92),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0xFFB0BEC5), // Concrete lining
    ));

    // -------------------------------------------------------------
    // 3. SOLAR PANEL ARRAYS & HIGH-CLEARANCE STILTS
    // -------------------------------------------------------------
    final int rows = config.panelRows;
    final double rowPitch = config.rowSpacing * scale * 0.65;
    final double stiltH = config.panelHeight * scale * 0.85;
    final double tiltRad = config.panelTilt * math.pi / 180.0;
    final double panelW = 11.5 * scale;
    final double panelChord = 4.2 * scale;

    for (int r = 0; r < rows; r++) {
      final double rowZ = (r - (rows - 1) / 2.0) * rowPitch;

      // 4 Heavy-Duty Galvanized Stilts per row
      final pillarXPositions = [-panelW * 0.42, -panelW * 0.14, panelW * 0.14, panelW * 0.42];

      for (final px in pillarXPositions) {
        // Concrete Foundation Footing Block at ground level
        _addConcreteFooting(
          polygons: polygons,
          center: v64.Vector3(px, 0.0, rowZ),
          size: 7.0,
          height: 3.0,
        );

        // Vertical High-Strength Stilt Post
        _addVerticalPillar(
          polygons: polygons,
          center: v64.Vector3(px, 0.0, rowZ),
          height: stiltH,
          width: 3.2,
          color: const Color(0xFFECEFF1), // Galvanized steel
        );

        // Pillar Shadow
        _addPillarShadow(
          polygons: polygons,
          base: v64.Vector3(px, 0.0, rowZ),
          height: stiltH,
          shadowFactor: sunShadowFactor,
        );
      }

      // Diagonal Structural Cross-Bracing between outer stilts
      _addCrossBrace(
        polygons: polygons,
        p1: v64.Vector3(-panelW * 0.42, 0.0, rowZ),
        p2: v64.Vector3(-panelW * 0.14, stiltH * 0.85, rowZ),
      );
      _addCrossBrace(
        polygons: polygons,
        p1: v64.Vector3(panelW * 0.14, stiltH * 0.85, rowZ),
        p2: v64.Vector3(panelW * 0.42, 0.0, rowZ),
      );

      // Horizontal Torque Tube & Crossbeam
      _addHorizontalBeam(
        polygons: polygons,
        start: v64.Vector3(-panelW * 0.48, stiltH, rowZ),
        end: v64.Vector3(panelW * 0.48, stiltH, rowZ),
        thickness: 3.5,
        color: const Color(0xFFCFD8DC),
      );

      // 4 Individual High-Efficiency Monocrystalline Solar Module Tables
      final double halfChord = panelChord / 2.0;
      final double dy = math.sin(tiltRad) * halfChord;
      final double dz = math.cos(tiltRad) * halfChord;

      const int modulesPerRow = 4;
      final double moduleW = (panelW * 0.96) / modulesPerRow;

      for (int m = 0; m < modulesPerRow; m++) {
        final mLeftX = -panelW * 0.48 + m * moduleW + 2.0;
        final mRightX = mLeftX + moduleW - 4.0;

        final pTopLeft = v64.Vector3(mLeftX, stiltH + dy, rowZ - dz);
        final pTopRight = v64.Vector3(mRightX, stiltH + dy, rowZ - dz);
        final pBottomRight = v64.Vector3(mRightX, stiltH - dy, rowZ + dz);
        final pBottomLeft = v64.Vector3(mLeftX, stiltH - dy, rowZ + dz);

        final edge1 = pTopRight - pTopLeft;
        final edge2 = pBottomLeft - pTopLeft;
        final panelNormal = edge1.cross(edge2).normalized();

        // Monocrystalline Silicon Blue Panel Face
        polygons.add(Polygon3d(
          vertices: [pTopLeft, pTopRight, pBottomRight, pBottomLeft],
          normal: panelNormal,
          baseColor: const Color(0xFF1565C0), // Deep Solar Blue
          isPanel: true,
          isGlass: true,
        ));

        // Anodized Aluminum Perimeter Frame
        _addPanelFrame(
          polygons: polygons,
          tl: pTopLeft,
          tr: pTopRight,
          br: pBottomRight,
          bl: pBottomLeft,
          normal: panelNormal,
        );

        // Ground Shadow Cast by this module
        final sTopLeft = _projectToGround(pTopLeft, sunShadowFactor);
        final sTopRight = _projectToGround(pTopRight, sunShadowFactor);
        final sBottomRight = _projectToGround(pBottomRight, sunShadowFactor);
        final sBottomLeft = _projectToGround(pBottomLeft, sunShadowFactor);

        polygons.add(Polygon3d(
          vertices: [sTopLeft, sTopRight, sBottomRight, sBottomLeft],
          normal: v64.Vector3(0.0, 1.0, 0.0),
          baseColor: const Color(0x351F2A1E),
          isShadow: true,
        ));
      }

      // -------------------------------------------------------------
      // 4. HIGH-DENSITY 3D CROP CANOPIES UNDERNEATH
      // -------------------------------------------------------------
      _addDetailedCropRows(
        polygons: polygons,
        cropType: config.cropType,
        rowZ: rowZ,
        rowWidth: panelW * 0.96,
        rowPitch: rowPitch,
        scale: scale,
      );
    }

    // -------------------------------------------------------------
    // 5. SCALE OBJECTS: MINI TRACTOR & ELECTRICAL INVERTER SKID
    // -------------------------------------------------------------
    // Mini Farm Tractor parked on dirt road (Clearance reference)
    _addMiniTractor(
      polygons: polygons,
      position: v64.Vector3(-halfW * 0.86, 0.0, -halfL * 0.35),
      sunShadowFactor: sunShadowFactor,
    );

    // Inverter Skid Station on Field Edge
    _addInverterStation(
      polygons: polygons,
      position: v64.Vector3(-halfW * 0.86, 0.0, halfL * 0.40),
      sunShadowFactor: sunShadowFactor,
    );

    // -------------------------------------------------------------
    // 6. PERIMETER FENCE POSTS & SCENIC TREES
    // -------------------------------------------------------------
    _addPerimeterFence(polygons: polygons, halfW: halfW * 0.94, halfL: halfL * 0.94);

    final treeLocations = [
      v64.Vector3(-halfW * 0.88, 0.0, -halfL * 0.85),
      v64.Vector3(halfW * 0.85, 0.0, -halfL * 0.82),
      v64.Vector3(halfW * 0.88, 0.0, halfL * 0.78),
      v64.Vector3(-halfW * 0.88, 0.0, halfL * 0.82),
      v64.Vector3(halfW * 0.86, 0.0, 0.0),
    ];

    for (final loc in treeLocations) {
      _addRealisticTree(
        polygons: polygons,
        position: loc,
        height: 52.0,
        radius: 22.0,
        sunShadowFactor: sunShadowFactor,
      );
    }

    return polygons;
  }

  static v64.Vector3 _projectToGround(v64.Vector3 vertex, v64.Vector2 shadowFactor) {
    return v64.Vector3(
      vertex.x + vertex.y * shadowFactor.x,
      0.35,
      vertex.z + vertex.y * shadowFactor.y,
    );
  }

  static void _addConcreteFooting({
    required List<Polygon3d> polygons,
    required v64.Vector3 center,
    required double size,
    required double height,
  }) {
    final hs = size / 2.0;
    // Top pad
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(center.x - hs, height, center.z - hs),
        v64.Vector3(center.x + hs, height, center.z - hs),
        v64.Vector3(center.x + hs, height, center.z + hs),
        v64.Vector3(center.x - hs, height, center.z + hs),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0xFFB0BEC5),
    ));
    // Front face
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(center.x - hs, 0.0, center.z + hs),
        v64.Vector3(center.x + hs, 0.0, center.z + hs),
        v64.Vector3(center.x + hs, height, center.z + hs),
        v64.Vector3(center.x - hs, height, center.z + hs),
      ],
      normal: v64.Vector3(0.0, 0.0, 1.0),
      baseColor: const Color(0xFF90A4AE),
    ));
  }

  static void _addVerticalPillar({
    required List<Polygon3d> polygons,
    required v64.Vector3 center,
    required double height,
    required double width,
    required Color color,
  }) {
    final hw = width / 2.0;
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(center.x - hw, 0.0, center.z + hw),
        v64.Vector3(center.x + hw, 0.0, center.z + hw),
        v64.Vector3(center.x + hw, height, center.z + hw),
        v64.Vector3(center.x - hw, height, center.z + hw),
      ],
      normal: v64.Vector3(0.0, 0.0, 1.0),
      baseColor: color,
      isMetallic: true,
    ));
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(center.x + hw, 0.0, center.z + hw),
        v64.Vector3(center.x + hw, 0.0, center.z - hw),
        v64.Vector3(center.x + hw, height, center.z - hw),
        v64.Vector3(center.x + hw, height, center.z + hw),
      ],
      normal: v64.Vector3(1.0, 0.0, 0.0),
      baseColor: const Color(0xFFB0BEC5),
      isMetallic: true,
    ));
  }

  static void _addCrossBrace({
    required List<Polygon3d> polygons,
    required v64.Vector3 p1,
    required v64.Vector3 p2,
  }) {
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(p1.x - 0.8, p1.y, p1.z),
        v64.Vector3(p1.x + 0.8, p1.y, p1.z),
        v64.Vector3(p2.x + 0.8, p2.y, p2.z),
        v64.Vector3(p2.x - 0.8, p2.y, p2.z),
      ],
      normal: v64.Vector3(0.0, 0.0, 1.0),
      baseColor: const Color(0xFF90A4AE),
      isMetallic: true,
    ));
  }

  static void _addHorizontalBeam({
    required List<Polygon3d> polygons,
    required v64.Vector3 start,
    required v64.Vector3 end,
    required double thickness,
    required Color color,
  }) {
    final ht = thickness / 2.0;
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(start.x, start.y - ht, start.z),
        v64.Vector3(end.x, end.y - ht, end.z),
        v64.Vector3(end.x, end.y + ht, end.z),
        v64.Vector3(start.x, start.y + ht, start.z),
      ],
      normal: v64.Vector3(0.0, 0.0, 1.0),
      baseColor: color,
      isMetallic: true,
    ));
  }

  static void _addPanelFrame({
    required List<Polygon3d> polygons,
    required v64.Vector3 tl,
    required v64.Vector3 tr,
    required v64.Vector3 br,
    required v64.Vector3 bl,
    required v64.Vector3 normal,
  }) {
    polygons.add(Polygon3d(
      vertices: [tl, tr, tr + normal * 1.5, tl + normal * 1.5],
      normal: normal,
      baseColor: const Color(0xFFECEFF1),
      isMetallic: true,
    ));
  }

  static void _addPillarShadow({
    required List<Polygon3d> polygons,
    required v64.Vector3 base,
    required double height,
    required v64.Vector2 shadowFactor,
  }) {
    final tip = v64.Vector3(base.x, height, base.z);
    final projectedTip = _projectToGround(tip, shadowFactor);

    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(base.x - 1.8, 0.4, base.z),
        v64.Vector3(base.x + 1.8, 0.4, base.z),
        v64.Vector3(projectedTip.x + 1.8, 0.4, projectedTip.z),
        v64.Vector3(projectedTip.x - 1.8, 0.4, projectedTip.z),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0x301B261D),
      isShadow: true,
    ));
  }

  static void _addDetailedCropRows({
    required List<Polygon3d> polygons,
    required AgriCrop3dType cropType,
    required double rowZ,
    required double rowWidth,
    required double rowPitch,
    required double scale,
  }) {
    Color mainColor;
    Color highlightColor;
    double cropHeight;

    switch (cropType) {
      case AgriCrop3dType.wheat:
        mainColor = const Color(0xFFFFD54F); // Golden ripe wheat
        highlightColor = const Color(0xFFC0CA33); // Greenish stalk
        cropHeight = 13.0;
        break;
      case AgriCrop3dType.rice:
        mainColor = const Color(0xFF43A047); // Emerald paddy
        highlightColor = const Color(0xFF2E7D32);
        cropHeight = 10.0;
        break;
      case AgriCrop3dType.mustard:
        mainColor = const Color(0xFFFFEE58); // Vivid blooming yellow
        highlightColor = const Color(0xFF689F38);
        cropHeight = 16.0;
        break;
      case AgriCrop3dType.vegetables:
        mainColor = const Color(0xFF388E3C); // Lush garden plants
        highlightColor = const Color(0xFF1B5E20);
        cropHeight = 8.0;
        break;
    }

    final cropOffsets = [-rowPitch * 0.33, 0.0, rowPitch * 0.33];
    for (final off in cropOffsets) {
      final cz = rowZ + off;
      for (int i = -6; i <= 6; i++) {
        final cx = i * (rowWidth / 13.0);

        // Crop Clump Primary Fan
        polygons.add(Polygon3d(
          vertices: [
            v64.Vector3(cx - 6.0, 0.3, cz),
            v64.Vector3(cx + 6.0, 0.3, cz),
            v64.Vector3(cx + 3.5, cropHeight, cz),
            v64.Vector3(cx - 3.5, cropHeight, cz),
          ],
          normal: v64.Vector3(0.0, 0.0, 1.0),
          baseColor: mainColor,
          isCrop: true,
        ));

        // Crop Clump Cross Leaf
        polygons.add(Polygon3d(
          vertices: [
            v64.Vector3(cx, 0.3, cz - 6.0),
            v64.Vector3(cx, 0.3, cz + 6.0),
            v64.Vector3(cx, cropHeight, cz + 3.5),
            v64.Vector3(cx, cropHeight, cz - 3.5),
          ],
          normal: v64.Vector3(1.0, 0.0, 0.0),
          baseColor: highlightColor,
          isCrop: true,
        ));
      }
    }
  }

  static void _addMiniTractor({
    required List<Polygon3d> polygons,
    required v64.Vector3 position,
    required v64.Vector2 sunShadowFactor,
  }) {
    const double tw = 12.0;
    const double tl = 22.0;
    const double th = 11.0;

    // Red Tractor Body Hood
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(position.x - tw / 2, 4.0, position.z - tl / 2),
        v64.Vector3(position.x + tw / 2, 4.0, position.z - tl / 2),
        v64.Vector3(position.x + tw / 2, 4.0 + th, position.z - tl / 2),
        v64.Vector3(position.x - tw / 2, 4.0 + th, position.z - tl / 2),
      ],
      normal: v64.Vector3(0.0, 0.0, -1.0),
      baseColor: const Color(0xFFD32F2F), // Agricultural Red Tractor
    ));

    // Tractor Top Roof / Cabin
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(position.x - tw / 2, 4.0 + th, position.z - tl / 2),
        v64.Vector3(position.x + tw / 2, 4.0 + th, position.z - tl / 2),
        v64.Vector3(position.x + tw / 2, 4.0 + th, position.z + tl / 2),
        v64.Vector3(position.x - tw / 2, 4.0 + th, position.z + tl / 2),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0xFFC62828),
    ));

    // Tractor Wheels (Dark Rubber)
    final wheelPositions = [
      v64.Vector3(position.x - tw / 2 - 1.5, 0.0, position.z - tl / 3),
      v64.Vector3(position.x + tw / 2 + 1.5, 0.0, position.z - tl / 3),
      v64.Vector3(position.x - tw / 2 - 2.0, 0.0, position.z + tl / 3),
      v64.Vector3(position.x + tw / 2 + 2.0, 0.0, position.z + tl / 3),
    ];

    for (final wp in wheelPositions) {
      polygons.add(Polygon3d(
        vertices: [
          v64.Vector3(wp.x - 2.0, 0.0, wp.z - 4.0),
          v64.Vector3(wp.x + 2.0, 0.0, wp.z - 4.0),
          v64.Vector3(wp.x + 2.0, 7.0, wp.z + 4.0),
          v64.Vector3(wp.x - 2.0, 7.0, wp.z + 4.0),
        ],
        normal: v64.Vector3(1.0, 0.0, 0.0),
        baseColor: const Color(0xFF263238),
      ));
    }

    // Tractor Ground Shadow
    final trShadow = _projectToGround(
      v64.Vector3(position.x, 8.0, position.z),
      sunShadowFactor,
    );
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(trShadow.x - tw, 0.4, trShadow.z - tl / 2),
        v64.Vector3(trShadow.x + tw, 0.4, trShadow.z - tl / 2),
        v64.Vector3(trShadow.x + tw, 0.4, trShadow.z + tl / 2),
        v64.Vector3(trShadow.x - tw, 0.4, trShadow.z + tl / 2),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0x351F2A1E),
      isShadow: true,
    ));
  }

  static void _addInverterStation({
    required List<Polygon3d> polygons,
    required v64.Vector3 position,
    required v64.Vector2 sunShadowFactor,
  }) {
    // Inverter Skid Enclosure
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(position.x - 8.0, 0.0, position.z + 8.0),
        v64.Vector3(position.x + 8.0, 0.0, position.z + 8.0),
        v64.Vector3(position.x + 8.0, 14.0, position.z + 8.0),
        v64.Vector3(position.x - 8.0, 14.0, position.z + 8.0),
      ],
      normal: v64.Vector3(0.0, 0.0, 1.0),
      baseColor: const Color(0xFFECEFF1),
      isMetallic: true,
    ));

    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(position.x - 8.0, 14.0, position.z - 8.0),
        v64.Vector3(position.x + 8.0, 14.0, position.z - 8.0),
        v64.Vector3(position.x + 8.0, 14.0, position.z + 8.0),
        v64.Vector3(position.x - 8.0, 14.0, position.z + 8.0),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0xFFCFD8DC),
      isMetallic: true,
    ));
  }

  static void _addPerimeterFence({
    required List<Polygon3d> polygons,
    required double halfW,
    required double halfL,
  }) {
    final fencePosts = [
      v64.Vector3(-halfW, 0.0, -halfL),
      v64.Vector3(0.0, 0.0, -halfL),
      v64.Vector3(halfW, 0.0, -halfL),
      v64.Vector3(halfW, 0.0, 0.0),
      v64.Vector3(halfW, 0.0, halfL),
      v64.Vector3(0.0, 0.0, halfL),
      v64.Vector3(-halfW, 0.0, halfL),
      v64.Vector3(-halfW, 0.0, 0.0),
    ];

    for (final fp in fencePosts) {
      _addVerticalPillar(
        polygons: polygons,
        center: fp,
        height: 12.0,
        width: 2.2,
        color: const Color(0xFF8D6E63), // Wooden boundary fence post
      );
    }
  }

  static void _addRealisticTree({
    required List<Polygon3d> polygons,
    required v64.Vector3 position,
    required double height,
    required double radius,
    required v64.Vector2 sunShadowFactor,
  }) {
    // Tree Trunk
    _addVerticalPillar(
      polygons: polygons,
      center: position,
      height: height * 0.40,
      width: 5.5,
      color: const Color(0xFF4E342E),
    );

    // Multi-tier Foliage Layers
    final fBottom = position.y + height * 0.32;
    final fMid = position.y + height * 0.65;
    final fTop = position.y + height;

    // Layer 1
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(position.x - radius, fBottom, position.z),
        v64.Vector3(position.x + radius, fBottom, position.z),
        v64.Vector3(position.x + radius * 0.6, fMid, position.z),
        v64.Vector3(position.x - radius * 0.6, fMid, position.z),
      ],
      normal: v64.Vector3(0.0, 0.0, 1.0),
      baseColor: const Color(0xFF2E7D32),
      isCrop: true,
    ));

    // Layer 2
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(position.x, fBottom, position.z - radius),
        v64.Vector3(position.x, fBottom, position.z + radius),
        v64.Vector3(position.x, fMid, position.z + radius * 0.6),
        v64.Vector3(position.x, fMid, position.z - radius * 0.6),
      ],
      normal: v64.Vector3(1.0, 0.0, 0.0),
      baseColor: const Color(0xFF1B5E20),
      isCrop: true,
    ));

    // Crown
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(position.x - radius * 0.65, fMid, position.z),
        v64.Vector3(position.x + radius * 0.65, fMid, position.z),
        v64.Vector3(position.x, fTop, position.z),
      ],
      normal: v64.Vector3(0.0, 0.0, 1.0),
      baseColor: const Color(0xFF43A047),
      isCrop: true,
    ));

    // Tree Ground Shadow
    final treeShadowCenter = _projectToGround(
      v64.Vector3(position.x, height * 0.55, position.z),
      sunShadowFactor,
    );
    polygons.add(Polygon3d(
      vertices: [
        v64.Vector3(treeShadowCenter.x - radius * 0.85, 0.4, treeShadowCenter.z - radius * 0.85),
        v64.Vector3(treeShadowCenter.x + radius * 0.85, 0.4, treeShadowCenter.z - radius * 0.85),
        v64.Vector3(treeShadowCenter.x + radius * 0.85, 0.4, treeShadowCenter.z + radius * 0.85),
        v64.Vector3(treeShadowCenter.x - radius * 0.85, 0.4, treeShadowCenter.z + radius * 0.85),
      ],
      normal: v64.Vector3(0.0, 1.0, 0.0),
      baseColor: const Color(0x301B261D),
      isShadow: true,
    ));
  }
}
