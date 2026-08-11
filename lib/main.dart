import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/document_page.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:digitalize/viewmodel/ListModel.dart';
import 'package:digitalize/document_picker.dart';
import 'package:digitalize/viewmodel/document_list_controller.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ListModel>().loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ListModel>();

    final documentListController = DocumentListController(model: model);

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
            documentListController: documentListController,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: model.selectedDocuments.isEmpty
            ? () => documentListController.createDocument(context)
            : () => documentListController.deleteSelectedDocuments(context),
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
  final DocumentListController documentListController;

  DocumentItemWidget({
    super.key,
    required this.doc,
    required this.documentListController,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<ListModel>();


    if (!model.selectedDocuments.isNotEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () => {documentListController.loadDocument(context, doc)},
          onLongPress: () => {model.selectDocument(doc)},
          leading: const Icon(Icons.description),
          title: Text(doc.name),
          subtitle: Text(doc.createdAt),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => documentListController.rename(context, doc),
                icon: const Icon(Icons.drive_file_rename_outline),
              ),
              IconButton(
                onPressed: () => documentListController.delete(context, doc),
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
          onTap: () => model.selectDocument(doc),
          onLongPress: () => {},
          leading: model.isSelected(doc)
              ? Icon(Icons.check_circle_rounded)
              : Icon(Icons.circle_outlined),
          title: Text(doc.name),
          subtitle: Text(doc.createdAt),
        ),
      );
    }
  }
}
