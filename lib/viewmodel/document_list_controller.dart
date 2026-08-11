import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/document_page.dart';
import 'package:digitalize/document_picker.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:digitalize/viewmodel/ListModel.dart';
import 'package:flutter/cupertino.dart';
import "dart:io";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DocumentListController {
  final ListModel model;

  DocumentListController({
    required this.model,
  });

  Future<void> createDocument(BuildContext context) async {
    var d = await Navigator.of(context).push(
      MaterialPageRoute<bool>(builder: (context) => const DocumentPicker()),
    );

    if (d == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Documento salvo'),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,

          margin: EdgeInsets.only(bottom: 1, left: 16, right: 16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
    await model.loadDocuments();
  }

  Future<void> loadDocument(BuildContext context, DocumentModel doc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DocumentPage(document: doc)),
    );

    if (result == true) {
      await model.loadDocuments();
    }
  }

  Future<void> rename(BuildContext context, DocumentModel doc) async {
    final t = await DialogService.rename(context, doc);
    if (t == null) return;
    await model.renameDocument(doc, t);
  }

  Future<void> delete(BuildContext context, DocumentModel doc) async {
    final confirmed = await DialogService.delete(context);

    if (confirmed == true) {
      await model.deleteDocument(doc);
    }
  }

  Future<void> deleteSelectedDocuments(BuildContext context) async {
    final confirmed = await DialogService.delete(context);
    if(confirmed == true){
      await model.deleteSelectedDocuments();
    }
  }

}