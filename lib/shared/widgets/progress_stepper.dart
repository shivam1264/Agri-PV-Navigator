import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep; // 1 to 5
  final void Function(int)? onStepTapped;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  static const List<String> stepLabels = [
    'Location',
    'Details',
    'Suitability',
    'Design',
    'Preview',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row of circles and connecting lines
          Row(
            children: List.generate(stepLabels.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connecting line
                final lineIndex = index ~/ 2;
                final isCompleted = (lineIndex + 1) < currentStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: isCompleted ? AppColors.primary : AppColors.border,
                  ),
                );
              } else {
                // Step circle
                final stepIndex = index ~/ 2;
                final stepNumber = stepIndex + 1;
                final isCompleted = stepNumber < currentStep;
                final isCurrent = stepNumber == currentStep;
                return GestureDetector(
                  onTap: onStepTapped != null ? () => onStepTapped!(stepNumber) : null,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primary
                          : isCurrent
                              ? AppColors.primary
                              : AppColors.surfaceSecondary,
                      border: Border.all(
                        color: isCompleted || isCurrent ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : Text(
                              '$stepNumber',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isCurrent ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 5),

          // Row of step labels
          Row(
            children: List.generate(stepLabels.length, (index) {
              final stepNumber = index + 1;
              final isCurrent = stepNumber == currentStep;
              final isCompleted = stepNumber < currentStep;
              return Expanded(
                child: Text(
                  stepLabels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 9.5,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent
                        ? AppColors.primary
                        : isCompleted
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
