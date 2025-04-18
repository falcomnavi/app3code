import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/product_form.dart';
import 'screens/product_list.dart';
import 'screens/template_editor_screen.dart';
import 'screens/image_gallery_screen.dart';
import 'utils/calculator.dart';
import 'providers/product_provider.dart';
import 'providers/template_provider.dart';
import 'theme/app_theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:math_expressions/math_expressions.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);
  
  // Abre as caixas necessárias
  await Hive.openBox('produtos');
  await Hive.openBox('templates');
  await Hive.openBox('configuracoes');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Produtos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/product_form': (context) => ProductForm(),
        '/product_list': (context) => const ProductList(),
        '/template_editor': (context) => const TemplateEditorScreen(),
        '/image_gallery': (context) => const ImageGalleryScreen(),
        '/calculator': (context) => const CalculatorScreen(),

      },
    );
  }
}
