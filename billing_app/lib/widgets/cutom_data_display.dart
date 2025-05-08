import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String> onSubmitted;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? errorText;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;

  const CustomInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText = 'Enter text',
    this.onChanged,
    this.keyboardType,
    this.enabled = true,
    this.errorText,
    this.contentPadding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      enabled: enabled,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

// Example usage:
class InputShowcaseScreen extends StatelessWidget {
  const InputShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Input Showcase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInput(
              controller: controller,
              hintText: 'Enter store name',
              onSubmitted: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Submitted: $value')),
                );
              },
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: TextEditingController(),
              hintText: 'Enter amount',
              onSubmitted: (value) {},
              keyboardType: TextInputType.number,
              errorText: 'Invalid input',
            ),
          ],
        ),
      ),
    );
  }
}