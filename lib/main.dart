import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'services/identity_service.dart';
import 'services/routing_service.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Request Network & Location permissions
  await [
    Permission.location,
    Permission.nearbyWifiDevices,
  ].request();

  // 2. Request to ignore battery optimization
  bool isOptimized = await OptimizeBattery.isIgnoringBatteryOptimizations();
  if (!isOptimized) {
    OptimizeBattery.stopOptimizingBatteryUsage();
  }

  // 3. Start Services
  await IdentityService.initialize();
  await RoutingService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SendTalk Mesh',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ChatScreen(),
    );
  }
}