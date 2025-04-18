import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:hive/hive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> importarCsvBackup() async {
  final box = Hive.box('produtos');

  final file = await openFile(
    acceptedTypeGroups: [
      XTypeGroup(label: 'CSV', extensions: ['csv'])
    ],
  );

  if (file == null) {
    print('Nenhum arquivo selecionado.');
    return;
  }

  final content = await File(file.path).readAsString();
  final rows = const CsvToListConverter(eol: '\n').convert(content);

  for (var i = 1; i < rows.length; i++) {
    final linha = rows[i];

    final nome = linha[0].toString();
    final preco = linha[1].toString();
    final codigo = linha[2].toString();
    final imagem = linha.length > 3 ? linha[3].toString() : '';

    box.add({
      'nome': nome,
      'preco': preco,
      'codigo': codigo,
      'imagem': imagem,
    });
  }

  print('Importação do CSV concluída com sucesso.');
}

Future<void> exportarECompartilharCSV() async {
  final box = Hive.box('produtos');
  final produtos = box.values.toList();

  final buffer = StringBuffer();
  buffer.writeln('nome,preco,codigo,imagem');

  for (var produto in produtos) {
    final nome = (produto['nome'] ?? '').toString().replaceAll(',', ' ');
    final preco = (produto['preco'] ?? '').toString();
    final codigo = (produto['codigo'] ?? '').toString();
    final imagem = (produto['imagem'] ?? '').toString();
    buffer.writeln('$nome,$preco,$codigo,$imagem');
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/produtos_backup.csv');
  await file.writeAsString(buffer.toString());

  await Share.shareXFiles([XFile(file.path)],
      text: 'Veja meu backup de produtos!');
}
