import 'package:flutter/material.dart';
import '../presentation/registration_form_screen/registration_form_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String registrationForm = '/registration-form-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const RegistrationFormScreen(),
    registrationForm: (context) => const RegistrationFormScreen(),
    // TODO: Add your other routes here
  };
}
