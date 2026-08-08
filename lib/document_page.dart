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

    return
      AnimatedBuilder(
          animation: documentPageManager,
          builder: (context, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text(documentPageManager.document.name),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
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
                        onPressed: () async {
                          final t = await DialogService.rename(context, documentPageManager.document);
                          if(t == null) return;
                          await documentPageManager.renameDocument(documentPageManager.document, t);
                        },
                        icon: Icon(Icons.drive_file_rename_outline)),
                    IconButton(
                      onPressed: () async {
                        DialogService.showInfo(context, documentPageManager.document);
                      },
                      icon: Icon(Icons.info_outline),
                    ),
                    IconButton(
                      onPressed: () => {documentPageManager.shareImage()},
                      icon: Icon(Icons.share),
                    ),
                  ],
                ),
              ),
            );
          });
  }
}
