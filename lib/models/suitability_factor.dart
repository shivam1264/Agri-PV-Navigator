import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SuitabilityFactor {
  final String id;
  final String name;
  final int score;
  final String metricValue;
  final String shortReason;
  final String fullAssessment;
  final String impact;
  final IconData icon;
  final Color accentColor;

  const SuitabilityFactor({
    required this.id,
    required this.name,
    required this.score,
    required this.metricValue,
    required this.shortReason,
    required this.fullAssessment,
    required this.impact,
    required this.icon,
    required this.accentColor,
  });

  String get assessmentLevel {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Moderate';
    return 'Challenging';
  }

  factory SuitabilityFactor.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? 'f1';
    IconData icon = Icons.wb_sunny_rounded;
    Color accent = AppColors.solar;

    if (id == 'f1') {
      icon = Icons.wb_sunny_rounded;
      accent = AppColors.solar;
    } else if (id == 'f2') {
      icon = Icons.landscape_rounded;
      accent = AppColors.slope;
    } else if (id == 'f3') {
      icon = Icons.grass_rounded;
      accent = AppColors.soil;
    } else if (id == 'f4') {
      icon = Icons.water_drop_rounded;
      accent = AppColors.water;
    } else if (id == 'f5') {
      icon = Icons.eco_rounded;
      accent = AppColors.primary;
    } else if (id == 'f6') {
      icon = Icons.electric_bolt_rounded;
      accent = AppColors.solar;
    }

    return SuitabilityFactor(
      id: id,
      name: json['name'] ?? 'Factor',
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 80,
      metricValue: json['metricValue'] ?? '',
      shortReason: json['shortReason'] ?? '',
      fullAssessment: json['fullAssessment'] ?? '',
      impact: json['impact'] ?? '',
      icon: icon,
      accentColor: accent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'metricValue': metricValue,
      'shortReason': shortReason,
      'fullAssessment': fullAssessment,
      'impact': impact,
    };
  }
}
