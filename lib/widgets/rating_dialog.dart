import 'package:flutter/material.dart';

/// Abre uma janelinha (dialog) para o usuário digitar a nota de um filme.
///
/// Devolve um `Future<double?>`: a resposta chega quando a janela fecha.
/// - Se o usuário tocar em "Salvar", devolve a nota digitada.
/// - Se tocar em "Cancelar" (ou fora da janela), devolve null.
///
/// `notaAtual` é a nota que o filme já tem, para aparecer preenchida.
///
/// Isto é uma função, não uma classe: é só um atalho que monta e
/// abre a janela.
Future<double?> showRatingDialog(BuildContext context, {double? notaAtual}) {
  // Controla o campo de texto. Já começa com a nota atual (se existir),
  // para o usuário só editar em vez de digitar do zero.
  final controller = TextEditingController(
    text: notaAtual == null ? '' : notaAtual.toString(),
  );

  // `showDialog` mostra a janela por cima da tela atual.
  // O `<double>` diz que o valor devolvido ao fechar é um número decimal.
  return showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Atribuir nota'),
      content: TextField(
        controller: controller,
        autofocus: true,
        // Abre o teclado numérico, permitindo vírgula/ponto decimal.
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(hintText: 'Nota de 0 a 10'),
      ),
      // Os botões na parte de baixo da janela.
      actions: [
        TextButton(
          // `pop()` sem valor fecha a janela devolvendo null (= cancelou).
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            // Troca vírgula por ponto (quem digita "8,5" em português)
            // e converte o texto em número. Se não for um número válido,
            // `tryParse` devolve null em vez de quebrar o app.
            final nota = double.tryParse(controller.text.replaceAll(',', '.'));
            // Fecha a janela devolvendo a nota para quem abriu.
            Navigator.of(context).pop(nota);
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}
