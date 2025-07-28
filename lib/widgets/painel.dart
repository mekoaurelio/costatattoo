import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  final double width;
  final double height;

  const Panel({super.key,
    required this.child,
    required this.onClose,
    required this.width,
    required this.height
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fundo escuro semi-transparente
        GestureDetector(
          onTap: onClose,
          child: Container(),
        ),

        // Painel lateral à direita
        Align(
          alignment: Alignment.center,
          child: Material(
            elevation: 8,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
             // padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
