import 'dart:io';
import 'dart:ui';
import 'package:crop_image/crop_image.dart';
import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/data/models/image_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DocumentPickerManager extends ChangeNotifier{
  final picker = ImagePicker();

  XFile? image;

  List<XFile?> images = [];

  List<CropController> controllers = [];

  int currentController = 0;

  bool vertical = true;

  final DatabaseManager databaseManager = DatabaseManager();

  void setCurrentController(int index){
    currentController = index;
    notifyListeners();
  }

  Future<void> takePicture() async {
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    if (image != null) {
        this.image = image;
        this.images.add(image);
        controllers.add(CropController());
    }
    notifyListeners();
  }

  void rotateRight() {}

  void setAspectRatio(double a, b) {
    if (a == 0) {
      controllers[currentController].aspectRatio = null;
    } else {
      controllers[currentController].aspectRatio = a / b;
    }
    notifyListeners();
  }

  Future<List<Uint8List>> getCroppedImages() async {

    List<Uint8List> croppedList = [];

    for(var i = 0; i < images.length; i++){
      final bitmap = await controllers[i].croppedBitmap();

      final data = await bitmap.toByteData(
        format: ImageByteFormat.png,
      );

      if(data == null) continue;

      print("Imagem $i convertida com sucesso");

      croppedList.add(data.buffer.asUint8List());

    }
    return croppedList;
  }

  Future<void> saveImage(List<Uint8List> bytes, String name) async {

    final dir = await getApplicationDocumentsDirectory();

    final now = DateTime.now().toLocal();

    final String createdAt = "${now.day}/${now.month}/${now.year}";

    DocumentModel d = DocumentModel(name: name, path: '', createdAt: createdAt);

    List<ImageModel> images = [];

    for(var i = 0; i < bytes.length; i++){
      final file = File('${dir.path}/imagem_${DateTime.now().millisecondsSinceEpoch}${i}.png');

      await file.writeAsBytes(bytes[i], flush: true);

      print("Existe? ${await file.exists()}");

      images.add(ImageModel(path: file.path));
    }

    d.images = images;

    await databaseManager.insertDocument(d);

  }
}