import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextFiel extends StatelessWidget {
  CustomTextFiel({
    required this.label,
    this.hintText = '',
    this.prefixIcon,
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
    this.obrigatorio = true,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.controller,
    this.textAlign=TextAlign.start,
    this.prefixIconColor = Colors.grey,
    this.iconSize = 30,
    this.prefixIconOnPressed,
    this.onChanged,
    this.obscureText=false,
    this.onToggleVisibility,
    this.suffixIcon,
    //  this.validator
  });

  double top = 0;
  double bottom = 0;
  double left = 0;
  double right = 0;
  bool? obrigatorio = true;
  String label;
  final String hintText;
  final TextInputType keyboardType;
  final dynamic inputFormatters;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color prefixIconColor;
  final double iconSize;
  TextAlign? textAlign;
  final Function()? prefixIconOnPressed;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double adjustedIconSize = size.width > 450 ? iconSize : size.width < 290 ? 16 : iconSize;
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        textAlign: textAlign!,
        obscureText: obscureText,
        validator: (value) {
          if (value!.isEmpty && obrigatorio == true) {
            return 'mandatory_field'.tr;
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
             borderSide: const BorderSide(color: Colors.black),
             borderRadius: BorderRadius.circular(15),
          ),
          counterText: '',
          prefixIcon: prefixIcon!=null
              ? GestureDetector(
            onTap: prefixIconOnPressed,
            child: Icon(
              prefixIcon,
              size: adjustedIconSize,
              color: prefixIconColor,
            ),
          )
              : null,

            suffixIcon: suffixIcon != null ? IconButton(
              icon: Icon(suffixIcon,color: Colors.grey,),
              onPressed: onToggleVisibility?? null,
            ):null

        )
        )
    );
  }
}