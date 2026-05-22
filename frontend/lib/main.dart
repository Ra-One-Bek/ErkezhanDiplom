import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'ui/navigation/app_router.dart';
import 'ui/theme/app_theme.dart';
import 'viewmodels/history_viewmodel.dart';
import 'viewmodels/image_selection_viewmodel.dart';
import 'viewmodels/classification_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ImageSelectionViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassificationViewModel(),
        ),
      ],
      child: const PlantDiseaseApp(),
    ),
  );
}

class PlantDiseaseApp extends StatelessWidget {
  const PlantDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Plant Disease Classifier',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
    );
  }
}