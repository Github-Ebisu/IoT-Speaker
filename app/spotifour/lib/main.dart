import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'cloud_functions/auth_service.dart';
import 'firebase_options.dart';
import 'models/user.dart';
import 'ui/main_navigator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModels?>.value(
      value: AuthService().user,
      initialData: null,
      child: ToastificationWrapper(
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
            useMaterial3: true,
          ),
          home: const MainNavigator(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
