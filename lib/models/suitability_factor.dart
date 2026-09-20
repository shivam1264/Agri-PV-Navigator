import 'package:flutter/material.dart';

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
}
