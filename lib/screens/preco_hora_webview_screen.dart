import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class PrecoHoraWebViewScreen extends StatefulWidget {
  const PrecoHoraWebViewScreen({super.key});

  @override
  State<PrecoHoraWebViewScreen> createState() => _PrecoHoraWebViewScreenState();
}

class _PrecoHoraWebViewScreenState extends State<PrecoHoraWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) async {
            setState(() => _isLoading = false);
            // Injetar meta viewport para travar o zoom
            await _controller.runJavaScript(
              "if (!document.querySelector('meta[name=viewport]')) {"
              "var meta = document.createElement('meta');"
              "meta.name = 'viewport';"
              "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';"
              "document.getElementsByTagName('head')[0].appendChild(meta);"
              "}"
            );
          },
          onProgress: (progress) => setState(() => _progress = progress / 100),
        ),
      )
      ..loadRequest(Uri.parse('https://precodahora.ba.gov.br/produtos/'));
  }

  void _reload() => _controller.reload();
  void _goHome() => _controller.loadRequest(Uri.parse('https://precodahora.ba.gov.br/produtos/'));
  void _goBack() => _controller.goBack();
  void _goForward() => _controller.goForward();
  Future<void> _clearCache() async {
    await _controller.clearCache();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache limpo!')),
    );
  }

  void _openInBrowser() async {
    final url = await _controller.currentUrl();
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _scrollToFilters() {
    _controller.runJavaScript(
      "document.querySelector('aside')?.scrollIntoView({behavior: 'smooth'});"
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preço da Hora'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
            onPressed: _goBack,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Avançar',
            onPressed: _goForward,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Início',
            onPressed: _goHome,
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Limpar cache',
            onPressed: _clearCache,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Abrir no navegador',
            onPressed: _openInBrowser,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _isLoading
              ? LinearProgressIndicator(value: _progress)
              : const SizedBox(height: 3),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scrollToFilters,
        icon: const Icon(Icons.tune),
        label: const Text('Filtros'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
} 