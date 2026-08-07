import 'dart:io';
import 'dart:ui';
import 'package:crop_image/crop_image.dart';
import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/view/custom_widgets/dialog_service.dart';
import 'package:digitalize/viewmodel/document_picker_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DocumentPicker extends StatefulWidget {
  const DocumentPicker({super.key});

  @override
  State<StatefulWidget> createState() => _DocumentPickerState();
}

class _DocumentPickerState extends State<DocumentPicker> {
  final DocumentPickerManager documentPickerManager = DocumentPickerManager();

  bool aspectRatioRow = false;

  final PageController _pageController = PageController();

  int currentIndex = 0;

  void onPageChanged(int index) {
    documentPickerManager.setCurrentController(index);
    setState(() {
      currentIndex = index;
    });

    // Atualiza o controller da imagem atual
    //documentPickerManager.setImage(index);
  }

  void turnAspectRatioRow(bool b) {
    setState(() {
      aspectRatioRow = b;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      documentPickerManager.takePicture();
      setState(() {});
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: documentPickerManager,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: Icon(Icons.close),
            ),
            actions: [
              IconButton(
                onPressed: () async {

                  var cropFuture = documentPickerManager.getCroppedImages();

                  var nome = await DialogService.name(context);
                  if(nome == null) return;

                  var ci = await cropFuture;
                  if (ci == null) return;

                  print(ci);

                  await DialogService.save(context, () async {
                    await documentPickerManager.saveImage(ci, nome);
                  });

                  Navigator.pop(context, true);

                },
                icon: Icon(Icons.check),
              ),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: documentPickerManager.images.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : PageView.builder(
                          controller: _pageController,
                          onPageChanged: onPageChanged,
                          itemCount: documentPickerManager.images.length,
                          itemBuilder: (context, index){

                            final image = documentPickerManager.images[index];
                            final controller = documentPickerManager.controllers[index];

                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: CropImage(
                                key: ValueKey(image?.path),
                                controller: controller,
                                image: kIsWeb
                                    ? Image.network(image!.path)
                                    : Image.file(File(image!.path)),
                              ),
                            );
                          }
                      )
                    ),
                    aspectRatioRow
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsetsGeometry.only(bottom: 10),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                padding: EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () => {
                                        documentPickerManager.setAspectRatio(
                                          0,
                                          0,
                                        ),
                                      },
                                      child: Text(
                                        "Custom",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => {
                                        documentPickerManager
                                                .controllers[documentPickerManager.currentController]
                                                .aspectRatio =
                                            3.0 / 4.0,
                                      },
                                      child: Text(
                                        "3:4",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => {
                                        documentPickerManager
                                                .controllers[documentPickerManager.currentController]
                                                .aspectRatio =
                                            10.0 / 10.0,
                                      },
                                      child: Text(
                                        "1:1",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => {
                                        documentPickerManager
                                                .controllers[documentPickerManager.currentController]
                                                .aspectRatio =
                                            1.0 / 1.4,
                                      },
                                      child: Text(
                                        "A4",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).colorScheme.inversePrimary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () async => {documentPickerManager.takePicture()},
                  icon: Icon(Icons.add_a_photo),
                ),
                IconButton(
                  onPressed: () => {
                    turnAspectRatioRow(aspectRatioRow ? false : true),
                  },
                  icon: Icon(Icons.crop),
                  color: aspectRatioRow ? Colors.white70 : null,
                ),
                IconButton(
                  onPressed: () => {
                    documentPickerManager..controllers[documentPickerManager.currentController].rotateLeft(),
                  },
                  icon: Icon(Icons.rotate_90_degrees_ccw),
                ),
                IconButton(
                  onPressed: () => {
                    documentPickerManager..controllers[documentPickerManager.currentController].rotateRight(),
                  },
                  icon: Icon(Icons.rotate_90_degrees_cw),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
