import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connectivity_banner_widget.dart';
import './widgets/country_code_picker_widget.dart';
import './widgets/form_field_widget.dart';
import './widgets/form_header_widget.dart';
import './widgets/password_strength_widget.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isConnected = true;
  CountryCode _selectedCountryCode = CountryCode.fromCode('US');
  DateTime? _selectedDate;

  // Validation errors
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _dobError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Connectivity
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Progress calculation
  double get _formProgress {
    int filledFields = 0;
    if (_fullNameController.text.isNotEmpty) filledFields++;
    if (_emailController.text.isNotEmpty) filledFields++;
    if (_phoneController.text.isNotEmpty) filledFields++;
    if (_dobController.text.isNotEmpty) filledFields++;
    if (_passwordController.text.isNotEmpty) filledFields++;
    if (_confirmPasswordController.text.isNotEmpty) filledFields++;
    return filledFields / 6.0;
  }

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _setupFieldListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      },
    );
  }

  void _setupFieldListeners() {
    _fullNameController.addListener(() {
      _validateFullName();
      setState(() {});
    });

    _emailController.addListener(() {
      _validateEmail();
      setState(() {});
    });

    _phoneController.addListener(() {
      _validatePhone();
      setState(() {});
    });

    _passwordController.addListener(() {
      _validatePassword();
      setState(() {});
    });

    _confirmPasswordController.addListener(() {
      _validateConfirmPassword();
      setState(() {});
    });
  }

  void _validateFullName() {
    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      _fullNameError = 'Full name is required';
    } else if (name.length < 2) {
      _fullNameError = 'Name must be at least 2 characters';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      _fullNameError = 'Name can only contain letters and spaces';
    } else {
      _fullNameError = null;
    }
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _emailError = 'Please enter a valid email address';
    } else {
      _emailError = null;
    }
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
    } else if (phone.length < 10) {
      _phoneError = 'Phone number must be at least 10 digits';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _phoneError = 'Phone number can only contain digits';
    } else {
      _phoneError = null;
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      _passwordError = 'Password is required';
    } else if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
    } else {
      _passwordError = null;
    }
  }

  void _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
    } else if (confirmPassword != _passwordController.text) {
      _confirmPasswordError = 'Passwords do not match';
    } else {
      _confirmPasswordError = null;
    }
  }

  void _validateDateOfBirth() {
    if (_selectedDate == null) {
      _dobError = 'Date of birth is required';
    } else {
      final age = DateTime.now().difference(_selectedDate!).inDays / 365;
      if (age < 13) {
        _dobError = 'You must be at least 13 years old';
      } else if (age > 120) {
        _dobError = 'Please enter a valid date of birth';
      } else {
        _dobError = null;
      }
    }
  }

  bool get _isFormValid {
    return _fullNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _dobError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate:
          DateTime.now().subtract(const Duration(days: 43800)), // 120 years ago
      lastDate:
          DateTime.now().subtract(const Duration(days: 4745)), // 13 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
      _validateDateOfBirth();
    }
  }

  Future<void> _submitForm() async {
    if (!_isConnected) {
      Fluttertoast.showToast(
        msg: 'No internet connection. Please check your network.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
      return;
    }

    // Validate all fields
    _validateFullName();
    _validateEmail();
    _validatePhone();
    _validateDateOfBirth();
    _validatePassword();
    _validateConfirmPassword();

    if (!_isFormValid) {
      setState(() {});
      return;
    }

    // Show confirmation dialog
    final bool? confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare registration data
      final registrationData = {
        'FullName': _fullNameController.text.trim(),
        'Email': _emailController.text.trim(),
        'PhoneNumber':
            '${_selectedCountryCode.dialCode}${_phoneController.text.trim()}',
        'DateOfBirth': _selectedDate!.toIso8601String(),
        'Password': _passwordController.text,
        'CountryCode': _selectedCountryCode.code,
        'RegistrationDate': DateTime.now().toIso8601String(),
      };

      // Mock SAP OData service call
      final dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer mock_token_for_sap_integration',
      };

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful response
      final response = await dio.post(
        'https://mock-sap-odata-service.com/ZCDS_C_TEST_REGISTER_NEW_CDS',
        data: registrationData,
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Registration',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to create an account with the provided information?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    // Haptic feedback
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Success!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
        content: Text(
          'Your account has been created successfully. Welcome aboard!',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    String userFriendlyMessage = 'Registration failed. Please try again.';

    if (error.contains('network') || error.contains('connection')) {
      userFriendlyMessage =
          'Network error. Please check your connection and try again.';
    } else if (error.contains('email')) {
      userFriendlyMessage = 'This email address is already registered.';
    } else if (error.contains('validation')) {
      userFriendlyMessage = 'Please check your information and try again.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Registration Failed',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          userFriendlyMessage,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dobController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    setState(() {
      _selectedDate = null;
      _selectedCountryCode = CountryCode.fromCode('US');
      _fullNameError = null;
      _emailError = null;
      _phoneError = null;
      _dobError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  Future<void> _refreshForm() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Form',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to clear all form data?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Connectivity Banner
            ConnectivityBannerWidget(isConnected: _isConnected),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshForm,
                color: AppTheme.lightTheme.primaryColor,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Header with progress
                        FormHeaderWidget(progressValue: _formProgress),

                        // Form Fields
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            children: [
                              // Full Name
                              FormFieldWidget(
                                label: 'Full Name',
                                hint: 'Enter your full name',
                                controller: _fullNameController,
                                keyboardType: TextInputType.name,
                                isRequired: true,
                                errorText: _fullNameError,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z\s]')),
                                ],
                              ),
                              SizedBox(height: 3.h),

                              // Email
                              FormFieldWidget(
                                label: 'Email Address',
                                hint: 'Enter your email address',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                isRequired: true,
                                errorText: _emailError,
                              ),
                              SizedBox(height: 3.h),

                              // Phone Number
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Phone Number',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        '*',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      // Country Code Picker
                                      SizedBox(
                                        width: 30.w,
                                        child: CountryCodePickerWidget(
                                          initialSelection:
                                              _selectedCountryCode,
                                          onChanged: (countryCode) {
                                            setState(() {
                                              _selectedCountryCode =
                                                  countryCode;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 2.w),

                                      // Phone Number Field
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyLarge,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                15),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: 'Phone number',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                              vertical: 2.h,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.outline,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.outline,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme
                                                    .lightTheme.primaryColor,
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.error,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_phoneError != null &&
                                      _phoneError!.isNotEmpty) ...[
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      _phoneError!,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 3.h),

                              // Date of Birth
                              FormFieldWidget(
                                label: 'Date of Birth',
                                hint: 'MM/DD/YYYY',
                                controller: _dobController,
                                isRequired: true,
                                readOnly: true,
                                errorText: _dobError,
                                onTap: _selectDate,
                                suffixIcon: CustomIconWidget(
                                  iconName: 'calendar_today',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              SizedBox(height: 3.h),

                              // Password
                              FormFieldWidget(
                                label: 'Password',
                                hint: 'Create a strong password',
                                controller: _passwordController,
                                isRequired: true,
                                obscureText: !_isPasswordVisible,
                                errorText: _passwordError,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  child: CustomIconWidget(
                                    iconName: _isPasswordVisible
                                        ? 'visibility_off'
                                        : 'visibility',
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                              ),

                              // Password Strength Indicator
                              PasswordStrengthWidget(
                                  password: _passwordController.text),
                              SizedBox(height: 3.h),

                              // Confirm Password
                              FormFieldWidget(
                                label: 'Confirm Password',
                                hint: 'Re-enter your password',
                                controller: _confirmPasswordController,
                                isRequired: true,
                                obscureText: !_isConfirmPasswordVisible,
                                errorText: _confirmPasswordError,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                  child: CustomIconWidget(
                                    iconName: _isConfirmPasswordVisible
                                        ? 'visibility_off'
                                        : 'visibility',
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 6.h,
                                child: ElevatedButton(
                                  onPressed: _isFormValid && !_isLoading
                                      ? _submitForm
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid
                                        ? AppTheme.lightTheme.primaryColor
                                        : AppTheme
                                            .lightTheme.colorScheme.outline
                                            .withValues(alpha: 0.3),
                                    foregroundColor: _isFormValid
                                        ? AppTheme
                                            .lightTheme.colorScheme.onPrimary
                                        : AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                    elevation: _isFormValid ? 2 : 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppTheme.lightTheme.colorScheme
                                                  .onPrimary,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Create Account',
                                          style: AppTheme
                                              .lightTheme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _isFormValid
                                                ? AppTheme.lightTheme
                                                    .colorScheme.onPrimary
                                                : AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 2.h),

                              // Security Notice
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: AppTheme
                                      .lightTheme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'security',
                                      color: AppTheme.lightTheme.primaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Text(
                                        'Your data is encrypted and secure. We comply with industry standards for data protection.',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}