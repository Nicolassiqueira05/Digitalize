import 'dart:io';
import 'dart:typed_data';
import 'package:digitalize/Data/Database/database.dart';
import 'package:digitalize/Data/Models/document_model.dart';
import 'package:digitalize/data/models/image_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:file_picker/file_picker.dart' as fp;

class DocumentPageManager extends ChangeNotifier {
  late DocumentModel document;
  late DatabaseManager databaseManager;
  late Uint8List pdf;
  late List<ImageModel> images;

  DocumentPageManager(DocumentModel doc){
    document = doc;
    images = doc.images;
    databaseManager = DatabaseManager();
  }

  String getImage(){
    return document.path;
  }

  void shareImage() async {

    final bytes = await generatePDF();

    final file = await createTempPdf(bytes);

    SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)])
    );
  }

  Future<void> deleteDocument() async {
    await databaseManager.deleteDocument(document);
  }

  Future<void> renameDocument(DocumentModel doc, String name) async {
    doc.name = name;
    await databaseManager.updateDocument(doc);
    notifyListeners();
  }

  Future<void> saveImage() async {
    final bytes = await generatePDF();
    final file = await createTempPdf(bytes);

    String? outputFile = await fp.FilePicker.saveFile(
      dialogTitle: 'Salvar PDF',
      fileName: 'documento.pdf',
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if(outputFile != null){
      final f = File(outputFile);
      await f.writeAsBytes(bytes);
      print('PDF salvo em: $outputFile');
    }

  }

  Future<Uint8List> generatePDF() async {
    final pdf = pw.Document();

    for(var i in document.images){
      final imageBytes = await File(i.path).readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final imageSimulator = frame.image;

      final width = imageSimulator.width.toDouble();
      final height = imageSimulator.height.toDouble();


      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(width, height),
          build: (_) => pw.Center(
            child: pw.Image(image),
          ),
        ),
      );
    }

  return await pdf.save();
  }

  Future<File> createTempPdf(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/document.pdf');

    await file.writeAsBytes(bytes);

    return file;
  }

}