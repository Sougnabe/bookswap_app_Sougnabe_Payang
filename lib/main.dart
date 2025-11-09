import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/firebase_options.dart';
import 'package:bookswap_app/services/auth_service.dart';
import 'package:bookswap_app/services/firestore_service.dart';
import 'package:bookswap_app/services/storage_service.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/providers/book_provider.dart';
import 'package:bookswap_app/providers/swap_provider.dart';
import 'package:bookswap_app/providers/chat_provider.dart';
import 'package:bookswap_app/screens/auth/login_screen.dart';
import 'package:bookswap_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BookSwapApp());
}

class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
          )..initialize(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BookProvider>(
          create: (context) => BookProvider(
            context.read<FirestoreService>(),
            context.read<StorageService>(),
          ),
          update: (context, authProvider, bookProvider) {
            if (authProvider.user != null) {
              bookProvider?.initialize(authProvider.user!.id);
            }
            return bookProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SwapProvider>(
          create: (context) => SwapProvider(
            context.read<FirestoreService>(),
          ),
          update: (context, authProvider, swapProvider) {
            if (authProvider.user != null) {
              swapProvider?.initialize(authProvider.user!.id);
            }
            return swapProvider!;
          },
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(
            context.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (authProvider.user == null) {
              return const LoginScreen();
            }
            
            return HomeScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}