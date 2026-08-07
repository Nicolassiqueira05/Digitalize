import 'dart:io';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:digitalize/viewmodel/document_page_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DocumentPage extends StatelessWidget {
  final DocumentModel document;
  late final DocumentPageManager documentPageManager;

  DocumentPage({super.key, required this.document}) {
    documentPageManager = DocumentPageManager(document);
  }

  final PageController _pageController = PageController();
  void onPageChanged(int index){

  }

  @override
  Widget build(BuildContext context) {

    print("TOTAL IMAGES: ${documentPageManager.images.length}");

    print(documentPageManager.images);

    print(documentPageManager.document);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Documento"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: PageView.builder(
            controller: _pageController,
            onPageChanged: onPageChanged,
            itemCount: documentPageManager.images.length,
            itemBuilder: (context, index){

              final image = documentPageManager.images[index];

              return Padding(
                padding: EdgeInsets.all(10),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.contain,
                ),
              );
            }
        )
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () async {
                final confirmed = await DialogService.delete(context);

                if (confirmed == true) {
                  documentPageManager.deleteDocument();

                  if (!context.mounted) return;

                  Navigator.pop(context, true);
                }
              },
              icon: Icon(Icons.delete),
            ),
            IconButton(
                onPressed: () => {},
                icon: Icon(Icons.folder)),
            IconButton(
              onPressed: () => {documentPageManager.shareImage()},
              icon: Icon(Icons.share),
            ),
            IconButton(
              onPressed: () => {},
              icon: Icon(Icons.download),
            ),
          ],
        ),
      ),
    );
  }
}
