import 'package:booksy_app/add_book/add_book_screen.dart';
import 'package:booksy_app/book_details/book_details_screen.dart';
import 'package:booksy_app/services/book_service.dart';
import 'package:booksy_app/state.dart';
import 'package:flutter/material.dart';
import 'package:booksy_app/model/book.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookshelfBloc, BookshelfState>(
        builder: (context, bookshelfState) {
      var widget = bookshelfState.bookIds.isEmpty
          ? Center(
              child: Text(
                'Sin libros',
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            )
          : MyBooksGrid(bookshelfState.bookIds);
      return Column(
        children: [
          Expanded(child: widget),
          ElevatedButton(
            onPressed: () {
              _navigateToAddBookScreen(context);
            },
            child: const Text('Agregar libro'),
          ),
        ],
      );
    });
  }

  void _navigateToAddBookScreen(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddBookScreen()));
  }
}

class MyBooksGrid extends StatelessWidget {
  final List<String> bookIds;
  const MyBooksGrid(this.bookIds, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: bookIds.length,
        itemBuilder: (BuildContext context, int index) {
          return BookCoverItem(bookIds[index]);
        },
      ),
    );
  }
}

class BookCoverItem extends StatefulWidget {
  final String _bookId;
  const BookCoverItem(this._bookId, {super.key});

  @override
  State<BookCoverItem> createState() => _BookCoverItemState();
}

class _BookCoverItemState extends State<BookCoverItem> {
  Book? _book;

  @override
  void initState() {
    super.initState();
    _getBook(widget._bookId);
  }

  void _getBook(String bookId) async {
    var book = await BookService().getBook(bookId);
    setState(() {
      _book = book;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_book == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return InkWell(
      onTap: () {
        _openBookDetails(context, _book!);
      },
      child: Ink.image(
        fit: BoxFit.fill,
        image: _getImageWidget(_book!.coverUrl),
      ),
    );
  }

  void _openBookDetails(BuildContext context, Book book) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => BookDetailsScreen(book)));
  }

  _getImageWidget(String coverUrl) {
    if (coverUrl.startsWith('http')) {
      return NetworkImage(coverUrl);
    } else {
      return AssetImage(coverUrl);
    }
  }
}
