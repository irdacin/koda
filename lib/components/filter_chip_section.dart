import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:koda/utils/app_colors.dart';

class FilterChipSection extends StatefulWidget {
  final List<Widget> chipLabels;
  final void Function(dynamic)? onSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? labelColor;
  final Color? selectedLabelColor;
  final List<String>? dropdownItem;
  final InputDecoration? dropdownDecoration;
  final Color? iconColor;
  final Color? selectedIconColor;
  final double chipHeight;

  const FilterChipSection({
    super.key,
    this.chipLabels = const [],
    this.onSelected,
    this.backgroundColor,
    this.selectedColor,
    this.labelColor,
    this.selectedLabelColor,
    this.dropdownItem,
    this.dropdownDecoration,
    this.iconColor,
    this.selectedIconColor,
    this.chipHeight = 35,
  });

  @override
  State<FilterChipSection> createState() => _FilterChipSectionState();
}

class _FilterChipSectionState extends State<FilterChipSection> {
  int selectedIndex = 0;
  String? selectedValue;
  DateTime? pickedDate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 12,
        children: widget.chipLabels.asMap().entries.map((e) {
          final index = e.key;
          final labelWidget = e.value;
          bool isSelected = selectedIndex == index;

          Widget styledLabel = labelWidget;
          if (labelWidget is Icon) {
            styledLabel = Icon(
              labelWidget.icon,
              color: isSelected ? widget.selectedIconColor : widget.iconColor,
              size: isSelected ? 15 : labelWidget.size,
            );
          } else if (labelWidget is Text) {
            styledLabel = Text(
              labelWidget.data ?? "",
              style: TextStyle(
                fontSize: isSelected ? 15 : 12,
                color:
                    isSelected ? widget.selectedLabelColor : widget.labelColor,
                fontWeight: isSelected ? FontWeight.w900 : null
              ),
            );
          } else if (labelWidget is DropdownSearch<String>) {
            styledLabel = ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: widget.chipHeight,
                maxHeight: widget.chipHeight,
                maxWidth: 140,
              ),
              child: DropdownSearch<String>(
                decoratorProps: DropDownDecoratorProps(
                  decoration: widget.dropdownDecoration ??
                      const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                        border: OutlineInputBorder(),
                      ),
                  baseStyle: TextStyle(
                    fontSize: isSelected ? 15 : 12,
                    overflow: TextOverflow.ellipsis,
                    color: isSelected
                        ? widget.selectedLabelColor
                        : widget.labelColor,
                  ),
                ),
                items: (filter, loadProps) => widget.dropdownItem ?? [],
                suffixProps: DropdownSuffixProps(
                  dropdownButtonProps: DropdownButtonProps(
                    padding: EdgeInsets.zero,
                    iconClosed: Icon(
                      Icons.keyboard_arrow_down,
                      color: isSelected
                          ? widget.selectedIconColor
                          : widget.iconColor,
                    ),
                    iconOpened: Icon(
                      Icons.keyboard_arrow_up,
                      color: isSelected
                          ? widget.selectedIconColor
                          : widget.iconColor,
                    ),
                  ),
                ),
                onBeforePopupOpening: labelWidget.onBeforePopupOpening,
                selectedItem: selectedValue,
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  emptyBuilder: (context, searchEntry) {
                    return const SizedBox.shrink();
                  },
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: isSelected ? widget.selectedColor : null,
                          borderRadius: BorderRadius.only(
                            topLeft: item == widget.dropdownItem?.first
                                ? const Radius.circular(8)
                                : Radius.zero,
                            topRight: item == widget.dropdownItem?.first
                                ? const Radius.circular(8)
                                : Radius.zero,
                            bottomLeft: item == widget.dropdownItem?.last
                                ? const Radius.circular(8)
                                : Radius.zero,
                            bottomRight: item == widget.dropdownItem?.last
                                ? const Radius.circular(8)
                                : Radius.zero,
                          )),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? widget.selectedLabelColor
                              : widget.labelColor,
                        ),
                      ),
                    );
                  },
                  fit: FlexFit.loose,
                  menuProps: const MenuProps(
                    margin: EdgeInsets.only(top: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                onChanged: (value) async {
                  setState(() {
                    selectedValue = value;
                    selectedIndex = index;
                  });
                  widget.onSelected?.call(selectedValue);
                },
              ),
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (labelWidget is Icon) {
                await _pickDateTime();
                if (pickedDate == null) return;
                widget.onSelected?.call(pickedDate);
              } else if (labelWidget is Text) {
                _resetSelected();
                widget.onSelected?.call(labelWidget.data);
              }

              setState(() => selectedIndex = index);
            },
            child: Container(
              height: widget.chipHeight,
              decoration: BoxDecoration(
                color:
                    isSelected ? widget.selectedColor : widget.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              padding: labelWidget is DropdownSearch<String>
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: styledLabel,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _resetSelected() {
    setState(() {
      selectedValue = null;
      pickedDate = null;
    });
  }

  Future<void> _pickDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: pickedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      currentDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, widget) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.selected,
              surface: AppColors.secondary,
              onSurface: AppColors.text,
            ),
            dividerTheme: DividerThemeData(color: AppColors.secondary),
          ),
          child: widget!,
        );
      },
    );
    if (selectedDate != null) {
      setState(() => pickedDate = selectedDate);
    }
  }
}
