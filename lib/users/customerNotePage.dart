import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../service/utils.dart';
import '../widgets/texto.dart';

class CustomerNotePage extends StatefulWidget {

  const CustomerNotePage({
    Key? key,
  }) : super(key: key);

  @override
  _CustomerNotePageState createState() => _CustomerNotePageState();
}

class _CustomerNotePageState extends State<CustomerNotePage> {
  late final TextEditingController _textController;
  bool _isLoading = true;
  String? texto='';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    start();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void start() async {
    texto = await Utils.getLongTextFromFirestore();
    _textController.text =  texto!;
    setState(() { _isLoading = false; });
  }

  Future<void> _saveNote() async {
    setState(() { _isLoading = true; });

    try {
      // Atualiza apenas o campo 'longText' no documento do cliente
      await FirebaseFirestore.instance
          .collection('note')
          .doc('text')
          .update({'longText': _textController.text});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota salva com sucesso!')),
      );
      Navigator.of(context).pop(); // Volta para a lista de clientes

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar nota: $e')),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:Colors.white ,
        title:  Texto(tit:'note_title'.tr),
        actions: [
          // Botão de salvar na AppBar
          _isLoading
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          )
              : IconButton(
            icon: const Icon(Icons.save,color: Colors.red,),
            onPressed: _saveNote,
            tooltip: 'Salvar Nota',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // O TextFormField ocupa todo o espaço disponível
            Expanded(
              child: TextFormField(
                controller: _textController,
                // Chaves para a mágica do campo multi-linha expansível:
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Digite suas anotações aqui...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Garante que o label (se houver) fique no topo
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}