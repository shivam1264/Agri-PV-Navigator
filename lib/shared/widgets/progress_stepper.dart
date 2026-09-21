import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep; // 1 to 4
  final void Function(int)? onStepTapped;
  final List<String>? customLabels;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    this.onStepTapped,
    this.customLabels,
  });

  static const List<String> defaultStepLabels = [
    'Location',
    'Details',
    'Suitability',
    'Design',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeGreen = isDark ? const Color(0xFF00E676) : const Color(0xFF166534);
    final inactiveLine = isDark ? const Color(0xFF1E2B23) : const Color(0xFFE2E8F0);
    final inactiveCircle = isDark ? const Color(0xFF151D18) : const Color(0xFFF1F5F9);
    final inactiveBorder = isDark ? const Color(0xFF2B3A30) : const Color(0xFFCBD5E1);

    final labels = customLabels ?? defaultStepLabels;
    final totalSteps = labels.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? theme.dividerColor : const Color(0xFFE2E8F0), width: 1.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row of circles and connecting lines
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                // Connecting line
                final lineIndex = index ~/ 2;
                final isCompleted = (lineIndex + 1) < currentStep;
                return Expanded(
                  child: Container(
                    height: 2.5,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? activeGreen : inactiveLine,
                      borderRadius: BorderRadius.circular(2),
                    ),
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent
                          ? activeGreen
                          : inactiveCircle,
                      border: Border.all(
                        color: isCompleted || isCurrent
                            ? activeGreen
                            : inactiveBorder,
                        width: 1.5,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: activeGreen.withValues(alpha: 0.28),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: isDark ? const Color(0xFF031A0B) : Colors.white,
                            )
                          : Text(
                              '$stepNumber',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? (isDark ? const Color(0xFF031A0B) : Colors.white)
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                fontFamily: 'Inter',
                              ),
                            ),
                    ),
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 6),

          // Row of step labels
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCurrent = stepNumber == currentStep;
              final isCompleted = stepNumber < currentStep;

              return Expanded(
                child: GestureDetector(
                  onTap: onStepTapped != null ? () => onStepTapped!(stepNumber) : null,
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                      color: isCurrent
                          ? activeGreen
                          : isCompleted
                              ? (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155))
                              : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
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
