import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? width;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final double top;
  final double bottom;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.black54,
    this.fontSize = 18,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.isLoading = false,
    this.top=20,
    this.bottom=30,
    this.width=200,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top:top,bottom:bottom),
      child:Container(
        width: width,
        child:ElevatedButton(

          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white, // Use provided color or default
            textStyle: TextStyle(fontSize: fontSize),
            shape: RoundedRectangleBorder(borderRadius: borderRadius!),

          ),
          onPressed: isLoading ? null : onPressed, // Disable button while loading
          child: isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) // Show loader
              : Text(text.tr, style: TextStyle(color: textColor)), // Use provided text color
        ) ,
      )


    );
  }
}