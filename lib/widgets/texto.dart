import 'package:flutter/material.dart';

class Texto extends StatelessWidget {
  final String tit;
  final double tam;
  final Color cor;
  final bool negrito;
  final TextAlign? alin;
  final int linhas;
  final double top, bottom, left, right;
  final IconData? icone;  // Alterado para nullable
  final VoidCallback? aoClicarIcone;
  final String? tooltip;  // Alterado para nullable
  final FontWeight? fontWeight;
  final IconData? prefixIcon;
  final Color? iconColor;

  Texto({
    required this.tit,
    this.tam = 15,
    this.cor = Colors.black54,
    this.negrito = false,
    this.alin,
    this.linhas = 1,
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
    this.icone,  // Removido o valor padrão
    this.aoClicarIcone,
    this.tooltip = 'Editar',
    this.fontWeight,
    this.prefixIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: top,
          bottom: bottom,
          left: left,
          right: right
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[  // Verificação simplificada
            SizedBox(width: 15),
            IconButton(
              icon: Icon(prefixIcon, size: tam + 2,color: iconColor ?? Colors.grey),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: aoClicarIcone,
              //tooltip: tooltip,
            ),
          ],
          if (prefixIcon != null)
            SizedBox(width: 5,),
          Flexible(
            child: Text(
              tit,
              textAlign: alin,
              maxLines: linhas,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: tam,
                color: cor,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
            ),
          ),
          if (icone != null) ...[  // Verificação simplificada
            SizedBox(width: 5),
            IconButton(
              icon: Icon(icone, size: tam + 2, color: iconColor ?? Colors.grey),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: aoClicarIcone,
              tooltip: tooltip,
            ),
          ],
        ],
      ),
    );
  }
}