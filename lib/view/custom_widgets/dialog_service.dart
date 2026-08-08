import 'dart:async';

import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/viewmodel/document_list_manager.dart';
import 'package:digitalize/viewmodel/document_picker_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogService {
  static Future<String?> rename(BuildContext context, DocumentModel doc) async {
    final TextEditingController textEditingController = TextEditingController(
      text: doc.name ?? "",
    );

    final FocusNode focusNode = FocusNode();

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Renomeara Documento',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(controller: textEditingController, focusNode: focusNode, autofocus: true),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text('Fechar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, textEditingController.text),
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<String?> name(BuildContext context) async {
    final TextEditingController textEditingController = TextEditingController(
      text: "",
    );

    final FocusNode focusNode = FocusNode();

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Nomeie o seu documento',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(controller: textEditingController, focusNode: focusNode, autofocus: true,),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Fechar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, textEditingController.text),
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<bool?> delete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Deletar documento?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => {Navigator.pop(context, false)},
                      child: const Text('Fechar'),
                    ),
                    ElevatedButton(
                      onPressed: () => {Navigator.pop(context, true)},
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> save(
    BuildContext context,
    Future<void> Function() save,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(Duration.zero);

    try {
      await save();
    } finally {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  static Future<void> showInfo(BuildContext context, DocumentModel doc) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              height: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Faz o dialog usar apenas o espaço necessário
                mainAxisAlignment: MainAxisAlignment.start, // Alinha os itens no topo (vertical)
                crossAxisAlignment: CrossAxisAlignment.start, // Alinha os itens na esquerda (horizontal)
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(onPressed: () => {Navigator.pop(context)}, icon: Icon(Icons.close))
                    ],
                  ),
                  Text("Dados:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Row(children: [Text("Nome: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("${doc.name}", style: TextStyle(fontSize: 20, color: Colors.black))]),
                  Row(children: [Text("Páginas: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("${doc.images.length}", style: TextStyle(fontSize: 20))]),
                  Row(children: [Text("Data de criação: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text("${doc.createdAt}", style: TextStyle(fontSize: 20))]),
                ],
              ),
            ),
          );
    }
    );
  }
}
