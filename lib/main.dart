import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/note_storage_service.dart';
import 'theme/theme_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NoteStorageService.init();
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notesy',
      debugShowCheckedModeBanner: false,
      theme: themeData(),
      home: const SplashScreen(),
    );
  }
}
