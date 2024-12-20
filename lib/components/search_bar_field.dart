import 'package:flutter/material.dart';

class SearchBarField extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final Color? backgroundColor;

  const SearchBarField({
    super.key,
    this.onSearchChanged,
    this.backgroundColor,
  });

  @override
  State<SearchBarField> createState() => _SearchBarFieldState();
}

class _SearchBarFieldState extends State<SearchBarField> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onSearchChanged,
      controller: searchController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    searchController.clear();
                  });
                },
                icon: const Icon(Icons.cancel_outlined),
              )
            : Icon(
                Icons.search,
                size: 25,
                color: Colors.black,
              ),
        filled: widget.backgroundColor != null,
        fillColor: widget.backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
      ),
    );
  }
}
