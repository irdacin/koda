import 'package:flutter/material.dart';
import 'package:koda/utils/app_colors.dart';

class InputField extends StatefulWidget {
  final String? labelText;
  final FocusNode? focusNode;
  final IconData? icon;
  final Widget? trailing;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  final void Function(String)? onChanged;
  final bool isVisible;
  final String? hintText;
  final String? errorText;

  const InputField({
    super.key,
    this.labelText,
    this.focusNode,
    this.icon,
    this.trailing,
    this.controller,
    this.validator,
    this.onChanged,
    this.isVisible = true,
    this.hintText,
    this.errorText,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool focusText = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(() {
      setState(() {
        focusText = widget.focusNode!.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    widget.focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) => widget.onChanged?.call(value),
      focusNode: widget.focusNode,
      style: TextStyle(
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        label: Text(widget.labelText ?? ""),
        labelStyle: TextStyle(
          color: focusText && widget.errorText == null ? Colors.black : null,
          fontWeight:
              focusText && widget.errorText == null ? FontWeight.bold : null,
        ),
        errorText: widget.errorText,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: const Icon(Icons.email),
        hintText: widget.hintText,
        prefixIconColor: widget.errorText != null ? Colors.red : null,
        suffixIcon: widget.trailing,
      ),
      obscureText: !widget.isVisible,
    );
  }
}
