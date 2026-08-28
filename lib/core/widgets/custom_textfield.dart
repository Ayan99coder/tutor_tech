import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool showToggle;
  final int maxLines;
  final IconData? prefixIcon;
  final bool enabled;
  final void Function(String)? onChanged;
  final String? errorText;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showToggle = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.enabled = true,
    this.onChanged,
    this.errorText,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;
  late FocusNode _effectiveFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: AppColors.secondary.withAlpha(38),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: TextFormField(
            focusNode: _effectiveFocusNode,
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            obscureText: _isObscured,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
              errorText: widget.errorText,
              errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: _isFocused ? AppColors.secondary : AppColors.primary, size: 20)
                  : null,
              suffixIcon: widget.showToggle
                  ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
                  : null,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
