import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const CNITApp());

class CNITApp extends StatefulWidget { const CNITApp({super.key});
  @override State<CNITApp> createState()=>_CNITAppState(); }

class _CNITAppState extends State<CNITApp>{
  ThemeMode _mode = ThemeMode.light;
  void _toggle(bool dark){ setState(()=> _mode = dark? ThemeMode.dark : ThemeMode.light); }

  @override Widget build(BuildContext context){
    return MaterialApp(
      title: 'CNIT Activities',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue, brightness: Brightness.dark),
      themeMode: _mode,
      home: SplashScreen(onThemeToggle: _toggle),
    );
  }
}
