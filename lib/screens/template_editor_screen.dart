import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';

class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  Color _textColor = Colors.black;  
  final _templateBox = Hive.box('templates');
  final List<Map<String, dynamic>> _presets = [];
  String _currentPresetName = '';
  final _imagePicker = ImagePicker();
  
  // Configurações atuais
  Color corFundoImagem = Colors.orange;
  Color corTexto = Colors.white;
  double tamanhoFonte = 14.0;
  bool imagemEsquerda = true;
  String? fontePersonalizadaPath;
  double espacamentoProdutos = 16.0;
  double raioBorda = 8.0;
  bool mostrarDataGeracao = true;
  bool mostrarContato = true;
  String contato = '(XX) XXXX-XXXX';
  bool gradienteAtivo = true;
  Color corFundoPDF = Colors.white;
  double margemPagina = 20.0;
  String? logoPath;
  String? fonteSelecionada = 'Roboto';
  bool mostrarLogo = true;
  double tamanhoLogo = 100.0;
  bool mostrarPreco = true;
  bool mostrarCategoria = true;
  bool mostrarInformacoes = true;
  final _formKey = GlobalKey<FormState>();
  String? _logoPath;
  String _fontFamily = 'Roboto';
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.grey;
  bool _showPrice = true;
  bool _showCategory = true;
  bool _showInfo = true;
  bool _showCode = true;
  String _layoutStyle = 'grid';
  int _columns = 2;
  double _imageSize = 1.0;
  bool _showGradient = false;
  Color _gradientStart = Colors.blue;
  Color _gradientEnd = Colors.lightBlue;
  String _gradientDirection = 'horizontal';
  bool _showBorder = true;
  Color _borderColor = Colors.grey;
  double _borderRadius = 8.0;
  bool _showShadow = true;
  double _shadowOpacity = 0.3;
  bool _showWatermark = false;
  String? _watermarkText;
  Color _watermarkColor = Colors.grey.withOpacity(0.3);
  bool _showFooter = true;
  String _footerText = 'Contato: (11) 99999-9999';
  bool _showHeader = true;
  String _headerText = 'Catálogo de Produtos';
  bool _showPageNumbers = true;
  String _pageNumberFormat = 'Página {current} de {total}';
  bool _showQRCode = false;
  String? _qrCodeData;
  bool _showTable = false;
  List<String> _tableColumns = ['Nome', 'Preço', 'Categoria'];
  bool _showImageBackground = false;
  String? _backgroundImagePath;
  double _backgroundOpacity = 0.1;
  bool _showCustomFont = false;
  String? _customFontPath;
  bool _showCustomStyle = false;
  Map<String, dynamic> _customStyles = {};

  @override
  void initState() {
    super.initState();
    _loadPresets();
    _loadSettings();
  }

  void _loadPresets() {
    setState(() {
      _presets.clear();
      _presets.addAll(_templateBox.values.map((e) => Map<String, dynamic>.from(e)));
    });
  }

  void _savePreset() {
    if (_currentPresetName.isNotEmpty) {
      final preset = {
        'name': _currentPresetName,
        'corFundoImagem': corFundoImagem.value,
        'corTexto': corTexto.value,
        'tamanhoFonte': tamanhoFonte,
        'imagemEsquerda': imagemEsquerda,
        'fontePersonalizadaPath': fontePersonalizadaPath,
        'espacamentoProdutos': espacamentoProdutos,
        'raioBorda': raioBorda,
        'mostrarDataGeracao': mostrarDataGeracao,
        'mostrarContato': mostrarContato,
        'contato': contato,
        'gradienteAtivo': gradienteAtivo,
        'corFundoPDF': corFundoPDF.value,
        'margemPagina': margemPagina,
        'logoPath': logoPath,
        'fonteSelecionada': fonteSelecionada,
        'mostrarLogo': mostrarLogo,
        'tamanhoLogo': tamanhoLogo,
        'mostrarPreco': mostrarPreco,
        'mostrarCategoria': mostrarCategoria,
        'mostrarInformacoes': mostrarInformacoes,
      };
      _templateBox.put(_currentPresetName, preset);
      _loadPresets();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preset $_currentPresetName salvo com sucesso!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _loadPreset(String name) {
    final preset = _templateBox.get(name);
    if (preset != null) {
      setState(() {
        _currentPresetName = name;
        corFundoImagem = Color(preset['corFundoImagem'] ?? Colors.orange.value);
        corTexto = Color(preset['corTexto'] ?? Colors.white.value);
        tamanhoFonte = preset['tamanhoFonte'] ?? 14.0;
        imagemEsquerda = preset['imagemEsquerda'] ?? true;
        fontePersonalizadaPath = preset['fontePersonalizadaPath'];
        espacamentoProdutos = preset['espacamentoProdutos'] ?? 16.0;
        raioBorda = preset['raioBorda'] ?? 8.0;
        mostrarDataGeracao = preset['mostrarDataGeracao'] ?? true;
        mostrarContato = preset['mostrarContato'] ?? true;
        contato = preset['contato'] ?? '(XX) XXXX-XXXX';
        gradienteAtivo = preset['gradienteAtivo'] ?? true;
        corFundoPDF = Color(preset['corFundoPDF'] ?? Colors.white.value);
        margemPagina = preset['margemPagina'] ?? 20.0;
        logoPath = preset['logoPath'];
        fonteSelecionada = preset['fonteSelecionada'] ?? 'Roboto';
        mostrarLogo = preset['mostrarLogo'] ?? true;
        tamanhoLogo = preset['tamanhoLogo'] ?? 100.0;
        mostrarPreco = preset['mostrarPreco'] ?? true;
        mostrarCategoria = preset['mostrarCategoria'] ?? true;
        mostrarInformacoes = preset['mostrarInformacoes'] ?? true;
      });
    }
  }

  void _deletePreset(String name) {
    _templateBox.delete(name);
    _loadPresets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset $name excluído com sucesso!'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  Future<void> _pickLogo() async {
    final result = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() {
        logoPath = result.path;
      });
    }
  }

  Future<void> _pickFont() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );
    if (result != null) {
      setState(() {
        fontePersonalizadaPath = result.files.single.path;
      });
    }
  }

  void _showColorPicker(String title, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSettings() async {
    final box = Hive.box('template_settings');
    setState(() {
      _logoPath = box.get('logoPath');
      _fontFamily = box.get('fontFamily', defaultValue: 'Roboto');
      _primaryColor = Color(box.get('primaryColor', defaultValue: Colors.blue.value));
      _secondaryColor = Color(box.get('secondaryColor', defaultValue: Colors.grey.value));
      _textColor = Color(box.get('textColor', defaultValue: Colors.black.value));
      _showPrice = box.get('showPrice', defaultValue: true);
      _showCategory = box.get('showCategory', defaultValue: true);
      _showInfo = box.get('showInfo', defaultValue: true);
      _showCode = box.get('showCode', defaultValue: true);
      _layoutStyle = box.get('layoutStyle', defaultValue: 'grid');
      _columns = box.get('columns', defaultValue: 2);
      _imageSize = box.get('imageSize', defaultValue: 1.0);
      _showGradient = box.get('showGradient', defaultValue: false);
      _gradientStart = Color(box.get('gradientStart', defaultValue: Colors.blue.value));
      _gradientEnd = Color(box.get('gradientEnd', defaultValue: Colors.lightBlue.value));
      _gradientDirection = box.get('gradientDirection', defaultValue: 'horizontal');
      _showBorder = box.get('showBorder', defaultValue: true);
      _borderColor = Color(box.get('borderColor', defaultValue: Colors.grey.value));
      _borderRadius = box.get('borderRadius', defaultValue: 8.0);
      _showShadow = box.get('showShadow', defaultValue: true);
      _shadowOpacity = box.get('shadowOpacity', defaultValue: 0.3);
      _showWatermark = box.get('showWatermark', defaultValue: false);
      _watermarkText = box.get('watermarkText');
      _watermarkColor = Color(box.get('watermarkColor', defaultValue: Colors.grey.withOpacity(0.3).value));
      _showFooter = box.get('showFooter', defaultValue: true);
      _footerText = box.get('footerText', defaultValue: 'Contato: (11) 99999-9999');
      _showHeader = box.get('showHeader', defaultValue: true);
      _headerText = box.get('headerText', defaultValue: 'Catálogo de Produtos');
      _showPageNumbers = box.get('showPageNumbers', defaultValue: true);
      _pageNumberFormat = box.get('pageNumberFormat', defaultValue: 'Página {current} de {total}');
      _showQRCode = box.get('showQRCode', defaultValue: false);
      _qrCodeData = box.get('qrCodeData');
      _showTable = box.get('showTable', defaultValue: false);
      _tableColumns = List<String>.from(box.get('tableColumns', defaultValue: ['Nome', 'Preço', 'Categoria']));
      _showImageBackground = box.get('showImageBackground', defaultValue: false);
      _backgroundImagePath = box.get('backgroundImagePath');
      _backgroundOpacity = box.get('backgroundOpacity', defaultValue: 0.1);
      _showCustomFont = box.get('showCustomFont', defaultValue: false);
      _customFontPath = box.get('customFontPath');
      _showCustomStyle = box.get('showCustomStyle', defaultValue: false);
      _customStyles = Map<String, dynamic>.from(box.get('customStyles', defaultValue: {}));
    });
  }

  Future<void> _saveSettings() async {
    final box = Hive.box('template_settings');
    await box.putAll({
      'logoPath': _logoPath,
      'fontFamily': _fontFamily,
      'primaryColor': _primaryColor.value,
      'secondaryColor': _secondaryColor.value,
      'textColor': _textColor.value,
      'showPrice': _showPrice,
      'showCategory': _showCategory,
      'showInfo': _showInfo,
      'showCode': _showCode,
      'layoutStyle': _layoutStyle,
      'columns': _columns,
      'imageSize': _imageSize,
      'showGradient': _showGradient,
      'gradientStart': _gradientStart.value,
      'gradientEnd': _gradientEnd.value,
      'gradientDirection': _gradientDirection,
      'showBorder': _showBorder,
      'borderColor': _borderColor.value,
      'borderRadius': _borderRadius,
      'showShadow': _showShadow,
      'shadowOpacity': _shadowOpacity,
      'showWatermark': _showWatermark,
      'watermarkText': _watermarkText,
      'watermarkColor': _watermarkColor.value,
      'showFooter': _showFooter,
      'footerText': _footerText,
      'showHeader': _showHeader,
      'headerText': _headerText,
      'showPageNumbers': _showPageNumbers,
      'pageNumberFormat': _pageNumberFormat,
      'showQRCode': _showQRCode,
      'qrCodeData': _qrCodeData,
      'showTable': _showTable,
      'tableColumns': _tableColumns,
      'showImageBackground': _showImageBackground,
      'backgroundImagePath': _backgroundImagePath,
      'backgroundOpacity': _backgroundOpacity,
      'showCustomFont': _showCustomFont,
      'customFontPath': _customFontPath,
      'showCustomStyle': _showCustomStyle,
      'customStyles': _customStyles,
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() => _logoPath = savedImage.path);
      await _saveSettings();
    }
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'background_${path.basename(pickedFile.path)}';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() => _backgroundImagePath = savedImage.path);
      await _saveSettings();
    }
  }

  Future<void> _pickCustomFont() async {
    // Implementar seleção de fonte personalizada
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor;
    final iconColor = isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
    final textColor = isDark ? AppTheme.darkTextColor : AppTheme.textColor;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePreset,
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          Text(
                            'Presets',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
            Row(
              children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Nome do Preset',
                                    labelStyle: TextStyle(color: secondaryTextColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: iconColor),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _currentPresetName = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                ElevatedButton(
                                onPressed: _savePreset,
                                child: const Text('Salvar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_presets.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _presets.length,
                              itemBuilder: (context, index) {
                                final preset = _presets[index];
                                return ListTile(
                                  title: Text(
                                    preset['name'],
                                    style: TextStyle(color: textColor),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: iconColor,
                                        ),
                                        onPressed: () => _loadPreset(preset['name']),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: AppTheme.errorColor,
                                        ),
                                        onPressed: () => _deletePreset(preset['name']),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text(
                              'Mostrar logo',
                              style: TextStyle(color: textColor),
                            ),
                            value: mostrarLogo,
                            onChanged: (value) {
                              setState(() {
                                mostrarLogo = value;
                              });
                            },
                          ),
                          if (mostrarLogo) ...[
                            const SizedBox(height: 8),
            Row(
              children: [
                                Expanded(
                                  child: Text(
                                    'Tamanho do logo: ${tamanhoLogo.toStringAsFixed(0)}px',
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                Slider(
                                  value: tamanhoLogo,
                                  min: 50,
                                  max: 200,
                                  divisions: 15,
                                  label: tamanhoLogo.toStringAsFixed(0),
                                  onChanged: (value) {
                                    setState(() {
                                      tamanhoLogo = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _pickLogo,
                              icon: const Icon(Icons.image),
                              label: const Text('Selecionar Logo'),
                            ),
                            if (logoPath != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(logoPath!),
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ColorOption(
                                color: corFundoImagem,
                                isSelected: true,
                                onTap: () {
                                  _showColorPicker('Cor de Fundo', corFundoImagem, (color) {
                                    setState(() {
                                      corFundoImagem = color;
                                    });
                                  });
                                },
                              ),
                              _ColorOption(
                                color: corTexto,
                                isSelected: false,
                                onTap: () {
                                  _showColorPicker('Cor do Texto', corTexto, (color) {
                                    setState(() {
                                      corTexto = color;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Layout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SettingOption(
                            title: 'Espaçamento entre produtos',
                            value: espacamentoProdutos.toString(),
                            onChanged: (value) {
                              setState(() {
                                espacamentoProdutos = double.tryParse(value) ?? 16.0;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          _SettingOption(
                            title: 'Raio da borda',
                            value: raioBorda.toString(),
                            onChanged: (value) {
                              setState(() {
                                raioBorda = double.tryParse(value) ?? 8.0;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          _SettingOption(
                            title: 'Margem da página',
                            value: margemPagina.toString(),
                            onChanged: (value) {
                              setState(() {
                                margemPagina = double.tryParse(value) ?? 20.0;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: Text(
                              'Imagem à esquerda',
                              style: TextStyle(color: textColor),
                            ),
                            value: imagemEsquerda,
                            onChanged: (value) {
                              setState(() {
                                imagemEsquerda = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações do Produto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text(
                              'Mostrar preço',
                              style: TextStyle(color: textColor),
                            ),
                            value: mostrarPreco,
                            onChanged: (value) {
                              setState(() {
                                mostrarPreco = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: Text(
                              'Mostrar categoria',
                              style: TextStyle(color: textColor),
                            ),
                            value: mostrarCategoria,
                            onChanged: (value) {
                              setState(() {
                                mostrarCategoria = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: Text(
                              'Mostrar informações adicionais',
                              style: TextStyle(color: textColor),
                            ),
                            value: mostrarInformacoes,
                            onChanged: (value) {
                              setState(() {
                                mostrarInformacoes = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fonte',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: fonteSelecionada,
                            decoration: InputDecoration(
                              labelText: 'Família da fonte',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: iconColor),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Roboto',
                                child: Text('Roboto'),
                              ),
                              DropdownMenuItem(
                                value: 'Open Sans',
                                child: Text('Open Sans'),
                              ),
                              DropdownMenuItem(
                                value: 'Montserrat',
                                child: Text('Montserrat'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                fonteSelecionada = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _SettingOption(
                            title: 'Tamanho da fonte',
                            value: tamanhoFonte.toString(),
                            onChanged: (value) {
                              setState(() {
                                tamanhoFonte = double.tryParse(value) ?? 14.0;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickFont,
                            icon: const Icon(Icons.font_download),
                            label: const Text('Carregar Fonte Personalizada'),
                          ),
                          if (fontePersonalizadaPath != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Fonte carregada: ${fontePersonalizadaPath!.split('/').last}',
                                style: TextStyle(color: secondaryTextColor),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rodapé',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text(
                              'Mostrar data de geração',
                              style: TextStyle(color: textColor),
                            ),
                            value: mostrarDataGeracao,
                            onChanged: (value) {
                              setState(() {
                                mostrarDataGeracao = value;
                              });
                            },
            ),
            SwitchListTile(
                            title: Text(
                              'Mostrar informações de contato',
                              style: TextStyle(color: textColor),
                            ),
                            value: mostrarContato,
                            onChanged: (value) {
                              setState(() {
                                mostrarContato = value;
                              });
                            },
                          ),
                          if (mostrarContato)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Contato',
                                  labelStyle: TextStyle(color: secondaryTextColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: iconColor),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    contato = value;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingOption extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  const _SettingOption({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkTextColor : AppTheme.textColor;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: textColor),
          ),
        ),
        SizedBox(
          width: 80,
          child: TextField(
            textAlign: TextAlign.center,
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
