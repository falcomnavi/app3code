import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';




class NavegadorGoogle extends StatefulWidget {
  const NavegadorGoogle({Key? key}) : super(key: key);

  @override
  _NavegadorGoogleState createState() => _NavegadorGoogleState();
}

class _NavegadorGoogleState extends State<NavegadorGoogle> {
  late final WebViewController _controller;
  String? _imagemSelecionada;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  double _loadingProgress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ImagemSelecionada',
        onMessageReceived: (message) {
          setState(() {
            _imagemSelecionada = message.message;
          });
          _mostrarOpcoesImagem(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0.0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress / 100;
              if (progress >= 100) {
                _isLoading = false;
              }
            });
            if (progress > 70) {
              _injetarJS();
            }
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 1.0;
            });
            _injetarJS();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.google.com/imghp?hl=pt-BR'));
  }

  void _injetarJS() {
    _controller.runJavaScript("""
      // Função para adicionar manipuladores de eventos a todas as imagens
      function adicionarManipuladoresImagens() {
        // Seleciona todas as imagens na página
        const imagens = document.querySelectorAll('img');
        
        imagens.forEach(img => {
          // Evita adicionar manipuladores duplicados
          if (!img.hasAttribute('listener-added')) {
            // Manipulador para clique longo (contextmenu)
            img.addEventListener('contextmenu', function(e) {
              e.preventDefault();
              let src = img.src;
              
              // Tenta obter a versão em alta resolução para imagens do Google
              if (img.hasAttribute('data-src')) {
                src = img.getAttribute('data-src');
              }
              
              // Para imagens em resultados de busca do Google
              const parent = img.closest('a');
              if (parent && parent.href && parent.href.includes('imgurl=')) {
                const match = parent.href.match(/imgurl=([^&]+)/);
                if (match && match[1]) {
                  src = decodeURIComponent(match[1]);
                }
              }
              
              ImagemSelecionada.postMessage(src);
              return false;
            });
            
            // Adicionar manipulador de toque longo para dispositivos móveis
            let touchStartTime = 0;
            let touchTimer = null;
            let startX = 0;
            let startY = 0;
            
            img.addEventListener('touchstart', function(e) {
              touchStartTime = new Date().getTime();
              startX = e.touches[0].clientX;
              startY = e.touches[0].clientY;
              
              touchTimer = setTimeout(function() {
                let src = img.src;
                
                // Tenta obter a versão em alta resolução
                if (img.hasAttribute('data-src')) {
                  src = img.getAttribute('data-src');
                }
                
                // Para imagens em resultados de busca do Google
                const parent = img.closest('a');
                if (parent && parent.href && parent.href.includes('imgurl=')) {
                  const match = parent.href.match(/imgurl=([^&]+)/);
                  if (match && match[1]) {
                    src = decodeURIComponent(match[1]);
                  }
                }
                
                ImagemSelecionada.postMessage(src);
              }, 600);
            });
            
            img.addEventListener('touchend', function(e) {
              clearTimeout(touchTimer);
            });
            
            img.addEventListener('touchmove', function(e) {
              const moveX = Math.abs(e.touches[0].clientX - startX);
              const moveY = Math.abs(e.touches[0].clientY - startY);
              
              // Se moveu mais que um limite, cancela o timer de pressão longa
              if (moveX > 10 || moveY > 10) {
                clearTimeout(touchTimer);
              }
            });
            
            // Marca a imagem como tendo manipuladores adicionados
            img.setAttribute('listener-added', 'true');
          }
        });
      }
      
      // Executa imediatamente
      adicionarManipuladoresImagens();
      
      // Observa mudanças no DOM para adicionar manipuladores a novas imagens
      const observer = new MutationObserver(function(mutations) {
        setTimeout(adicionarManipuladoresImagens, 500);
      });
      
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
      
      // Adicionar manipulador de eventos para eventos de scroll
      window.addEventListener('scroll', function() {
        setTimeout(adicionarManipuladoresImagens, 1000);
      });
    """);
  }

  Future<bool> _solicitarPermissoes() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permissão negada. Vá nas configurações do app e conceda acesso completo ao armazenamento.'),
            action: SnackBarAction(
              label: 'Abrir',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return false;
      }
    }
    return true; // iOS não precisa disso
  }

  String _obterExtensao(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;

    // Extrair extensão da URL
    String extensao = path.contains('.')
        ? path.substring(path.lastIndexOf('.') + 1).toLowerCase()
        : 'jpg'; // Default para jpg

    // Verificar se é uma extensão de imagem válida
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
    if (!validExtensions.contains(extensao)) {
      // Tentar determinar pelo content-type ou outro parâmetro na URL
      if (url.contains('image/jpeg') || url.contains('image/jpg')) {
        extensao = 'jpg';
      } else if (url.contains('image/png')) {
        extensao = 'png';
      } else if (url.contains('image/gif')) {
        extensao = 'gif';
      } else if (url.contains('image/webp')) {
        extensao = 'webp';
      } else {
        extensao = 'jpg'; // Default
      }
    }

    return extensao;
  }

  Future<void> _baixarImagem(String url) async {
    final temPermissao = await _solicitarPermissoes();
    if (!temPermissao) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão negada.')),
      );
      return;
    }

    try {
      final extensao = _obterExtensao(url);
      final nome = 'img_${DateTime.now().millisecondsSinceEpoch}.$extensao';

      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      final dir = await getExternalStorageDirectory(); // /storage/emulated/0/Android/data/<package>/files
      final pastaImagens = Directory('${dir!.path}/images');

      if (!await pastaImagens.exists()) {
        await pastaImagens.create(recursive: true);
      }

      final caminhoCompleto = '${pastaImagens.path}/$nome';
      final file = File(caminhoCompleto);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagem salva em: $caminhoCompleto')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar imagem: $e')),
      );
    }
  }


  void _mostrarOpcoesImagem(String url) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported, color: Colors.grey);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imagem Selecionada',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            url.length > 50 ? '${url.substring(0, 50)}...' : url,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.copy, color: Colors.blue),
                title: Text('Copiar URL da imagem'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('URL copiada!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.green),
                title: Text('Compartilhar imagem'),
                onTap: () async {
                  Navigator.pop(context);
                  await Share.share(url);
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: Colors.orange),
                title: Text('Salvar imagem'),
                onTap: () async {
                  Navigator.pop(context);
                  await _baixarImagem(url);
                },
              ),
              ListTile(
                leading: Icon(Icons.open_in_new, color: Colors.purple),
                title: Text('Abrir em nova aba'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.loadRequest(Uri.parse(url));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Imagens'),
        flexibleSpace: Container(
          decoration: AppTheme.gradientBackground,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _controller.loadRequest(Uri.parse('https://www.google.com/imghp?hl=pt-BR')),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          
          // Barra de progresso superior
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 3,
              ),
            ),

          // Indicador de download
          if (_isDownloading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Baixando imagem... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'voltar',
              backgroundColor: Colors.green,
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  _controller.goBack();
                }
              },
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: 'avancar',
              backgroundColor: Colors.green,
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  _controller.goForward();
                }
              },
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}