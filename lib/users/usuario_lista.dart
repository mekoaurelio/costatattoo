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
    await _loadPage(isInitial: true);
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

  // dentro da classe _CustomerListState

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

// **Lógica de "Previous" mais robusta (Opcional, mas recomendado)**
// Se você quiser que o botão "Voltar" funcione bem com a busca,
// a lógica precisa ser mais explícita.
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

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title:  Texto(tit:'customers'.tr),
        actions: [
          ///NOVO CLIENTE
          IconButton(
            icon: const Icon(Icons.person_add,color: Colors.black,weight: 100,),
            tooltip: 'new_customer'.tr,
            onPressed: () => _navigateToFormPage(),
          ),
          ///EDITAR
          IconButton(
            icon: const Icon(Icons.note_alt_outlined, color: Colors.red,),
            tooltip: 'edit_notes'.tr,
              onPressed: () {
                Get.to(() => CustomerNotePage(), arguments: {});
              },
          ),
        ],
      ),
      body: Column(
       // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.logo(),
          Expanded(
              child: _paginatedList())
        ],
      )
    );
  }

 */

  // dentro da classe _CustomerListState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title:  Texto(tit:'Costa Tattoo Studio',tam: 18,),
        actions: [

        Container(
        width: 300,
         child:  CustomTextFiel(
            controller: _searchController,
            hintText: 'Pesquisar por nome ou e-mail',
            label: '',
            left: 10,
            prefixIcon: Icons.search_outlined,
            obrigatorio: false,
           // onChanged: _onSearchChanged(),
          ),
        ),
/*
https://github.com/mekoaurelio/costatattoo.git
 */


        ///NOVO CLIENTE
        IconButton(
          icon: const Icon(Icons.person_add,color: Colors.black,weight: 100,),
          tooltip: 'new_customer'.tr,
          onPressed: () => _navigateToFormPage(),
        ),
        ///EDITAR
        IconButton(
          icon: const Icon(Icons.note_alt_outlined, color: Colors.red,),
          tooltip: 'edit_notes'.tr,
          onPressed: () {
            Get.to(() => CustomerNotePage(), arguments: {});
          },
        ),
      ],
    ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        //  Utils.logo(),

          Expanded(
            // CHAME O NOVO MÉTODO AQUI
            child: _paginatedList(),
          ),
        ],
      ),
    );
  }

  Widget _paginatedList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_currentDocs.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado.'));
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
                // ... (propriedades do CustomerCard - sem alterações)
                name: data['name'] ?? '-',
                email: data['email'] ?? '-',
                dateWB: data['dateWB'] ?? '-',
                imageUrl: data['imageUrl'],
                dateTattoo: data['createdAt'],
                onEdit: () => _navigateToFormPage(doc),
                onImage: () => _navigateToImage(doc),
                onDelete: () async {
                  final confirm = await Utils.showDlg('attention'.tr, 'conf_del'.tr, context, 'yes'.tr, 'no'.tr);
                  if (confirm) {
                    await FirebaseFirestore.instance.collection('customer').doc(doc.id).delete();
                    Utils.snak('congra'.tr, 'successDel'.tr, false, Colors.green);
                    _loadInitialData(); // Recarrega a primeira página após deletar
                  }
                },
              );
            },
          ),
        ),
        const Divider(),
        _buildPaginationControls(), // Separei os controles em um widget
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
          onPressed: _currentPage > 1 ? () => _loadPage(isInitial: true) : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed: _currentPage > 1 ? _loadPreviousPage : null, // Chama a nova função
        ),

        Texto(tit: 'Página $_currentPage de ${((_totalItems / _pageSize).ceil()).clamp(1, 999)}'),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: hasNextPage ? () => _loadPage(next: true) : null,
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
  final String? imageUrl; // NOVO: Propriedade para a URL da imagem
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onImage;

  const CustomerCard({
    required this.name,
    required this.email,
    required this.dateWB,
    required this.dateTattoo,
    this.imageUrl, // NOVO
    this.onDelete,
    this.onEdit,
    this.onImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row( // Mudei para Row para alinhar a imagem e os dados
          children: [
            CircleAvatar(
              radius: 120,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? NetworkImage('$pathPhpFiles/get_image.php?img=$imageUrl&v=${DateTime.now().millisecondsSinceEpoch}',)
                  : null,

              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? Icon(Icons.person, size: 120, color: Colors.grey.shade400)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Texto(tit: name,tam: 18,fontWeight: FontWeight.bold,),
                      ),
                      if (onImage != null)
                        IconButton(
                          icon: const Icon(Icons.image_outlined, color: Colors.green),
                          onPressed: onImage,
                        ),
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                  Texto(tit:'Email: $email'),
                  Texto(tit:'birth_date'.tr+ ': $dateWB'),
                  Row(
                    children: [
                      Texto(tit:'tattoo_date'.tr+ ': ${converteData(dateTattoo)}'),
                      Texto(tit:converteHora(dateTattoo),tam: 18,negrito: true,left: 10,cor: Colors.blue,),
                      Texto(tit:tempoCorrido(dateTattoo),left: 10,)
                    ],
                  )

                ],
              ),
            ),
          ],
        ),
      ),
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
