import 'dart:math';
import 'package:flutter/services.dart';

class PercentShiftFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 1) extrai só dígitos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // 2) determina casas decimais
    final len = digitsOnly.length;
    final decimals = len == 1
        ? 0
        : len == 2
        ? 1
        : 2;

    // 3) converte em número com vírgula deslocada
    final intVal = int.parse(digitsOnly);
    final divisor = pow(10, decimals);
    final value = intVal / divisor;

    // 4) formata em string com as casas definidas
    String text = value.toStringAsFixed(decimals);

    // 5) remove zeros finais *somente* quando houver 2 casas decimais
    if (decimals == 2) {
      // remove .00 ou .0 finais
      text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    // quando decimals == 1, mantemos o .0 obrigatório
    // quando decimals == 0, toStringAsFixed(0) já não tem ponto

    // 6) ajusta cursor no fim
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
