import 'package:billing_app/firebase_options.dart';
import 'package:billing_app/services/auth/auth_gate.dart';
import 'package:billing_app/services/data/goods.dart';
import 'package:billing_app/theme/theme_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => Goods())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Billing App',
        theme: MyAppTheme.lightTheme,
        darkTheme: MyAppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: AuthGate(),
      ),
    );
  }
}
