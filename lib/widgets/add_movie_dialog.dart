import 'package:flutter/material.dart';

class NovoFilme {
  const NovoFilme({required this.titulo, required this.url_da_capa});

  final String titulo;
  final String url_da_capa;
}

Future<NovoFilme?> showAddMovieDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final urlController = TextEditingController();

  return showDialog<NovoFilme>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Adicionar filme'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: tituloController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Obrigatório' : null,
            ),
            TextFormField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL da capa'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Obrigatório' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              NovoFilme(
                titulo: tituloController.text.trim(),
                url_da_capa: urlController.text.trim(),
              ),
            );
          },
          child: const Text('Adicionar'),
        ),
      ],
    ),
  );
}
