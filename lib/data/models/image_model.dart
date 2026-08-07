import 'dart:ui';

class ImageModel {
  final int? id;
  final int? documentId;
  final String path;

  ImageModel({this.id, this.documentId, required this.path});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'path': path,
    };
  }

  @override
  String toString() {
    return 'DocumentModel{id: $id, name: $documentId, path: $path';
  }


}