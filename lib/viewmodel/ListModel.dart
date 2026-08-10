import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:flutter/cupertino.dart';

class ListModel extends ChangeNotifier {
  final DatabaseManager databaseManager = DatabaseManager();
  List<DocumentModel> documentList = [];
  Set<DocumentModel> selectedDocuments = {};


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
    if (selectedDocuments.contains(doc)) {
      selectedDocuments.remove(doc);
    } else {
      selectedDocuments.add(doc);
    }
    notifyListeners();
  }

  Future<void> deleteSelectedDocuments() async {
    for (var doc in selectedDocuments){
      await databaseManager.deleteDocument(doc);
    }
    selectedDocuments.clear();

    await loadDocuments();
  }

}