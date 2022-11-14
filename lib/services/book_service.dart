import 'dart:io';

import 'package:booksy_app/model/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BookService {
  final booksRef = FirebaseFirestore.instance.collection('books').withConverter(
        fromFirestore: (snapshot, _) =>
            Book.formJson(snapshot.id, snapshot.data()!),
        toFirestore: (book, _) => book.toJson(),
      );

  Future<List<Book>> getLastBooks() async {
    var result = await booksRef.limit(3).get();
    List<Book> books = [];
    for (var doc in result.docs) {
      books.add(doc.data());
    }
    // await Future.delayed(const Duration(seconds: 2));
    return Future.value(books);
  }

  Future<Book> getBook(bookId) async {
    var result = await booksRef.doc(bookId).get();
    if (result.exists) {
      return result.data()!;
    }
    throw const HttpException("Book not found.");
  }

  Future<String> saveBook(String title, String author, String summary) async {
    var ref = FirebaseFirestore.instance.collection('books');
    var result = await ref.add({
      'name': title,
      'author': author,
      'summary': summary,
    });
    return result.id;
  }

  Future<String> uploadBookCover(String imagePath, String newBookId) async {
    try {
      var newBookRef = 'books/$newBookId.png';
      File image = File(imagePath);
      var task = await FirebaseStorage.instance.ref(newBookRef).putFile(image);
      debugPrint("Upload finalizado, path: ${task.ref}");
      return FirebaseStorage.instance.ref(newBookRef).getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<void> updateCoverBook(String newBookId, String imageUrl) async {
    var ref = FirebaseFirestore.instance.collection('books').doc(newBookId);
    await ref.update({
      'coverUrl': imageUrl,
    });
  }
}
