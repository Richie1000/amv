import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/routes/routes.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/followup_provider.dart';
import 'providers/history_provider.dart';
import 'providers/promotion_provider.dart';
import 'providers/request_provider.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => FollowupProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
      ],
      child: const RouteFlowApp(),
    ),
  );
}

class RouteFlowApp extends StatelessWidget {
  const RouteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RouteFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: createRouter(context),
    );
  }
}
