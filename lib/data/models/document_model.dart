import 'dart:ui';

import 'package:digitalize/data/models/image_model.dart';

class DocumentModel {
  final int? id;
  String name;
  final String path;
  final String createdAt;
  List<ImageModel> images;

  DocumentModel({
    this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    List<ImageModel>? images,
  }) : images = images ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'DocumentModel{id: $id, name: $name, path: $path, createdAt: ${createdAt}';
  }


}