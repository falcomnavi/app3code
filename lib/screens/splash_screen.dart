import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  List<String> _logs = [];
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _addLog('Iniciando aplicativo...');
    await Future.delayed(const Duration(milliseconds: 500));

    _addLog('Inicializando Hive...');
    await Hive.initFlutter();
    await Future.delayed(const Duration(milliseconds: 500));

    _addLog('Abrindo boxes...');
    await Hive.openBox('produtos');
    await Hive.openBox('template_settings');
    await Future.delayed(const Duration(milliseconds: 500));

    _addLog('Carregando configurações...');
    await Future.delayed(const Duration(milliseconds: 500));

    _addLog('Aplicativo pronto!');
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().split('.').first} - $message');
      if (_logs.length > 5) {
        _logs.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Gerenciador de Produtos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300,
                height: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _logs[index],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
