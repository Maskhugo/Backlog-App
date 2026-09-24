import 'package:flutter/material.dart';

Future<double?> showRatingDialog(BuildContext context, {double? notaAtual}) {
  final controller = TextEditingController(
    text: notaAtual == null ? '' : notaAtual.toString(),
  );

  return showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Atribuir nota'),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(hintText: 'Nota de 0 a 10'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final nota = double.tryParse(controller.text.replaceAll(',', '.'));
            Navigator.of(context).pop(nota);
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}
