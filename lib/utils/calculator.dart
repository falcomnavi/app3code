import 'dart:math';
import 'package:flutter/material.dart';

/// Engine de cálculo confiável (Shunting‑Yard + pós‑fixado)
class CalculatorEngine {
  static const _precedence = {
    '^': 3,
    '×': 2,
    '÷': 2,
    '%': 2,
    '+': 1,
    '-': 1,
  };

  double? evaluate(String input) {
    try {
      var expr = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');
      // Percentual relativo (ex: 100+10%)
      final rel = RegExp(r'^(\d+\.?\d*)([+\-])(\d+\.?\d*)%\\$').firstMatch(expr);
      if (rel != null) {
        final a = double.parse(rel.group(1)!);
        final op = rel.group(2)!;
        final b = double.parse(rel.group(3)!);
        final p = a * b / 100;
        return op == '+' ? a + p : a - p;
      }
      expr = expr.replaceAllMapped(RegExp(r'(\d+\.?\d*)%'), (m) => '(${m[1]}/100)');
      final tokens = RegExp(r'(\d+\.?\d*|[+\-*/^()%])')
          .allMatches(expr)
          .map((m) => m.group(0)!)
          .toList(growable: false);
      final postfix = _toPostfix(tokens);
      return _evalPostfix(postfix);
    } catch (_) {
      return null;
    }
  }

  List<String> _toPostfix(List<String> tokens) {
    final out = <String>[];
    final stack = <String>[];
    for (var t in tokens) {
      final n = double.tryParse(t);
      if (n != null) {
        out.add(t);
      } else if (_precedence.containsKey(t)) {
        while (stack.isNotEmpty && _precedence.containsKey(stack.last) && _precedence[stack.last]! >= _precedence[t]!) {
          out.add(stack.removeLast());
        }
        stack.add(t);
      } else if (t == '(') {
        stack.add(t);
      } else if (t == ')') {
        while (stack.isNotEmpty && stack.last != '(') out.add(stack.removeLast());
        if (stack.isNotEmpty) stack.removeLast();
      }
    }
    while (stack.isNotEmpty) out.add(stack.removeLast());
    return out;
  }

  double _evalPostfix(List<String> p) {
    final st = <double>[];
    for (var t in p) {
      final n = double.tryParse(t);
      if (n != null) {
        st.add(n);
      } else if (st.length >= 2) {
        final b = st.removeLast();
        final a = st.removeLast();
        double r;
        switch (t) {
          case '+': r = a + b; break;
          case '-': r = a - b; break;
          case '*': r = a * b; break;
          case '/': r = a / b; break;
          case '%': r = a % b; break;
          case '^': r = pow(a, b).toDouble(); break;
          default: r = 0;
        }
        st.add(r);
      }
    }
    return st.isEmpty ? 0 : st.last;
  }
}

/// Botão no estilo macOS: plasticidade e sombra suave
class MacButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bgColor;
  final Color fgColor;
  const MacButton({required this.label, required this.onTap, this.bgColor = const Color(0xFFE0E0E0), this.fgColor = Colors.black, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
            BoxShadow(color: Colors.white.withOpacity(0.6), offset: Offset(0, -1), blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 20, color: fgColor, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

/// Tela com design inspirado no macOS
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _exp = '';
  String _disp = '0';
  final _eng = CalculatorEngine();
  static const _buttons = [
    'C', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  void _press(String l) {
    final ops = ['+', '-', '×', '÷', '%', '^'];
    setState(() {
      if (l == 'C') { _exp = ''; _disp = '0'; }
      else if (l == '⌫') { if (_exp.isNotEmpty) _exp = _exp.substring(0, _exp.length - 1); }
      else if (l == '±') { _exp = _exp.startsWith('-') ? _exp.substring(1) : '-'+_exp; }
      else if (l == '=') { final v = _eng.evaluate(_exp); _disp = v?.toStringAsFixed(v.truncateToDouble()==v?0:6) ?? 'Erro'; }
      else {
        if (ops.contains(l) && (_exp.isEmpty || ops.contains(_exp.characters.last))) return;
        if (l=='.' && _exp.endsWith('.')) return;
        _exp += l;
        _disp = _exp;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Color(0xFFDDDDDD),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(_disp, style: TextStyle(fontSize: 48, fontFamily: 'Helvetica Neue', color: Colors.black)),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.black26),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: _buttons.map((b) {
                  final isOp = ['=', '÷', '×', '-', '+', '%', '±'].contains(b);
                  return MacButton(
                    label: b,
                    fgColor: isOp ? Colors.white : Colors.black,
                    bgColor: isOp ? Color(0xFF007AFF) : Color(0xFFE0E0E0),
                    onTap: () => _press(b),
                  );
                }).toList(growable: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
