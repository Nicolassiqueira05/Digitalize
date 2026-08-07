import 'dart:async';

import 'package:digitalize/data/models/image_model.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:digitalize/Data/Models/document_model.dart';

class DatabaseManager {

  late Future<Database> db;

  Future<Database>  getDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), "documents_database.db"),
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE documents(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, path TEXT, createdAt TEXT)');
        await db.execute('CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, documentID INTEGER, path TEXT, FOREIGN KEY (documentID) REFERENCES documents(id) ON DELETE CASCADE)');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS images');
        await db.execute('DROP TABLE IF EXISTS documents');

        await db.execute('CREATE TABLE documents(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, path TEXT, createdAt TEXT)');
        await db.execute('CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, documentID INTEGER, path TEXT, FOREIGN KEY (documentID) REFERENCES documents(id) ON DELETE CASCADE)');
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      version: 8,
    );
  }

  DatabaseManager(){
    db = getDatabase();
  }

  Future<int> insertDocument(DocumentModel d) async {
    final database = await db;
    int documentId = await database.insert('documents', d.toMap(), conflictAlgorithm: ConflictAlgorithm.abort,);
    for(var image in d.images){
      await database.insert('images',
        {
          'documentID': documentId,
          'path': image.path,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,);
    }
    return documentId;
  }

  Future<void> deleteDocument(DocumentModel d) async {
    final database = await db;

    await database.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [d.id],
    );
  }

  Future<void> debugDB() async {
    final database = await db;

    final docs = await database.rawQuery('SELECT * FROM documents');
    final imgs = await database.rawQuery('SELECT * FROM images');

    print("===== DOCUMENTS =====");
    for (var d in docs) {
      print(d);
    }

    print("===== IMAGES =====");
    for (var i in imgs) {
      print(i);
    }
  }

  Future<void> updateDocument(DocumentModel d) async {
    final database = await db;

    for(var image in d.images){
      await database.insert('images',
        {
          'documentID': d.id,
          'path': image.path,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,);
    }

    await database.update(
      'documents',
      d.toMap(),
      where: 'id = ?',
      whereArgs: [d.id],
    );
  }
  
  Future<List<DocumentModel>> getDocuments() async {
    final database = await db;
    
    final documentList = await database.query('documents');

    List<DocumentModel> result = [];

    for(var doc in documentList){
      int id = doc['id'] as int;

      final imagesData = await database.query(
        'images',
        where: 'documentID = ?',
        whereArgs: [id],
      );

      List<ImageModel> imagesList = imagesData.map((img) {
        return ImageModel(
            id: img['id'] as int?,
            documentId: img['documentID'] as int?,
            path: img['path'] as String,
        );
      }).toList();

      result.add(DocumentModel
        (
          id: id,
          name: doc['name'] as String,
          path: doc['path'] as String,
          createdAt: doc['createdAt'] as String,
          images: imagesList,
        )
      );
    }

    return result;
  }

}