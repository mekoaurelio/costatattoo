import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../const/const.dart';
import '../service/dateDifference.dart';
import '../service/imageUploadPage.dart';
import '../service/utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/texto.dart';
import 'customerDialog.dart';
import 'customerNotePage.dart'; // Usado para traduções como 'name'.tr

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  bool _isLoading = true; // Controla o estado de carregamento inicial
  List<DocumentSnapshot> _currentDocs = [];
  int _totalItems = 0;
  final int _pageSize = 10;
  DocumentSnapshot? _lastDoc;
  DocumentSnapshot? _firstDoc; // Necessário para a página anterior
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _getTotalItems();
    await _loadPage(direction: 'initial');
    setState(() => _isLoading = false);
  }

  Future<void> _getTotalItems() async {
    final countQuery = _buildBaseQuery().count();
    final snap = await countQuery.get();
    setState(() => _totalItems = snap.count ?? 0);
  }

  Query _buildBaseQuery() {
    Query query = FirebaseFirestore.instance.collection('customer');

    if (_searchQuery.isNotEmpty) {
      // Usa a query 'array-contains' que é muito eficiente para busca
      query = query.where('searchKeywords', arrayContains: _searchQuery);
    }

    return query.orderBy('createdAt', descending: true);
  }
  /*
  Future<void> _loadPage({bool next = true, bool isInitial = false}) async {
    if (!mounted) return;

    // 1. COMEÇA COM A QUERY BASE CORRETA (que já tem o filtro de busca)
    Query query = _buildBaseQuery();

    // 2. APLICA A PAGINAÇÃO NA QUERY CORRETA
    if (isInitial) {
      _lastDoc = null;
      _firstDoc = null;
      _currentPage = 1;
    } else if (next && _lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    } else if (!next && _firstDoc != null) {
      // A lógica de "previous" é complexa. Para que funcione com a busca,
      // a query de contagem reversa também precisa dos filtros.
      // Esta implementação é simplificada e pode não funcionar perfeitamente com a busca.
      // Uma melhoria seria refazer a query inteira em ordem reversa.
      // Por agora, vamos garantir que "next" funcione perfeitamente.
      query = query.endBeforeDocument(_firstDoc!).limitToLast(_pageSize);
    } else {
      // Se não for inicial e não tiver cursor, não faz nada
    }

    // 3. Limita o número de resultados e busca os dados
    final snapshot = await query.limit(_pageSize).get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _currentDocs = snapshot.docs;
        _firstDoc = snapshot.docs.first;
        _lastDoc = snapshot.docs.last;
        if (!isInitial) {
          _currentPage = next ? _currentPage + 1 : (_currentPage > 1 ? _currentPage - 1 : 1);
        }
      });
    } else if (isInitial) {
      // Se a busca inicial não retornou nada
      setState(() {
        _currentDocs = [];
        _lastDoc = null;
        _firstDoc = null;
        _currentPage = 1;
      });
    } else if (!next) {
      // Se clicou em voltar e não veio nada, talvez esteja na primeira página. Recarrega.
      await _loadPage(isInitial: true);
    }
  }

   */

  // dentro da classe _CustomerListState

  Future<void> _loadPage({
    String direction = 'initial', // 'initial', 'next', 'previous', 'reload'
  }) async {
    if (!mounted) return;

    Query query = _buildBaseQuery(); // Sempre começa com a query base correta

    switch (direction) {
      case 'initial':
        _lastDoc = null;
        _firstDoc = null;
        _currentPage = 1;
        break;
      case 'next':
        if (_lastDoc != null) query = query.startAfterDocument(_lastDoc!);
        break;
      case 'previous':
      // Para "previous", a lógica mais segura é buscar em ordem reversa
      // e depois inverter o resultado localmente.
        if (_firstDoc != null) {
          query = _buildBaseQuery()
              .orderBy('createdAt', descending: true) // Inverte a ordenação principal
              .startAfterDocument(_firstDoc!)
              .limit(_pageSize);

          final snapshot = await query.get();
          if (snapshot.docs.isNotEmpty) {
            setState(() {
              _currentDocs = snapshot.docs.reversed.toList();
              _firstDoc = _currentDocs.first;
              _lastDoc = _currentDocs.last;
              _currentPage--;
            });
          }
          return; // Retorna para não executar a query principal
        }
        break;
      case 'reload':
        if (_currentPage > 1 && _firstDoc != null) {
          Query reloadQuery = _buildBaseQuery();
          // Para chegar na página atual, precisamos "pular" as páginas anteriores.
          if (_currentPage > 1) {
            final snapshotToSkip = await reloadQuery.limit((_currentPage - 1) * _pageSize).get();
            if (snapshotToSkip.docs.isNotEmpty) {
              query = query.startAfterDocument(snapshotToSkip.docs.last);
            }
          }
        }
        break;
    }

    final snapshot = await query.limit(_pageSize).get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _currentDocs = snapshot.docs;
        _firstDoc = snapshot.docs.first;
        _lastDoc = _currentDocs.last;
        if (direction == 'next') _currentPage++;
      });
    } else if (direction == 'initial' || direction == 'reload') {
      setState(() {
        _currentDocs = [];
        _lastDoc = null;
        _firstDoc = null;
      });
    }
  }
/*
  Future<void> _reloadCurrentPage() async {
    setState(() => _isLoading = true);

    Query query = _buildBaseQuery().limit(_currentPage * _pageSize);
    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      // Pega apenas os últimos `_pageSize` documentos, que correspondem à página atual
      final startIndex = (_currentPage - 1) * _pageSize;
      setState(() {
        _currentDocs = snapshot.docs.sublist(startIndex);
        _firstDoc = _currentDocs.first;
        _lastDoc = _currentDocs.last;
      });
    } else {
      // Se não houver mais dados (ex: o item foi deletado), volta para a primeira página.
      _loadInitialData();
    }

    setState(() => _isLoading = false);
  }

 */

  // dentro da classe _CustomerListState

  Future<void> _reloadCurrentPage() async {
    // Mostra um indicador de carregamento para feedback visual
    setState(() => _isLoading = true);

    // Busca todos os documentos até a página atual.
    // Isso é necessário para encontrar o cursor correto para começar a busca da página atual.
    QuerySnapshot snapshotToDetermineCursor;
    if (_currentPage == 1) {
      snapshotToDetermineCursor = await _buildBaseQuery().limit((_currentPage) * _pageSize).get();
    } else {
      snapshotToDetermineCursor = await _buildBaseQuery().limit((_currentPage - 1) * _pageSize).get();
    }

    Query query = _buildBaseQuery();

    // Se não estiver na primeira página, define o cursor inicial
    if (_currentPage > 1 && snapshotToDetermineCursor.docs.isNotEmpty) {
      query = query.startAfterDocument(snapshotToDetermineCursor.docs.last);
    }

    // Busca os documentos da página atual
    final snapshot = await query.limit(_pageSize).get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _currentDocs = snapshot.docs;
        _firstDoc = _currentDocs.first;
        _lastDoc = _currentDocs.last;
      });
    } else {
      // Se a página atual ficou vazia (ex: último item foi deletado),
      // é melhor voltar para a primeira página.
      await _loadInitialData();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadPreviousPage() async {
    if (_firstDoc == null) return;

    Query query = _buildBaseQuery() // Começa com a query base (com filtros)
        .orderBy('createdAt', descending: true) // Inverte a ordenação
        .startAfterDocument(_firstDoc!) // Começa DEPOIS do primeiro item atual (na ordem reversa)
        .limit(_pageSize);

    final snapshot = await query.get();

    if(snapshot.docs.isNotEmpty) {
      setState(() {
        _currentDocs = snapshot.docs.reversed.toList(); // Inverte a lista para a ordem correta
        _firstDoc = _currentDocs.first;
        _lastDoc = _currentDocs.last;
        _currentPage = _currentPage - 1;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  // dentro da classe _CustomerListState

  void _onSearchChanged() {
    // Cancela o timer anterior se houver um
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Cria um novo timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Quando o timer terminar, atualiza o estado da query
      // e refaz a busca do zero.
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          // Reinicia a paginação para a busca
          _loadInitialData();
        });
      }
    });
  }

  Future<void> _navigateToImage([DocumentSnapshot? customerDoc]) async {
    // Navega para a nova tela e aguarda um resultado.
    final bool? success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageUploadPage(customerDoc: customerDoc),
      ),
    );
    if (success == true) {
      setState(() {});
    }
  }

  Future<void> _navigateToFormPage([DocumentSnapshot? customerDoc]) async {
    // Navega para a nova tela e aguarda um resultado.
    final bool? success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(customerDoc: customerDoc),
      ),
    );
    if (success == true) {
    }
  }
  @override
  Widget build(BuildContext context) {
    // Pega a largura atual da tela para tomar decisões de layout
    final screenWidth = MediaQuery.of(context).size.width;
    // Define um ponto de corte. Abaixo de 768px, consideramos "mobile".
    const double mobileBreakpoint = 768.0;
    final bool isMobile = screenWidth < mobileBreakpoint;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFa49494),
        title: Texto(tit: 'Costa Tattoo Studio', tam: 18, cor: Colors.white),
        actions: [
          // O campo de busca SÓ APARECE na AppBar em telas largas
          if (!isMobile)
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: CustomTextFiel(
                controller: _searchController,
                hintText: 'Pesquisar por nome ou e-mail',
                label: '',
                obrigatorio: false,
                prefixIcon: Icons.search_outlined,
                // Estilos para combinar com a AppBar
                //fillColor: Colors.white.withOpacity(0.1),
                //textColor: Colors.white,
                //hintColor: Colors.white70,
                prefixIconColor: Colors.white70,
              ),
            ),

          ///NOVO CLIENTE
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.black, weight: 100),
            tooltip: 'new_customer'.tr,
            onPressed: () => _navigateToFormPage(),
          ),
          ///EDITAR NOTAS
          IconButton(
            icon: const Icon(Icons.note_alt_outlined, color: Colors.white),
            tooltip: 'edit_notes'.tr,
            onPressed: () {
              Get.to(() => CustomerNotePage());
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // O campo de busca SÓ APARECE no corpo em telas estreitas
          if (isMobile)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextFiel(
                controller: _searchController,
                hintText: 'Pesquisar por nome ou e-mail',
                label: '',
                obrigatorio: false,
                prefixIcon: Icons.search_outlined,
              ),
            ),
          Expanded(
            // Passamos o booleano 'isMobile' para a lista
            child: _paginatedList(isMobile),
          ),
        ],
      ),
    );
  }

  /*
  Future<void> _showEditValueDialog(DocumentSnapshot customerDoc) async {
    final data = customerDoc.data() as Map<String, dynamic>;
    final currentValue = (data['value'] ?? 0.0).toString();
    final valueController = TextEditingController(text: currentValue);

    // showDialog retorna o valor digitado quando o diálogo é fechado com "Salvar"
    final newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('edit_value'.tr),
          content: TextField(
            controller: valueController,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'new_value'.tr,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () => Navigator.of(context).pop(), // Fecha sem retornar valor
            ),
            ElevatedButton(
              child: Text('save'.tr),
              onPressed: () {
                // Fecha e retorna o novo valor
                Navigator.of(context).pop(valueController.text);
              },
            ),
          ],
        );
      },
    );

    // Se o usuário salvou (newValue não é nulo) e o valor mudou
    if (newValue != null && newValue != currentValue) {
      // Tenta converter o valor para double
      final double? parsedValue = double.tryParse(newValue.replaceAll(',', '.'));
      if (parsedValue != null) {
        try {
          // Atualiza o valor no Firestore
          await FirebaseFirestore.instance
              .collection('customer')
              .doc(customerDoc.id)
              .update({'value': parsedValue});

          Utils.snak('success'.tr, 'value_updated'.tr, false, Colors.green);
          // Não é necessário chamar setState, o StreamBuilder cuidará da atualização da UI
        } catch (e) {
          Utils.snak('error'.tr, 'update_failed'.tr, false, Colors.red);
        }
      } else {
        Utils.snak('error'.tr, 'invalid_value'.tr, false, Colors.red);
      }
    }
  }

   */

  // dentro da classe _CustomerListState

  Future<void> _showEditValueDialog(DocumentSnapshot customerDoc) async {
    final data = customerDoc.data() as Map<String, dynamic>;
    final currentValue = (data['value'] ?? 0.0).toString();
    final valueController = TextEditingController(text: currentValue);

    final newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('edit_value'.tr),
          content: TextField(
            controller: valueController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'new_value'.tr,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('save'.tr),
              onPressed: () {
                Navigator.of(context).pop(valueController.text);
              },
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue != currentValue) {
      final double? parsedValue = double.tryParse(newValue.replaceAll(',', '.'));
      if (parsedValue != null) {
        try {
          await FirebaseFirestore.instance
              .collection('customer')
              .doc(customerDoc.id)
              .update({'value': parsedValue});

          Utils.snak('success'.tr, 'value_updated'.tr, false, Colors.green);

          // **** AQUI ESTÁ A CORREÇÃO ****
          // Após a atualização bem-sucedida, chame a função para recarregar os dados da página atual.
          await _reloadCurrentPage();

        } catch (e) {
          Utils.snak('error'.tr, 'update_failed'.tr, false, Colors.red);
        }
      } else {
        Utils.snak('error'.tr, 'invalid_value'.tr, false, Colors.red);
      }
    }
  }

  Widget _paginatedList(bool isMobile) { // Recebe a flag aqui
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_currentDocs.isEmpty) {
      return Utils.vazio('Nenhum Cliente Encontrado');
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _currentDocs.length,
            itemBuilder: (context, index) {
              final doc = _currentDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              return CustomerCard(
                name: data['name'] ?? '-',
                email: data['email'] ?? '-',
                dateWB: data['dateWB'] ?? '-',
                imageUrl: data['imageUrl'],
                dateTattoo: data['createdAt'],
                value: data['value'] ?? 0.0,
                onEdit: () => _navigateToFormPage(doc),
                onImage: () => _navigateToImage(doc),
                // NOVO: Passe a função do diálogo como callback
                onValueTap: () => _showEditValueDialog(doc),
                onDelete: () async {
                  final confirm = await Utils.showDlg('attention'.tr, 'conf_del'.tr, context, 'yes'.tr, 'no'.tr);
                  if (confirm) {
                    await FirebaseFirestore.instance.collection('customer').doc(doc.id).delete();
                    Utils.snak('congra'.tr, 'successDel'.tr, false, Colors.green);
                    _loadInitialData(); // Recarrega a primeira página após deletar
                  }
                },
                isMobile: isMobile, // <<< PASSE A FLAG AQUI
                // ...
              );
            },
          ),
        ),
        const Divider(),
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    // Lógica para saber se pode ir para a próxima página
    // Uma forma simples é verificar se a página atual está cheia.
    final bool hasNextPage = _currentDocs.length == _pageSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: _currentPage > 1 ? () => _loadPage(direction: '') : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed: _currentPage > 1 ? _loadPreviousPage : null, // Chama a nova função
        ),

        Texto(tit: 'Página $_currentPage de ${((_totalItems / _pageSize).ceil()).clamp(1, 999)}'),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: hasNextPage ? () => _loadPage(direction:'next') : null,
        ),
        // O botão "Last Page" é muito custoso e complexo de implementar com Firestore cursors.
        // É comum removê-lo ou usar outra estratégia. Vou deixá-lo desabilitado por enquanto.
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: null,
        ),
        const SizedBox(width: 10),
        Texto(tit: '$_totalItems Itens'),
      ],
    );
  }
}

class CustomerCard extends StatelessWidget {
  final String name;
  final String email;
  final String dateWB;
  final Timestamp dateTattoo;
  final String? imageUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onImage;
  final bool isMobile; // NOVO: Flag para controlar o layout
  final num value; // Adicione a propriedade para o valor
  final VoidCallback? onValueTap; // Callback para o clique

  const CustomerCard({
    required this.name,
    required this.email,
    required this.dateWB,
    required this.dateTattoo,
    this.imageUrl,
    this.onDelete,
    this.onEdit,
    this.onImage,
    this.isMobile = false, // Padrão para false
    required this.value,
    this.onValueTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Escolhe o layout com base na flag 'isMobile'
    return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
  }

  // --- LAYOUT PARA TELAS LARGAS (o seu código original) ---
  Widget _buildDesktopLayout() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(radius: 60.0), // Imagem maior
            const SizedBox(width: 16),
            Expanded(child: _buildInfoColumn()),
          ],
        ),
      ),
    );
  }

  // --- NOVO LAYOUT PARA TELAS ESTREITAS ---
  Widget _buildMobileLayout() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Elementos empilhados verticalmente
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(radius: 40.0), // Imagem menor
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Texto(tit: name, tam: 18, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      Texto(tit: 'Email: $email', tam: 12),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoDetails(),
            _buildActionButtons(), // Botões separados para melhor layout
          ],
        ),
      ),
    );
  }

  // Widget helper para a imagem, para evitar repetição
  Widget _buildAvatar({required double radius}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
          ? NetworkImage('$pathPhpFiles/get_image.php?img=$imageUrl&v=${DateTime.now().millisecondsSinceEpoch}')
          : null,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? Icon(Icons.person, size: radius, color: Colors.grey.shade400)
          : null,
    );
  }

  // Widget helper para a coluna de informações, para reutilizar no desktop
  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Texto(tit: name, tam: 18, fontWeight: FontWeight.bold),
            ),
            // Os botões de ação ficam aqui no layout de desktop
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onImage != null) IconButton(icon: const Icon(Icons.image_outlined, color: Colors.green), onPressed: onImage),
                if (onEdit != null) IconButton(icon: const Icon(Icons.edit, color: Color(0xFFa49494)), onPressed: onEdit),
                if (onDelete != null) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
              ],
            )
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoDetails(),
      ],
    );
  }

  // Widget helper para os detalhes (data, valor, etc.)
  Widget _buildInfoDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Texto(tit: 'Email: $email', tam: 12),
        const SizedBox(height: 4),
        Row(
          children: [
            Texto(tit: '${'tattoo_date'.tr}: ${converteData(dateTattoo)}'),
            Texto(tit: converteHora(dateTattoo), tam: 14, negrito: true, left: 10, cor: Colors.blue),
          ],
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onValueTap, // Chama o callback ao ser clicado
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Para o InkWell não se esticar
              children: [
                Texto(
                  // Formata o número como moeda
                  tit: 'Value: ${NumberFormat.simpleCurrency(locale: 'en_AU').format(value)}',
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),

        /*
        Texto(tit: tempoCorrido(dateTattoo), tam: 11),
        const SizedBox(height: 4),
        Texto(tit: 'Value: 980.00'), // Mantenha seus dados aqui

         */
      ],
    );
  }

  // Widget helper para os botões de ação no layout mobile
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onImage != null) TextButton.icon(icon: const Icon(Icons.image_outlined, color: Colors.green), label: Text('Image'), onPressed: onImage),
        if (onEdit != null) TextButton.icon(icon: const Icon(Icons.edit, color: Color(0xFFa49494)), label: Text('Edit'), onPressed: onEdit),
        if (onDelete != null) TextButton.icon(icon: const Icon(Icons.delete, color: Colors.red), label: Text('Delete'), onPressed: onDelete),
      ],
    );
  }

  converteData(Timestamp timestamp ){
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
  converteHora(Timestamp timestamp ){
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm').format(dateTime);
  }

  tempoCorrido(Timestamp timestamp ){
    final dataFirestore =  timestamp;
    final tempoDecorrido = calcularDiferencaTempo(dataFirestore);
    return '${'tattoo_create'.tr} $tempoDecorrido';
  }
}