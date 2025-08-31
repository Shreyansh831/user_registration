import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CountryCodePickerWidget extends StatelessWidget {
  final Function(CountryCode) onChanged;
  final CountryCode initialSelection;

  const CountryCodePickerWidget({
    Key? key,
    required this.onChanged,
    required this.initialSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CountryCodePicker(
        onChanged: onChanged,
        initialSelection: initialSelection.code,
        favorite: const ['+1', '+44', '+91', '+86', '+81'],
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        textStyle: AppTheme.lightTheme.textTheme.bodyLarge,
        dialogTextStyle: AppTheme.lightTheme.textTheme.bodyMedium,
        searchStyle: AppTheme.lightTheme.textTheme.bodyMedium,
        dialogBackgroundColor: AppTheme.lightTheme.colorScheme.surface,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        boxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        searchDecoration: InputDecoration(
          hintText: 'Search country...',
          hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.h,
          ),
        ),
      ),
    );
  }
}
