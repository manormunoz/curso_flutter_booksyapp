import 'dart:io';

import 'package:booksy_app/add_book/take_picture_screen.dart';
import 'package:booksy_app/services/book_service.dart';
import 'package:booksy_app/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar libro')),
      body: const AddBookForm(),
    );
  }
}

class AddBookForm extends StatefulWidget {
  const AddBookForm({super.key});

  @override
  State<AddBookForm> createState() => _AddBookFormState();
}

class _AddBookFormState extends State<AddBookForm> {
  final titileFieldController = TextEditingController();
  final authorFieldController = TextEditingController();
  final summaryFieldController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    if (_saving) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: titileFieldController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Título',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: authorFieldController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Autor',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: summaryFieldController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Resumen',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    _navigateTakePictureScreen(context);
                  },
                  child: SizedBox(
                    width: 150,
                    child: _getImageWidget(context),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveBook(context);
                  }
                },
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTakePictureScreen(BuildContext context) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TakePictureScreen(),
        ));
    setState(() {
      _imagePath = result;
    });
  }

  void _saveBook(BuildContext context) async {
    setState(() {
      _saving = true;
    });
    var title = titileFieldController.text;
    var author = authorFieldController.text;
    var summary = summaryFieldController.text;
    var newBookId = await BookService().saveBook(title, author, summary);
    if (_imagePath != null) {
      var imageUrl =
          await BookService().uploadBookCover(_imagePath!, newBookId);
      await BookService().updateCoverBook(newBookId, imageUrl);
    }
    if (!mounted) return;
    var bookshelfBloc = context.read<BookshelfBloc>();
    bookshelfBloc.add(AddBookToBookshelf(newBookId));
    Navigator.pop(context);
  }

  Widget _getImageWidget(BuildContext context) {
    if (_imagePath == null) {
      return Image.asset("assets/images/take_photo.jpg");
    }
    return Image.file(File(_imagePath!));
  }
}
