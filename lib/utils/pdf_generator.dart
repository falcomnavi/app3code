import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

Future<void> gerarPdfComLoading(BuildContext context, List<dynamic> products) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Gerando PDF...'),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
            ],
          ),
        ),
  );

  try {
    await gerarPdf(products);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF gerado com sucesso!')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }
}

Future<void> gerarPdf(List<dynamic> products) async {
  final pdf = pw.Document();

  // Carregar configurações do template
  final templateBox = Hive.box('template_settings');
  final appSettingsBox = Hive.box('app_settings');

  // Obter configurações com valores padrão
  final logoPath = templateBox.get('logoPath', defaultValue: '');
  final showPrice = templateBox.get('showPrice', defaultValue: true);
  final showCategory = templateBox.get('showCategory', defaultValue: true);
  final showInfo = templateBox.get('showInfo', defaultValue: true);
  final primaryColor = templateBox.get('primaryColor', defaultValue: '#2196F3');
  final secondaryColor = templateBox.get('secondaryColor', defaultValue: '#1976D2');
  final textColor = templateBox.get('textColor', defaultValue: '#000000');
  final backgroundColor = templateBox.get('backgroundColor', defaultValue: '#FFFFFF');
  final fontFamily = templateBox.get('fontFamily', defaultValue: 'Helvetica');
  final fontSize = templateBox.get('fontSize', defaultValue: 12.0);
  final titleFontSize = templateBox.get('titleFontSize', defaultValue: 16.0);
  final headerFontSize = templateBox.get('headerFontSize', defaultValue: 14.0);
  final footerText = templateBox.get('footerText', defaultValue: '');
  final showFooter = templateBox.get('showFooter', defaultValue: true);
  final showDate = templateBox.get('showDate', defaultValue: true);
  final showContact = templateBox.get('showContact', defaultValue: true);
  final contactInfo = templateBox.get('contactInfo', defaultValue: '');

  // Converter cores hex para PdfColor
  final pdfPrimaryColor = PdfColor.fromHex(primaryColor);
  final pdfSecondaryColor = PdfColor.fromHex(secondaryColor);
  final pdfTextColor = PdfColor.fromHex(textColor);
  final pdfBackgroundColor = PdfColor.fromHex(backgroundColor);
  
  // Criar versões mais claras das cores para efeitos de opacidade
  final pdfPrimaryColorLight = PdfColor.fromHex(primaryColor.replaceAll('#', '') + '1A'); // 10% de opacidade
  final pdfSecondaryColorLight = PdfColor.fromHex(secondaryColor.replaceAll('#', '') + '1A'); // 10% de opacidade

  // Adicionar página
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return [
          // Cabeçalho
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [pdfPrimaryColor, pdfSecondaryColor],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logoPath.isNotEmpty && File(logoPath).existsSync())
                  pw.Image(
                    pw.MemoryImage(File(logoPath).readAsBytesSync()),
                    width: 100,
                    height: 50,
                    fit: pw.BoxFit.contain,
                  )
                else
                  pw.Text(
                    'Catálogo de Produtos',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: titleFontSize,
                      font: pw.Font.helveticaBold(),
                    ),
                  ),
                if (showDate)
                  pw.Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: pw.TextStyle(
              color: PdfColors.white,
                      fontSize: fontSize,
                    ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Lista de produtos
          pw.ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              
              // Verificar campos em inglês e português
              final name = product['name'] ?? product['nome'] ?? 'Nome não especificado';
              final price = product['price'] ?? product['preco'] ?? '0.00';
              final code = product['code'] ?? product['codigo'] ?? '';
              final imagePath = product['imagePath'] ?? product['image'] ?? '';
              final category = product['category'] ?? product['categoria'] ?? '';
              final info = product['info'] ?? product['informacoes'] ?? '';

              // Verificar se a imagem existe e é válida
              bool hasValidImage = false;
              Uint8List? imageBytes;
              
              if (imagePath.isNotEmpty) {
                try {
                  final imageFile = File(imagePath);
                  if (imageFile.existsSync()) {
                    imageBytes = imageFile.readAsBytesSync().buffer.asUint8List();
                    hasValidImage = true;
                  }
                } catch (e) {
                  print('Erro ao carregar imagem: $e');
                }
              }

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                decoration: pw.BoxDecoration(
                  color: pdfBackgroundColor,
                  border: pw.Border.all(color: pdfPrimaryColor),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                      if (hasValidImage && imageBytes != null)
                        pw.Container(
                          width: 100,
                          height: 100,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: pdfPrimaryColor),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Image(
                            pw.MemoryImage(imageBytes),
                            fit: pw.BoxFit.cover,
                          ),
                        )
                      else
                        pw.Container(
                          width: 100,
                          height: 100,
                          decoration: pw.BoxDecoration(
                            color: pdfPrimaryColorLight,
                            border: pw.Border.all(color: pdfPrimaryColor),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'Sem imagem',
                              style: pw.TextStyle(
                                color: pdfTextColor,
                                fontSize: fontSize - 2,
                        ),
                      ),
                    ),
                  ),
                      pw.SizedBox(width: 16),
                      pw.Expanded(
                  child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                            pw.Text(
                              name,
                              style: pw.TextStyle(
                                color: pdfTextColor,
                                fontSize: headerFontSize,
                                font: pw.Font.helveticaBold(),
                              ),
                            ),
                            if (showPrice) ...[
                      pw.SizedBox(height: 8),
                              pw.Text(
                                'Preço: R\$ $price',
                                style: pw.TextStyle(
                                  color: pdfTextColor,
                                  fontSize: fontSize,
                                ),
                              ),
                            ],
                            if (showCategory) ...[
                              pw.SizedBox(height: 8),
                              pw.Text(
                                'Categoria: $category',
                                style: pw.TextStyle(
                                  color: pdfTextColor,
                                  fontSize: fontSize,
                                ),
                              ),
                            ],
                            if (showInfo && info.isNotEmpty) ...[
                              pw.SizedBox(height: 8),
                              pw.Text(
                                'Informações: $info',
                                style: pw.TextStyle(
                                  color: pdfTextColor,
                                  fontSize: fontSize,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Rodapé
          if (showFooter) ...[
            pw.SizedBox(height: 20),
            pw.Container(
                                decoration: pw.BoxDecoration(
                                  gradient: pw.LinearGradient(
                  colors: [pdfPrimaryColor, pdfSecondaryColor],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                ),
              ),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                children: [
                  if (footerText.isNotEmpty)
                    pw.Text(
                      footerText,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: fontSize,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  if (showContact && contactInfo.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      contactInfo,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: fontSize,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ];
      },
    ),
  );

  // Salvar PDF
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/catalogo_produtos.pdf');
  await file.writeAsBytes(await pdf.save());

  // Abrir PDF
  await OpenFile.open(file.path);
}

class PdfGenerator {
  static Future<String> gerarPdf() async {
    final box = Hive.box('products');
    final templateBox = Hive.box('template_settings');
    final products = box.values.toList();

    if (products.isEmpty) {
      throw Exception('Nenhum produto encontrado');
    }

    final pdf = pw.Document();

    // Configurações do template
    final logoPath = templateBox.get('logoPath');
    final fontFamily = templateBox.get('fontFamily', defaultValue: 'Roboto');
    final primaryColor = PdfColor.fromInt(templateBox.get('primaryColor', defaultValue: Colors.blue.value));
    final secondaryColor = PdfColor.fromInt(templateBox.get('secondaryColor', defaultValue: Colors.grey.value));
    final textColor = PdfColor.fromInt(templateBox.get('textColor', defaultValue: Colors.black.value));
    final textColorInt = templateBox.get('textColor', defaultValue: Colors.black.value);
    final secondaryColorInt = templateBox.get('secondaryColor', defaultValue: Colors.grey.value);
    final showPrice = templateBox.get('showPrice', defaultValue: true);
    final showCategory = templateBox.get('showCategory', defaultValue: true);
    final showInfo = templateBox.get('showInfo', defaultValue: true);
    final showCode = templateBox.get('showCode', defaultValue: true);
    final layoutStyle = templateBox.get('layoutStyle', defaultValue: 'grid');
    final columns = templateBox.get('columns', defaultValue: 2);
    final imageSize = templateBox.get('imageSize', defaultValue: 1.0);
    final showGradient = templateBox.get('showGradient', defaultValue: false);
    final gradientStart = PdfColor.fromInt(templateBox.get('gradientStart', defaultValue: Colors.blue.value));
    final gradientEnd = PdfColor.fromInt(templateBox.get('gradientEnd', defaultValue: Colors.lightBlue.value));
    final gradientDirection = templateBox.get('gradientDirection', defaultValue: 'horizontal');
    final showBorder = templateBox.get('showBorder', defaultValue: true);
    final borderColor = PdfColor.fromInt(templateBox.get('borderColor', defaultValue: Colors.grey.value));
    final borderRadius = templateBox.get('borderRadius', defaultValue: 8.0);
    final showShadow = templateBox.get('showShadow', defaultValue: true);
    final shadowOpacity = templateBox.get('shadowOpacity', defaultValue: 0.3);
    final showWatermark = templateBox.get('showWatermark', defaultValue: false);
    final watermarkText = templateBox.get('watermarkText');
    final watermarkColor = PdfColor.fromInt(templateBox.get('watermarkColor', defaultValue: Colors.grey.withOpacity(0.3).value));
    final showFooter = templateBox.get('showFooter', defaultValue: true);
    final footerText = templateBox.get('footerText', defaultValue: 'Contato: (11) 99999-9999');
    final showHeader = templateBox.get('showHeader', defaultValue: true);
    final headerText = templateBox.get('headerText', defaultValue: 'Catálogo de Produtos');
    final showPageNumbers = templateBox.get('showPageNumbers', defaultValue: true);
    final pageNumberFormat = templateBox.get('pageNumberFormat', defaultValue: 'Página {current} de {total}');
    final showQRCode = templateBox.get('showQRCode', defaultValue: false);
    final qrCodeData = templateBox.get('qrCodeData');
    final showTable = templateBox.get('showTable', defaultValue: false);
    final tableColumns = List<String>.from(templateBox.get('tableColumns', defaultValue: ['Nome', 'Preço', 'Categoria']));
    final showImageBackground = templateBox.get('showImageBackground', defaultValue: false);
    final backgroundImagePath = templateBox.get('backgroundImagePath');
    final backgroundOpacity = templateBox.get('backgroundOpacity', defaultValue: 0.1);

    // Carregar fonte personalizada se existir
    final customFontPath = templateBox.get('customFontPath');
    final ttf = customFontPath != null ? await rootBundle.load(customFontPath) : null;
    final font = ttf != null ? pw.Font.ttf(ttf) : null;

    // Carregar logo se existir
    final logo = logoPath != null ? pw.MemoryImage(File(logoPath).readAsBytesSync()) : null;

    // Carregar imagem de fundo se existir
    final backgroundImage = backgroundImagePath != null ? pw.MemoryImage(File(backgroundImagePath).readAsBytesSync()) : null;

    // Função para criar gradiente
    pw.BoxDecoration? createGradient() {
      if (!showGradient) return null;
      return pw.BoxDecoration(
        gradient: pw.LinearGradient(
          begin: gradientDirection == 'horizontal' ? pw.Alignment.centerLeft : pw.Alignment.topCenter,
          end: gradientDirection == 'horizontal' ? pw.Alignment.centerRight : pw.Alignment.bottomCenter,
          colors: [gradientStart, gradientEnd],
        ),
      );
    }

    // Função para criar borda
    pw.BoxDecoration? createBorder() {
      if (!showBorder) return null;
      return pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1),
        borderRadius: pw.BorderRadius.circular(borderRadius),
      );
    }

    // Função para criar sombra
    pw.BoxDecoration? createShadow() {
      if (!showShadow) return null;
      return pw.BoxDecoration(
        boxShadow: [
          pw.BoxShadow(
            color: PdfColor.fromInt(Colors.black.withOpacity(shadowOpacity).value),
            blurRadius: 5,
            offset: PdfPoint(2, 2), // Corrigido: mudado de pw.Point para PdfPoint
          ),
        ],
      );
    }

    // Função para criar marca d'água
    pw.Widget? createWatermark() {
      if (!showWatermark || watermarkText == null) return null;
      return pw.Transform.rotate(
        angle: -0.5,
        child: pw.Opacity(
          opacity: 0.3,
                                child: pw.Text(
            watermarkText,
            style: pw.TextStyle(
              color: watermarkColor,
              fontSize: 50,
                                  ),
                                ),
                              ),
      );
    }

    // Função para criar QR Code - tornado assíncrono
    Future<pw.Widget?> createQRCode() async {
      if (!showQRCode || qrCodeData == null) return null;
      
      final qr = QrPainter(
        data: qrCodeData,
        version: QrVersions.auto,
        gapless: false,
        color: ui.Color(textColorInt),
        emptyColor: ui.Color(secondaryColorInt),
      );
      
      final qrImageData = await qr.toImageData(200);
      if (qrImageData == null) return null;
      
      return pw.Image(
        pw.MemoryImage(qrImageData.buffer.asUint8List()),
        width: 100,
        height: 100,
      );
    }

    // Função para criar cabeçalho
    pw.Widget createHeader() {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: primaryColor,
          borderRadius: const pw.BorderRadius.only(
            bottomLeft: pw.Radius.circular(10),
            bottomRight: pw.Radius.circular(10),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logo != null)
              pw.Image(
                logo,
                width: 100,
                height: 50,
                fit: pw.BoxFit.contain,
              ),
            pw.Text(
              headerText,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 24,
                font: font,
                            ),
                          ),
                        ],
                      ),
      );
    }

    // Função para criar rodapé
    pw.Widget createFooter() {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
                              decoration: pw.BoxDecoration(
          color: secondaryColor,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(10),
            topRight: pw.Radius.circular(10),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              footerText,
              style: pw.TextStyle(
                                  color: PdfColors.white,
                fontSize: 12,
                font: font,
              ),
            ),
            if (showPageNumbers)
              pw.Text(
                pageNumberFormat,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                  font: font,
                ),
              ),
          ],
        ),
      );
    }

    // Função para criar card de produto
    pw.Widget createProductCard(Map<String, dynamic> product) {
      final name = product['name'] ?? product['nome'] ?? 'Sem nome';
      final price = product['price'] ?? product['preco'] ?? '0.00';
      final category = product['category'] ?? product['categoria'] ?? 'Sem categoria';
      final info = product['info'] ?? product['informacao'] ?? '';
      final code = product['code'] ?? product['codigo'] ?? '';
      final imagePath = product['imagePath'] ?? product['caminhoImagem'];

      return pw.Container(
        margin: const pw.EdgeInsets.all(10),
                                decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(borderRadius),
          border: showBorder ? pw.Border.all(color: borderColor, width: 1) : null,
          boxShadow: showShadow
              ? [
                  pw.BoxShadow(
                    color: PdfColor.fromInt(Colors.black.withOpacity(shadowOpacity).value),
                    blurRadius: 5,
                    offset: PdfPoint(2, 2), // Corrigido: mudado de pw.Point para PdfPoint
                  ),
                ]
              : null,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (imagePath != null)
              pw.Image(
                pw.MemoryImage(File(imagePath).readAsBytesSync()),
                width: double.infinity,
                height: 200.0 * (imageSize as double),
                fit: pw.BoxFit.cover,
              ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    name,
                    style: pw.TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                  if (showPrice)
                    pw.Text(
                      'R\$ $price',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        font: font,
                      ),
                    ),
                  if (showCategory)
                    pw.Text(
                      category,
                      style: pw.TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                        font: font,
                      ),
                    ),
                  if (showCode)
                    pw.Text(
                      'Código: $code',
                      style: pw.TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                        font: font,
                      ),
                    ),
                  if (showInfo && info.isNotEmpty)
                    pw.Text(
                      info,
                      style: pw.TextStyle(
                        color: textColor,
                        fontSize: 12,
                        font: font,
                      ),
                    ),
                    ],
                  ),
                ),
              ],
            ),
          );
    }

    // Função para criar tabela de produtos
    pw.Widget createProductTable() {
      final headers = tableColumns.map((column) => pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Text(
              column,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
            ),
          )).toList();

      final rows = products.map((product) {
        return tableColumns.map((column) {
          String value = '';
          switch (column.toLowerCase()) {
            case 'nome':
              value = product['name'] ?? product['nome'] ?? '';
              break;
            case 'preço':
              value = 'R\$ ${product['price'] ?? product['preco'] ?? '0.00'}';
              break;
            case 'categoria':
              value = product['category'] ?? product['categoria'] ?? '';
              break;
            case 'código':
              value = product['code'] ?? product['codigo'] ?? '';
              break;
            case 'informações':
              value = product['additionalInfo'] ?? product['informacao'] ?? '';
              break;
          }
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Text(
              value,
              style: pw.TextStyle(
                color: textColor,
                font: font,
              ),
            ),
          );
        }).toList();
      }).toList();

      return pw.Table(
        border: pw.TableBorder.all(color: borderColor),
        children: [
          pw.TableRow(children: headers),
          ...rows.map((row) => pw.TableRow(children: row)),
        ],
      );
    }

    // Modificada para lidar com o QR Code assíncrono
    Future<void> addPagesToDocument() async {
      // Preparar QR Code antecipadamente se necessário
      pw.Widget? qrCodeWidget;
      if (showQRCode) {
        qrCodeWidget = await createQRCode();
      }

      if (layoutStyle == 'table') {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Stack(
                children: [
                  if (backgroundImage != null)
                    pw.Opacity(
                      opacity: backgroundOpacity,
                      child: pw.Image(
                        backgroundImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  if (showHeader) createHeader(),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(20),
                    child: createProductTable(),
                  ),
                  if (showFooter) createFooter(),
                  if (showWatermark) createWatermark()!,
                  if (qrCodeWidget != null) qrCodeWidget,
                ],
              );
            },
          ),
        );
      } else {
        final productsPerPage = columns * 2;
        final totalPages = (products.length / productsPerPage).ceil();

        for (var i = 0; i < totalPages; i++) {
          final start = i * productsPerPage;
          final end = (start + productsPerPage > products.length) ? products.length : start + productsPerPage;
          final pageProducts = products.sublist(start.toInt(), end.toInt());

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (context) {
                return pw.Stack(
                  children: [
                    if (backgroundImage != null)
                      pw.Opacity(
                        opacity: backgroundOpacity,
                        child: pw.Image(
                          backgroundImage,
                          width: double.infinity,
                          height: double.infinity,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    if (showHeader) createHeader(),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(20),
                      child: layoutStyle == 'grid'
                          ? pw.GridView(
                              crossAxisCount: columns,
                              children: pageProducts.map((product) => createProductCard(product)).toList(),
                            )
                          : pw.Column(
                              children: pageProducts.map((product) => createProductCard(product)).toList(),
                            ),
                    ),
                    if (showFooter) createFooter(),
                    if (showWatermark) createWatermark()!,
                    if (qrCodeWidget != null) qrCodeWidget,
                  ],
                );
              },
            ),
          );
        }
      }
    }

    // Adicionar páginas ao PDF
    await addPagesToDocument();

    // Salvar e compartilhar o PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/catalogo.pdf');
  await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}