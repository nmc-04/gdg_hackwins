import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  runApp(const MedDonationApp());
}

class MedDonationApp extends StatelessWidget {
  const MedDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareMyMeds',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: LoginScreen.routeName,
      routes: AppRoutes.routes,
      builder: (context, child) {
        // Prevent text scaling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true, 
            textScaler: TextScaler.linear(1.0),
          ),
          child: GestureDetector(
            onTap: () {
              // Hide keyboard when tapping outside
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild?.unfocus();
              }
            },
            child: child!,
          ),
        );
      },
    );
  }
}