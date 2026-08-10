import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/document_page.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:digitalize/viewmodel/ListModel.dart';
import 'package:digitalize/viewmodel/document_list_manager.dart';
import 'package:digitalize/view/custom_widgets/document_list.dart';
import 'package:digitalize/document_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
        create: (context) => ListModel(),
        child: const MyApp()
      )
  );
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

  @override
  void initState() {
    super.initState();
    //documentListManager.loadDocuments();
    Future.microtask(() {
      context.read<ListModel>().loadDocuments();
    });
    
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

    context.read<ListModel>().loadDocuments();
  }

  void loadDocument(DocumentModel doc) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DocumentPage(document: doc)),
    );

    if (result == true) {
      context.read<ListModel>().loadDocuments();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ListModel>().loadDocuments();
  }

  DatabaseManager db = DatabaseManager();

  @override
  Widget build(BuildContext context) {

    final model = context.watch<ListModel>();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: DocumentListWidget(
            documents: model.documentList,
            selectedDocuments: model.selectedDocuments,
            select: model.selectDocument,
            deleteDocument: model.deleteDocument,
            renameDocument: model.renameDocument,
            loadDocument: loadDocument,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: model.selectedDocuments.isEmpty
                ? _newDocument
                : () async {
                    final confirmed = await DialogService.delete(context);
                    if (confirmed == true) {
                      model.deleteSelectedDocuments();
                    }
                  },
            tooltip: model.selectedDocuments.isEmpty
                ? 'Digitalize um novo documento'
                : 'Delete todos os documentos selecionados',
            child: model.selectedDocuments.isEmpty
                ? const Icon(Icons.add)
                : const Icon(Icons.delete),
          ),
        );
  }
}
