import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:koda/helpers/app_colors.dart';

class MultiDropdown extends StatefulWidget {
  final List<String> items;
  final bool searchEnabled;
  final MultiSelectController? controller;
  final bool closeOnBackButton;

  const MultiDropdown({
    super.key,
    required this.items,
    this.searchEnabled = true,
    this.controller,
    this.closeOnBackButton = false,
  });

  @override
  State<MultiDropdown> createState() => _MultiDropdownState();
}

class _MultiDropdownState extends State<MultiDropdown> {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();
  late final _dropdownController = widget.controller ?? MultiSelectController();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (_dropdownController.isDisposed) {
      throw StateError("DropdownController is disposed");
    }

    if (!_dropdownController.initialized) {
      _dropdownController
        ..initialize()
        ..setItems(widget.items);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropdownController..addListener(_controllerListener);
      // .._setOnSelectionChange(widget.onSelectionChange)
      // .._setOnSearchChange(widget.onSearchChange);

      _listenBackButton();
    });
  }

  void _listenBackButton() {
    if (!widget.closeOnBackButton) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _registerBackButtonDispatcherCallback();
      } catch (e) {
        debugPrint('Error: $e');
      }
    });
  }

  void _registerBackButtonDispatcherCallback() {
    final rootBackDispatcher = Router.of(context).backButtonDispatcher;

    if (rootBackDispatcher != null) {
      rootBackDispatcher.createChildBackButtonDispatcher()
        ..addCallback(() {
          if (_dropdownController.isOpen) {
            _dropdownController.closeDropdown();
          }

          return Future.value(true);
        })
        ..takePriority();
    }
  }

  void _controllerListener() {
    if (_dropdownController.isOpen) {
      _portalController.show();
    } else {
      _dropdownController.clearSearchQuery();
      _portalController.hide();
    }
  }

  @override
  void dispose() {
    _dropdownController.removeListener(_controllerListener);

    if (widget.controller == null) {
      _dropdownController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
        initialValue: _dropdownController.selectedItems,
        builder: (context) {
          return OverlayPortal(
            controller: _portalController,
            overlayChildBuilder: (context) {
              final renderBox = context.findRenderObject() as RenderBox?;

              if (renderBox == null || !renderBox.attached) {
                return const SizedBox();
              }

              final renderBoxSize = renderBox.size;
              final renderBoxOffset = renderBox.localToGlobal(Offset.zero);

              final availableHeight = MediaQuery.of(context).size.height;
                  // renderBoxOffset.dy -
                  // renderBoxSize.height;

              final showOnTop = availableHeight < 400;
              print(renderBoxSize.height);

              return SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _handleOutsideTap,
                      ),
                    ),
                    CompositedTransformFollower(
                      link: _layerLink,
                      showWhenUnlinked: false,
                      targetAnchor:
                          showOnTop ? Alignment.topLeft : Alignment.bottomLeft,
                      followerAnchor:
                          showOnTop ? Alignment.bottomLeft : Alignment.topLeft,
                      offset: Offset.zero,
                      child: RepaintBoundary(
                        child: Material(
                          elevation: 1,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          color: AppColors.main,
                          surfaceTintColor: AppColors.main,
                          child: Focus(
                            canRequestFocus: false,
                            skipTraversal: true,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                color: AppColors.main,
                                backgroundBlendMode: BlendMode.dstATop,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: 200,
                                maxHeight: 400,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // if (widget.searchEnabled)
                                  //   _SearchField(
                                  //     decoration: searchDecoration,
                                  //     onChanged: _onSearchChange,
                                  //   ),
                                  // if (decoration.header != null)
                                  //   Flexible(child: decoration.header!),
                                  Flexible(
                                    child: ListView.separated(
                                      separatorBuilder: (_, __) =>
                                          const SizedBox.shrink(),
                                      shrinkWrap: true,
                                      itemCount: widget.items.length,
                                      itemBuilder: (_, int index) =>
                                          _buildOption(index),
                                    ),
                                  ),
                                  // if (items.isEmpty && searchEnabled)
                                  //   Padding(
                                  //     padding: const EdgeInsets.all(12),
                                  //     child: Text(
                                  //       'No items found',
                                  //       textAlign: TextAlign.center,
                                  //       style: theme.textTheme.bodyMedium,
                                  //     ),
                                  //   ),
                                  // if (decoration.footer != null)
                                  //   Flexible(child: decoration.footer!),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: CompositedTransformTarget(
              link: _layerLink,
              child: ListenableBuilder(
                listenable: Listenable.merge([_dropdownController]),
                builder: (_, __) {
                  return InkWell(
                    onTap: _handleTap,
                    child: Text("helo"),
                  );
                },
              ),
            ),
          );
        });
  }

  void _handleTap() {
    if (_portalController.isShowing && _dropdownController.isOpen) return;
    print("kena tappp");

    _dropdownController.openDropdown();
  }

  Widget _buildOption(int index) {
    final option = widget.items[index];

    // final tileColor = option.selected
    //         ? dropdownItemDecoration.selectedBackgroundColor
    //         : dropdownItemDecoration.backgroundColor;

    // final trailing = option.disabled
    //     ? dropdownItemDecoration.disabledIcon
    //     : option.selected
    //         ? dropdownItemDecoration.selectedIcon
    //         : null;

    return ListTile(
      title: Text(option),
      // trailing: trailing,
      dense: true,
      autofocus: true,
      // enabled: !option.disabled,
      // selected: option.selected,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      focusColor: AppColors.main.withAlpha(100),
      selectedColor: AppColors.selected,
      textColor: AppColors.text,
      onTap: () {
        print("kena tap");
        _handleDropdownItemTap(option);
        return;
      },
    );
  }

  void _handleDropdownItemTap(String item) {
    // if (widget.singleSelect) {
    //   _dropdownController._toggleOnly(item);
    // } else {
    //   _dropdownController.toggleWhere((element) => element == item);
    // }
    // _formFieldKey.currentState?.didChange(_dropdownController.selectedItems);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropdownController.closeDropdown();
    });
  }

  void _handleOutsideTap() {
    if (!_dropdownController.isOpen) return;

    _dropdownController.closeDropdown();
  }
}

class MultiSelectController extends ChangeNotifier {
  bool initialized = false;

  void initialize() {
    initialized = true;
  }

  final List<String> _items = [];
  List<String> _filteredItems = [];
  String _searchQuery = '';

  List<String> get items => _searchQuery.isEmpty ? _items : _filteredItems;
  List<String> get selectedItems => _items.where((element) => true).toList();
  List<String> get _selectedValues => selectedItems.map((e) => e).toList();

  bool _open = false;
  bool get isOpen => _open;

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  void Function(List<String> selectedItems)? _onSelectionChanged;

  ValueChanged<String>? _onSearchChanged;

  void setItems(List<String> options) {
    _items
      ..clear()
      ..addAll(options);
    notifyListeners();
    _onSelectionChanged?.call(_selectedValues);
  }

  // void selectAll() {
  //   _items = _items
  //       .map(
  //         (element) =>
  //             !element.selected ? element.copyWith(selected: true) : element,
  //       )
  //       .toList();
  //   notifyListeners();
  //   _onSelectionChanged?.call(_selectedValues);
  // }

  // void selectAtIndex(int index) {
  //   if (index < 0 || index >= _items.length) return;

  //   // final item = _items[index];

  //   // if (item.disabled || item.selected) return;

  //   selectWhere((element) => element == _items[index]);
  // }

  // /// deselects all the items.
  // void toggleWhere(bool Function(String item) predicate) {
  //   _items = _items
  //       .map(
  //         (element) => predicate(element)
  //             ? element.copyWith(selected: !element.selected)
  //             : element,
  //       )
  //       .toList();
  //   if (_searchQuery.isNotEmpty) {
  //     _filteredItems = _items
  //         .where(
  //           (item) =>
  //               item.toLowerCase().contains(_searchQuery.toLowerCase()),
  //         )
  //         .toList();
  //   }
  //   notifyListeners();
  //   _onSelectionChanged?.call(_selectedValues);
  // }

  // void selectWhere(bool Function(String item) predicate) {
  //   _items = _items
  //       .map(
  //         (element) => predicate(element) && !element.selected
  //             ? element.copyWith(selected: true)
  //             : element,
  //       )
  //       .toList();
  //   notifyListeners();
  //   _onSelectionChanged?.call(_selectedValues);
  // }

  // void _toggleOnly(String item) {
  //   _items = _items
  //       .map(
  //         (element) => element == item
  //             ? element.copyWith(selected: !element.selected)
  //             : element.copyWith(selected: false),
  //       )
  //       .toList();

  //   notifyListeners();
  //   _onSelectionChanged?.call(_selectedValues);
  // }

  /// unselects the items that satisfy the predicate.
  ///
  /// The [predicate] parameter is a function that takes a [DropdownItem] and returns a boolean.
  // void unselectWhere(bool Function(String item) predicate) {
  //   _items = _items
  //       .map(
  //         (element) => predicate(element) && element.selected
  //             ? element.copyWith(selected: false)
  //             : element,
  //       )
  //       .toList();
  //   notifyListeners();
  //   _onSelectionChanged?.call(_selectedValues);
  // }

  void openDropdown() {
    if (_open) return;

    _open = true;
    notifyListeners();
  }

  void closeDropdown() {
    if (!_open) return;

    _open = false;
    notifyListeners();
  }

  void _setOnSelectionChange(Function(List<String>)? onSelectionChanged) {
    _onSelectionChanged = onSelectionChanged;
  }

  void _setOnSearchChange(ValueChanged? onSearchChanged) {
    _onSearchChanged = onSearchChanged;
  }

  void _setSearchQuery(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      _filteredItems = _items
          .where(
            (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    _onSearchChanged?.call(query);
    notifyListeners();
  }

  void clearSearchQuery({bool notify = false}) {
    _searchQuery = '';
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    super.dispose();
    _isDisposed = true;
  }

  @override
  String toString() {
    return 'MultiSelectController(options: $_items, open: $_open)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MultiSelectController &&
        listEquals(other._items, _items) &&
        other._open == _open;
  }

  @override
  int get hashCode => _items.hashCode ^ _open.hashCode;
}
