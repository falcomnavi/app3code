import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TemplateProvider extends ChangeNotifier {
  final _box = Hive.box('template_settings');
  
  // Configurações do template
  String? _logoPath;
  String _fontFamily = 'Roboto';
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.grey;
  Color _textColor = Colors.black;
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

  // Getters
  String? get logoPath => _logoPath;
  String get fontFamily => _fontFamily;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get textColor => _textColor;
  bool get showPrice => _showPrice;
  bool get showCategory => _showCategory;
  bool get showInfo => _showInfo;
  bool get showCode => _showCode;
  String get layoutStyle => _layoutStyle;
  int get columns => _columns;
  double get imageSize => _imageSize;
  bool get showGradient => _showGradient;
  Color get gradientStart => _gradientStart;
  Color get gradientEnd => _gradientEnd;
  String get gradientDirection => _gradientDirection;
  bool get showBorder => _showBorder;
  Color get borderColor => _borderColor;
  double get borderRadius => _borderRadius;
  bool get showShadow => _showShadow;
  double get shadowOpacity => _shadowOpacity;
  bool get showWatermark => _showWatermark;
  String? get watermarkText => _watermarkText;
  Color get watermarkColor => _watermarkColor;
  bool get showFooter => _showFooter;
  String get footerText => _footerText;
  bool get showHeader => _showHeader;
  String get headerText => _headerText;
  bool get showPageNumbers => _showPageNumbers;
  String get pageNumberFormat => _pageNumberFormat;
  bool get showQRCode => _showQRCode;
  String? get qrCodeData => _qrCodeData;
  bool get showTable => _showTable;
  List<String> get tableColumns => _tableColumns;
  bool get showImageBackground => _showImageBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  double get backgroundOpacity => _backgroundOpacity;
  bool get showCustomFont => _showCustomFont;
  String? get customFontPath => _customFontPath;
  bool get showCustomStyle => _showCustomStyle;
  Map<String, dynamic> get customStyles => _customStyles;

  // Setters
  set logoPath(String? value) {
    _logoPath = value;
    _saveSettings();
    notifyListeners();
  }

  set fontFamily(String value) {
    _fontFamily = value;
    _saveSettings();
    notifyListeners();
  }

  set primaryColor(Color value) {
    _primaryColor = value;
    _saveSettings();
    notifyListeners();
  }

  set secondaryColor(Color value) {
    _secondaryColor = value;
    _saveSettings();
    notifyListeners();
  }

  set textColor(Color value) {
    _textColor = value;
    _saveSettings();
    notifyListeners();
  }

  set showPrice(bool value) {
    _showPrice = value;
    _saveSettings();
    notifyListeners();
  }

  set showCategory(bool value) {
    _showCategory = value;
    _saveSettings();
    notifyListeners();
  }

  set showInfo(bool value) {
    _showInfo = value;
    _saveSettings();
    notifyListeners();
  }

  set showCode(bool value) {
    _showCode = value;
    _saveSettings();
    notifyListeners();
  }

  set layoutStyle(String value) {
    _layoutStyle = value;
    _saveSettings();
    notifyListeners();
  }

  set columns(int value) {
    _columns = value;
    _saveSettings();
    notifyListeners();
  }

  set imageSize(double value) {
    _imageSize = value;
    _saveSettings();
    notifyListeners();
  }

  set showGradient(bool value) {
    _showGradient = value;
    _saveSettings();
    notifyListeners();
  }

  set gradientStart(Color value) {
    _gradientStart = value;
    _saveSettings();
    notifyListeners();
  }

  set gradientEnd(Color value) {
    _gradientEnd = value;
    _saveSettings();
    notifyListeners();
  }

  set gradientDirection(String value) {
    _gradientDirection = value;
    _saveSettings();
    notifyListeners();
  }

  set showBorder(bool value) {
    _showBorder = value;
    _saveSettings();
    notifyListeners();
  }

  set borderColor(Color value) {
    _borderColor = value;
    _saveSettings();
    notifyListeners();
  }

  set borderRadius(double value) {
    _borderRadius = value;
    _saveSettings();
    notifyListeners();
  }

  set showShadow(bool value) {
    _showShadow = value;
    _saveSettings();
    notifyListeners();
  }

  set shadowOpacity(double value) {
    _shadowOpacity = value;
    _saveSettings();
    notifyListeners();
  }

  set showWatermark(bool value) {
    _showWatermark = value;
    _saveSettings();
    notifyListeners();
  }

  set watermarkText(String? value) {
    _watermarkText = value;
    _saveSettings();
    notifyListeners();
  }

  set watermarkColor(Color value) {
    _watermarkColor = value;
    _saveSettings();
    notifyListeners();
  }

  set showFooter(bool value) {
    _showFooter = value;
    _saveSettings();
    notifyListeners();
  }

  set footerText(String value) {
    _footerText = value;
    _saveSettings();
    notifyListeners();
  }

  set showHeader(bool value) {
    _showHeader = value;
    _saveSettings();
    notifyListeners();
  }

  set headerText(String value) {
    _headerText = value;
    _saveSettings();
    notifyListeners();
  }

  set showPageNumbers(bool value) {
    _showPageNumbers = value;
    _saveSettings();
    notifyListeners();
  }

  set pageNumberFormat(String value) {
    _pageNumberFormat = value;
    _saveSettings();
    notifyListeners();
  }

  set showQRCode(bool value) {
    _showQRCode = value;
    _saveSettings();
    notifyListeners();
  }

  set qrCodeData(String? value) {
    _qrCodeData = value;
    _saveSettings();
    notifyListeners();
  }

  set showTable(bool value) {
    _showTable = value;
    _saveSettings();
    notifyListeners();
  }

  set tableColumns(List<String> value) {
    _tableColumns = value;
    _saveSettings();
    notifyListeners();
  }

  set showImageBackground(bool value) {
    _showImageBackground = value;
    _saveSettings();
    notifyListeners();
  }

  set backgroundImagePath(String? value) {
    _backgroundImagePath = value;
    _saveSettings();
    notifyListeners();
  }

  set backgroundOpacity(double value) {
    _backgroundOpacity = value;
    _saveSettings();
    notifyListeners();
  }

  set showCustomFont(bool value) {
    _showCustomFont = value;
    _saveSettings();
    notifyListeners();
  }

  set customFontPath(String? value) {
    _customFontPath = value;
    _saveSettings();
    notifyListeners();
  }

  set showCustomStyle(bool value) {
    _showCustomStyle = value;
    _saveSettings();
    notifyListeners();
  }

  set customStyles(Map<String, dynamic> value) {
    _customStyles = value;
    _saveSettings();
    notifyListeners();
  }

  // Carregar configurações
  Future<void> loadSettings() async {
    _logoPath = _box.get('logoPath');
    _fontFamily = _box.get('fontFamily', defaultValue: 'Roboto');
    _primaryColor = Color(_box.get('primaryColor', defaultValue: Colors.blue.value));
    _secondaryColor = Color(_box.get('secondaryColor', defaultValue: Colors.grey.value));
    _textColor = Color(_box.get('textColor', defaultValue: Colors.black.value));
    _showPrice = _box.get('showPrice', defaultValue: true);
    _showCategory = _box.get('showCategory', defaultValue: true);
    _showInfo = _box.get('showInfo', defaultValue: true);
    _showCode = _box.get('showCode', defaultValue: true);
    _layoutStyle = _box.get('layoutStyle', defaultValue: 'grid');
    _columns = _box.get('columns', defaultValue: 2);
    _imageSize = _box.get('imageSize', defaultValue: 1.0);
    _showGradient = _box.get('showGradient', defaultValue: false);
    _gradientStart = Color(_box.get('gradientStart', defaultValue: Colors.blue.value));
    _gradientEnd = Color(_box.get('gradientEnd', defaultValue: Colors.lightBlue.value));
    _gradientDirection = _box.get('gradientDirection', defaultValue: 'horizontal');
    _showBorder = _box.get('showBorder', defaultValue: true);
    _borderColor = Color(_box.get('borderColor', defaultValue: Colors.grey.value));
    _borderRadius = _box.get('borderRadius', defaultValue: 8.0);
    _showShadow = _box.get('showShadow', defaultValue: true);
    _shadowOpacity = _box.get('shadowOpacity', defaultValue: 0.3);
    _showWatermark = _box.get('showWatermark', defaultValue: false);
    _watermarkText = _box.get('watermarkText');
    _watermarkColor = Color(_box.get('watermarkColor', defaultValue: Colors.grey.withOpacity(0.3).value));
    _showFooter = _box.get('showFooter', defaultValue: true);
    _footerText = _box.get('footerText', defaultValue: 'Contato: (11) 99999-9999');
    _showHeader = _box.get('showHeader', defaultValue: true);
    _headerText = _box.get('headerText', defaultValue: 'Catálogo de Produtos');
    _showPageNumbers = _box.get('showPageNumbers', defaultValue: true);
    _pageNumberFormat = _box.get('pageNumberFormat', defaultValue: 'Página {current} de {total}');
    _showQRCode = _box.get('showQRCode', defaultValue: false);
    _qrCodeData = _box.get('qrCodeData');
    _showTable = _box.get('showTable', defaultValue: false);
    _tableColumns = List<String>.from(_box.get('tableColumns', defaultValue: ['Nome', 'Preço', 'Categoria']));
    _showImageBackground = _box.get('showImageBackground', defaultValue: false);
    _backgroundImagePath = _box.get('backgroundImagePath');
    _backgroundOpacity = _box.get('backgroundOpacity', defaultValue: 0.1);
    _showCustomFont = _box.get('showCustomFont', defaultValue: false);
    _customFontPath = _box.get('customFontPath');
    _showCustomStyle = _box.get('showCustomStyle', defaultValue: false);
    _customStyles = Map<String, dynamic>.from(_box.get('customStyles', defaultValue: {}));
    notifyListeners();
  }

  // Salvar configurações
  Future<void> _saveSettings() async {
    await _box.putAll({
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
} 