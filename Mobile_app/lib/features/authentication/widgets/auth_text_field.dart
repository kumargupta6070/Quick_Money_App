import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Next-Level FinTech Input Field with seamless dark styling, neon cyan active glow,
/// elegant vertical divider, and crystal-clear text visibility.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isPhone;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Widget? suffix;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.isPhone = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.suffix,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with glowing cyan dot
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isFocused ? const Color(0xFF00E5FF) : const Color(0xFF38BDF8),
                boxShadow: _isFocused
                    ? [
                        const BoxShadow(
                          color: Color(0xFF00E5FF),
                          blurRadius: 8,
                          spreadRadius: 1.5,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _isFocused ? const Color(0xFF00E5FF) : const Color(0xFFE2E8F0),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Animated glowing textfield container
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: const Color(0xFF0B132B).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused ? const Color(0xFF00E5FF) : const Color(0xFF1E293B),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Prefix section with vertical separator divider
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.prefixIcon,
                      size: 19,
                      color: _isFocused ? const Color(0xFF00E5FF) : const Color(0xFF94A3B8),
                    ),
                    if (widget.isPhone) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00E5FF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 22,
                      color: _isFocused
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                          : const Color(0xFF334155),
                    ),
                  ],
                ),
              ),

              // Expanded Text Field with explicitly disabled internal fills and borders
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword ? _obscureText : false,
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  inputFormatters: widget.inputFormatters,
                  maxLength: widget.maxLength,
                  cursorColor: const Color(0xFF00E5FF),
                  cursorWidth: 2.0,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                  decoration: InputDecoration(
                    // Explicitly override any theme-level fill & borders
                    filled: false,
                    fillColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  ),
                ),
              ),

              // Suffix Password Eye
              if (widget.isPassword)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    icon: Icon(
                      _obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 19,
                      color: _obscureText ? const Color(0xFF94A3B8) : const Color(0xFF00E5FF),
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                )
              else if (widget.suffix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: widget.suffix!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
