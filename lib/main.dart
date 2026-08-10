import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/document_page.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:digitalize/viewmodel/ListModel.dart';
import 'package:digitalize/document_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ListModel(),
      child: const MyApp(),
    ),
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
    context.read<ListModel>().loadDocuments();
  }

  void _newDocument() async {
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
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: model.documentList.length,
        itemBuilder: (context, index) {
          return DocumentItemWidget(
            doc: model.documentList[index],
            selectMode: model.selectedDocuments.isNotEmpty,
            selected: model.selectedDocuments.contains(
              model.documentList[index].id,
            ),
            select: () => model.selectDocument(model.documentList[index]),
            deleteDocument: () =>
                model.deleteDocument(model.documentList[index]),
            renameDocument: model.renameDocument,
            loadDocument: loadDocument,
          );
        },
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
                  if (t == null) return;
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
