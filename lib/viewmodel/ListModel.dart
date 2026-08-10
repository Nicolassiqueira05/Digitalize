import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:flutter/cupertino.dart';

class ListModel extends ChangeNotifier {
  final DatabaseManager databaseManager = DatabaseManager();
  List<DocumentModel> documentList = [];
  Set<int> selectedDocuments = {};


  Future<void> loadDocuments() async {
    List<DocumentModel> t = await databaseManager.getDocuments();
    documentList = t;
    notifyListeners();
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    await databaseManager.deleteDocument(doc);
    await loadDocuments();
  }

  Future<void> renameDocument(DocumentModel doc, String name) async {
    doc.name = name;
    await databaseManager.updateDocument(doc);
    await loadDocuments();
  }

  Future<void> DebugDB() async {
    await databaseManager.debugDB();
  }

  //Selection

  void selectDocument(DocumentModel doc) {
    if (selectedDocuments.contains(doc.id)) {
      selectedDocuments.remove(doc.id);
    } else {
      selectedDocuments.add(doc.id ?? 0);
    }
    notifyListeners();
  }

  Future<void> deleteSelectedDocuments() async {
    for (var id in selectedDocuments){
      await databaseManager.deleteDocument(documentList.firstWhere((e) => e.id == id));
    }
    selectedDocuments.clear();

    await loadDocuments();
  }

}