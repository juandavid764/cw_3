import 'package:mr_croc/database/db_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mr_croc/screens/homescreen.dart';

const String supabaseUrl =
    String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Crea DB
  await initializeDatabase();
  await _initSupabase();
  await getRoots();
  await gerDateNow();
  await getcategoriesdata();
  await getproductsdata();
  await getAdditionesData();
  runApp(const MyApp());
}

Future<void> _initSupabase() async {
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    return;
  }
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      //Ejecuta la primer pantalla
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreeen(),
      },
    );
  }
}

final ThemeData darkTheme = ThemeData(
  colorSchemeSeed: const Color.fromARGB(255, 255, 230, 0),
  useMaterial3: true,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Roboto',

  //Estilos del card
  cardTheme: CardThemeData(
    color: const Color.fromARGB(255, 197, 197, 0), // Color de fondo de las Card
    elevation: 2, // ElevaciÃ³n de la sombra
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Bordes redondeados
    ),
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
        overlayColor: WidgetStatePropertyAll(Colors.amberAccent),
        backgroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 197, 197, 0),
        ),
        foregroundColor: WidgetStatePropertyAll(Colors.black87)),
  ),

  //Estilos Text
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(
      fontSize: 16,
      color: Colors.black87,
      fontWeight: FontWeight.normal,
    ),
  ),
);
