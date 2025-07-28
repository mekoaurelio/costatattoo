import 'package:flutter/material.dart';

abstract class FormFieldData {
  final String controllerName;
  final String label;
  final String tipo;

  FormFieldData({
    required this.controllerName,
    required this.label,
    required this.tipo,
  });
}

class TextFormFieldData extends FormFieldData {
  final String hintText;
  final IconData? prefixIcon;
  final dynamic inputFormatters;
  final bool obrigatorio;

  TextFormFieldData({
    required String controllerName,
    required String label,
    required String tipo,
    this.inputFormatters,
    this.prefixIcon,
    this.hintText = '',
    this.obrigatorio=true,
  }) : super(controllerName: controllerName, label: label,tipo: tipo);
}

class DropdownFormFieldData extends FormFieldData {
  final String hint;
  final List<Map<String, dynamic>> items;
  final String idField;
  final String displayField;
  final bool obrigatorio;
  final String? value;
  final Function(String?)? onChanged;

  DropdownFormFieldData({
    required String controllerName,
    required String label,
    required String tipo,
    required this.hint,
    required this.items,
    required this.idField,
    required this.displayField,
    this.obrigatorio=false,
    this.value,
    this.onChanged,
  }) : super(controllerName: controllerName, label: label,tipo: tipo);
}