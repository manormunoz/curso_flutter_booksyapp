import 'package:flutter/material.dart';

import 'package:booksy_app/model/book_category.dart';
import 'package:booksy_app/utils.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookCategoriesGrid();
  }
}

class BookCategoriesGrid extends StatelessWidget {
  const BookCategoriesGrid({super.key});

  final List<BookCategory> _categories = const [
    BookCategory(1, "Categoria 1", "#A9CCE3"),
    BookCategory(2, "Categoria 2", "#C5F0B3"),
    BookCategory(3, "Categoria 3", "#F0B3E1"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: _categories.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          return TileCategory(_categories[index]);
        },
      ),
    );
  }
}

class TileCategory extends StatelessWidget {
  final BookCategory _category;
  const TileCategory(this._category, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: () {
          _navigateBooksWithCateory();
        },
        child: Container(
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: hexToColor(_category.colorBg),
          ),
          child: Text(
            _category.name,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _navigateBooksWithCateory() {}
}
