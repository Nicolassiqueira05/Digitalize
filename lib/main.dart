import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/document_page.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:digitalize/viewmodel/document_list_manager.dart';
import 'package:digitalize/view/custom_widgets/document_list.dart';
import 'package:digitalize/document_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digitalize',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      home: const MyHomePage(title: 'Digitalize'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DocumentListManager documentListManager = DocumentListManager();

  @override
  void initState() {
    super.initState();
    documentListManager.loadDocuments();
  }

  void _newDocument() async {
    var d = await Navigator.of(context).push(
      MaterialPageRoute<bool>(builder: (context) => const DocumentPicker()),
    );

    if(d == true){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Documento salvo'),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,

          margin: EdgeInsets.only(
            bottom: 1,
            left: 16,
            right: 16,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    documentListManager.loadDocuments();
  }

  void loadDocument(DocumentModel doc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DocumentPage(document: doc)),
    );

    if (result == true) {
      documentListManager.loadDocuments();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    documentListManager.loadDocuments();
  }

  DatabaseManager db = DatabaseManager();

  @override
  Widget build(BuildContext context) {
    print(documentListManager.documentList);
    return AnimatedBuilder(
      animation: documentListManager,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: DocumentListWidget(
            documents: documentListManager.documentList,
            selectedDocuments: documentListManager.selectedDocuments,
            select: documentListManager.selectDocument,
            deleteDocument: documentListManager.deleteDocument,
            renameDocument: documentListManager.renameDocument,
            loadDocument: loadDocument,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: documentListManager.selectedDocuments.isEmpty
                ? _newDocument
                : () async {
                    final confirmed = await DialogService.delete(context);
                    if (confirmed == true) {
                      documentListManager.deleteSelectedDocuments();
                    }
                  },
            tooltip: documentListManager.selectedDocuments.isEmpty
                ? 'Digitalize um novo documento'
                : 'Delete todos os documentos selecionados',
            child: documentListManager.selectedDocuments.isEmpty
                ? const Icon(Icons.add)
                : const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
