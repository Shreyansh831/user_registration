import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final String password;

  const PasswordStrengthWidget({
    Key? key,
    required this.password,
  }) : super(key: key);

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Password Strength: ',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                strength.label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: strength.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),

          // Strength indicator bars
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 1.w : 0),
                  decoration: BoxDecoration(
                    color: index < strength.level
                        ? strength.color
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),

          // Password requirements
          if (strength != PasswordStrength.strong) ...[
            SizedBox(height: 1.h),
            Text(
              'Password should contain:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            _buildRequirement('At least 8 characters', password.length >= 8),
            _buildRequirement(
                'Uppercase letter', password.contains(RegExp(r'[A-Z]'))),
            _buildRequirement(
                'Lowercase letter', password.contains(RegExp(r'[a-z]'))),
            _buildRequirement('Number', password.contains(RegExp(r'[0-9]'))),
            _buildRequirement('Special character',
                password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isMet ? 'check_circle' : 'radio_button_unchecked',
            color: isMet
                ? AppTheme.lightTheme.colorScheme.tertiary
                : AppTheme.lightTheme.colorScheme.outline,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isMet
                  ? AppTheme.lightTheme.colorScheme.tertiary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

enum PasswordStrength {
  none(0, 'None', Colors.transparent),
  weak(1, 'Weak', Color(0xFFDC2626)),
  medium(2, 'Medium', Color(0xFFD97706)),
  strong(3, 'Strong', Color(0xFF059669));

  const PasswordStrength(this.level, this.label, this.color);

  final int level;
  final String label;
  final Color color;
}
