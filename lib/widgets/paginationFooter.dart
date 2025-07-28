import 'package:flutter/material.dart';

import '../service/screenSize.dart';

/// Um widget de rodapé reutilizável para controle de paginação.
///
/// Exibe controles para navegar entre as páginas (primeira, anterior, próxima, última)
/// e mostra informações sobre a página atual e o total de itens.
class PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;

  /// Callback que é acionado quando o usuário solicita uma mudança de página.
  /// O valor fornecido é o novo número da página.
  final ValueChanged<int> onPageChanged;

  const PaginationFooter({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSizeConfig = ScreenSizeConfig(context);
    final bool isFirstPage = currentPage <= 1;
    final bool isLastPage = currentPage >= totalPages;

    // Se houver apenas uma página ou menos, não há necessidade de mostrar o rodapé.
    if (totalPages <= 1) {
      return const SizedBox.shrink(); // Retorna um widget vazio
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Primeira Página',
            // Desabilita o botão se já estiver na primeira página
            onPressed: isFirstPage ? null : () => onPageChanged(1),
            icon: Icon(Icons.first_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            tooltip: 'Página Anterior',
            onPressed: isFirstPage ? null : () => onPageChanged(currentPage - 1),
            icon: Icon(Icons.arrow_back, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Página $currentPage de $totalPages',
              style: TextStyle(fontSize: screenSizeConfig.getBodyFontSize(), color: Colors.black54),
            ),
          ),
          IconButton(
            tooltip: 'Próxima Página',
            // Desabilita o botão se já estiver na última página
            onPressed: isLastPage ? null : () => onPageChanged(currentPage + 1),
            icon: Icon(Icons.arrow_forward, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            tooltip: 'Última Página',
            onPressed: isLastPage ? null : () => onPageChanged(totalPages),
            icon: Icon(Icons.last_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          const SizedBox(width: 24),
          Text(
            '$totalItems Itens',
            style: TextStyle(fontSize: screenSizeConfig.getBodyFontSize(), color: Colors.black54),
          ),
        ],
      ),
    );
  }
}