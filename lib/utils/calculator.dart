import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '0';

  final List<String> buttons = [
    'C', 'DEL', '%', '/',
    '7', '8', '9', '*',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '=',
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '0';
      } else if (value == 'DEL') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (value == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(_input.replaceAll('×', '*').replaceAll('÷', '/'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result = eval.toString();
        } catch (e) {
          _result = 'Erro';
        }
      } else {
        _input += value;
      }
    });
  }

  Widget _buildButton(String value) {
    final isOperator = ['%', '/', '*', '-', '+', '='].contains(value);
    final color = isOperator ? Colors.orange.shade700 : Colors.grey.shade800;

    return ElevatedButton(
      onPressed: () => _onButtonPressed(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Calculadora')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_input, style: const TextStyle(fontSize: 24, color: Colors.white)),
                  Text(_result, style: const TextStyle(fontSize: 48, color: Colors.white)),
                ],
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            itemCount: buttons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
            ),
            itemBuilder: (context, index) {
              return _buildButton(buttons[index]);
            },
          ),
        ],
      ),
    );
  }
}
