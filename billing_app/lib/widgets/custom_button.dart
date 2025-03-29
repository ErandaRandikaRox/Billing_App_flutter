import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? elevation;
  final double? borderRadius;
  final bool isOutlined;
  final bool isGradient;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.elevation,
    this.borderRadius,
    this.isOutlined = false,
    this.isGradient = false,
    this.width,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Define default colors
    final defaultBackgroundColor =
        isGradient ? Colors.deepPurple : (backgroundColor ?? Colors.deepPurple);
    final defaultTextColor = textColor ?? Colors.white;
    final defaultIconColor = iconColor ?? Colors.white;

    // Create gradient if needed
    final decoration =
        isGradient
            ? BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 15),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            )
            : null;

    // Button style based on outlined or solid
    final buttonStyle =
        isOutlined
            ? ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: defaultBackgroundColor,
              elevation: elevation ?? 0,
              shadowColor: Colors.transparent,
              side: BorderSide(color: defaultBackgroundColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 15),
              ),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            )
            : ElevatedButton.styleFrom(
              backgroundColor:
                  isGradient ? Colors.transparent : defaultBackgroundColor,
              foregroundColor: defaultTextColor,
              elevation: elevation ?? 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 15),
              ),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            );

    return Container(
      width: width,
      decoration: decoration,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isOutlined ? defaultBackgroundColor : defaultIconColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOutlined ? defaultBackgroundColor : defaultTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage in another file:
class ButtonShowcaseScreen extends StatelessWidget {
  const ButtonShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Button Showcase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Solid Gradient Button
            CustomButton(
              text: 'Gradient Button',
              icon: Icons.add_circle,
              onPressed: () {},
              isGradient: true,
            ),
            const SizedBox(height: 16),

            // Outlined Button
            CustomButton(
              text: 'Outlined Button',
              icon: Icons.edit,
              onPressed: () {},
              isOutlined: true,
            ),
            const SizedBox(height: 16),

           
            CustomButton(
              text: 'Custom Color',
              icon: Icons.save,
              onPressed: () {},
              backgroundColor: Colors.teal,
              borderRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
