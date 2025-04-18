import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _settingsBox;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = await Hive.openBox('app_settings');
    setState(() {
      _isDarkMode = _settingsBox.get('darkMode', defaultValue: false);
    });
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      _settingsBox.put('darkMode', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Modo Escuro'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre o App'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sobre o App'),
                    content: const Text(
                      'Catálogo de Produtos v1.0\n\n'
                      'Desenvolvido para gerenciar produtos e gerar PDFs personalizados.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fechar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 