import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  // Ensure that plugin services are initialized prior to runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const ClearBreezeApp());
}
