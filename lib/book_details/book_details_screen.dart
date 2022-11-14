import 'package:booksy_app/model/book.dart';
import 'package:booksy_app/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book _book;
  const BookDetailsScreen(this._book, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          BookCoverWidget(_book.coverUrl),
          BookInfoWidget(_book),
          BookActionsWidget(_book.id),
        ]),
      ),
    );
  }
}

class BookActionsWidget extends StatelessWidget {
  final String bookId;
  const BookActionsWidget(this.bookId, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookshelfBloc, BookshelfState>(
      builder: (context, bookshelfState) {
        if (bookshelfState.bookIds.contains(bookId)) {
          return ElevatedButton(
              onPressed: () {
                _removeFromBookshelf(context, bookId);
              },
              child: const Text('Quitar'));
        }
        return ElevatedButton(
            onPressed: () {
              _addToBookshelf(context, bookId);
            },
            child: const Text('Agregar'));
      },
    );
  }

  void _addToBookshelf(BuildContext context, String bookId) {
    var bookshelfBloc = context.read<BookshelfBloc>();
    bookshelfBloc.add(AddBookToBookshelf(bookId));
  }

  void _removeFromBookshelf(BuildContext context, String bookId) {
    var bookshelfBloc = context.read<BookshelfBloc>();
    bookshelfBloc.add(RemoveBookFromBookshelf(bookId));
  }
}

class BookInfoWidget extends StatelessWidget {
  final Book _book;
  const BookInfoWidget(this._book, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _book.title,
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 5),
          Text(
            _book.author,
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 20),
          Text(
            _book.description,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}

class BookCoverWidget extends StatelessWidget {
  final String _coverUrl;
  const BookCoverWidget(this._coverUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Image.asset(_coverUrl),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 20,
          ),
        ],
      ),
    );
  }
}
