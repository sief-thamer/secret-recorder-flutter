import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'providers/recorder_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'services/native_bridge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  await NativeBridge.init();
  
  runApp(const SecretRecorderApp());
}

class SecretRecorderApp extends StatelessWidget {
  const SecretRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => RecorderProvider()),
      ],
      child: MaterialApp(
        title: 'Secret Recorder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4CAF50),
            secondary: Color(0xFF2196F3),
            surface: Color(0xFF1E1E1E),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
