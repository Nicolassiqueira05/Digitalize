import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/document_picker.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class DocumentListWidget extends StatelessWidget {
  final List<DocumentModel> documents;
  final Set<DocumentModel> selectedDocuments;
  final Function(DocumentModel) select;
  final Function(DocumentModel) deleteDocument;
  final Function(DocumentModel, String) renameDocument;
  final Function(DocumentModel) loadDocument;

  const DocumentListWidget({
    super.key,
    required this.documents,
    required this.selectedDocuments,
    required this.select,
    required this.deleteDocument,
    required this.renameDocument,
    required this.loadDocument,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return DocumentItemWidget(
          doc: documents[index],
          selectMode: selectedDocuments.isNotEmpty,
          selected: selectedDocuments.contains(documents[index]),
          select: () => select(documents[index]),
          deleteDocument: () => deleteDocument(documents[index]),
          renameDocument: renameDocument,
          loadDocument: loadDocument,
        );
      },
    );
  }
}

class DocumentItemWidget extends StatelessWidget {
  final DocumentModel doc;

  final bool selectMode;
  final bool selected;
  final Function() select;
  final Function() deleteDocument;
  final Function(DocumentModel, String) renameDocument;
  final Function(DocumentModel) loadDocument;

  DialogService dialogService = DialogService();

  DocumentItemWidget({
    super.key,
    required this.doc,
    required this.selectMode,
    required this.selected,
    required this.select,
    required this.deleteDocument,
    required this.renameDocument,
    required this.loadDocument,
  });

  @override
  Widget build(BuildContext context) {
    if (!selectMode) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () => {loadDocument(doc)},
          onLongPress: select,
          leading: const Icon(Icons.description),
          title: Text(doc.name),
          subtitle: Text(doc.createdAt),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final t = await DialogService.rename(context, doc);
                  if(t == null) return;
                  await renameDocument(doc, t);
                },
                icon: const Icon(Icons.drive_file_rename_outline),
              ),
              IconButton(
                onPressed: () async {
                  final confirmed = await DialogService.delete(context);
                  
                  if (confirmed == true) {
                    await deleteDocument();
                  }
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: select,
          onLongPress: () => {},
          leading: selected
              ? Icon(Icons.check_circle_rounded)
              : Icon(Icons.circle_outlined),
          title: Text(doc.name),
          subtitle: Text(doc.createdAt),
        ),
      );
    }
  }
}
