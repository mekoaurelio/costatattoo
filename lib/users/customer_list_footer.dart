import 'package:flutter/material.dart';

class CustomerListFooter extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageChanged;

  const CustomerListFooter({
    required this.currentIndex,
    required this.totalItems,
    required this.onPrevious,
    required this.onNext,
    required this.onPageChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Contador de itens (similar à imagem)
          Text(
            'DI ${currentIndex + 1} de $totalItems Itens',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),

          // Controles de navegação
          Row(
            children: [
              // Botão Primeiro
              IconButton(
                icon: Icon(Icons.first_page, size: 20),
                onPressed: currentIndex > 0 ? () => onPageChanged(0) : null,
                tooltip: 'Primeiro item',
                color: Colors.blue,
              ),

              // Botão Anterior
              IconButton(
                icon: Icon(Icons.chevron_left, size: 24),
                onPressed: currentIndex > 0 ? onPrevious : null,
                tooltip: 'Item anterior',
                color: Colors.blue,
              ),

              // Espaçamento
              SizedBox(width: 8),

              // Botão Próximo
              IconButton(
                icon: Icon(Icons.chevron_right, size: 24),
                onPressed: currentIndex < totalItems - 1 ? onNext : null,
                tooltip: 'Próximo item',
                color: Colors.blue,
              ),

              // Botão Último
              IconButton(
                icon: Icon(Icons.last_page, size: 20),
                onPressed: currentIndex < totalItems - 1
                    ? () => onPageChanged(totalItems - 1)
                    : null,
                tooltip: 'Último item',
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}