import 'dart:typed_data'; // Essencial para lidar com dados de imagem na web
import 'package:costatattoo/widgets/custom_butom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:country_flags/country_flags.dart';

import '../data/db.dart';
import '../service/utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/texto.dart';

class CustomerFormPage extends StatefulWidget {
  final DocumentSnapshot? customerDoc;

  const CustomerFormPage({Key? key, this.customerDoc}) : super(key: key);

  @override
  _CustomerFormPageState createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _dateWBController;
  bool _isSaving = false;
  bool get _isEditing => widget.customerDoc != null;

  // ---- NOVOS ESTADOS PARA A IMAGEM ----
  Uint8List? _imageBytes; // Armazena os bytes da nova imagem selecionada
  String? _existingImageUrl; // Armazena a URL da imagem existente ao editar

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _dateWBController = TextEditingController();

    if (_isEditing) {
      final data = widget.customerDoc!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _dateWBController.text = data['dateWB'] ?? '';
      // Salva a URL da imagem existente
      _existingImageUrl = data['imageUrl'];
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dateWBController.dispose();
    super.dispose();
  }

// Adicione esta função helper na sua CustomerFormPage ou em um arquivo Utils
  List<String> _generateKeywords(String name, String email) {
    final List<String> keywords = [];
    final String nameLower = name.toLowerCase();
    final String emailLower = email.toLowerCase();

    // Adiciona partes do nome
    for (int i = 1; i <= nameLower.length; i++) {
      keywords.add(nameLower.substring(0, i));
    }

    // Adiciona o e-mail inteiro
    keywords.add(emailLower);

    // Adiciona a parte do e-mail antes do @
    if (emailLower.contains('@')) {
      keywords.add(emailLower.split('@')[0]);
    }

    return keywords;
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; });

    String? imageUrl;

    // Se uma nova imagem foi selecionada, faz o upload
    if (_imageBytes != null) {
      if (imageUrl == null) { // Se o upload falhar, interrompe o salvamento
        setState(() { _isSaving = false; });
        return;
      }
    } else {
      // Se não, mantém a imagem existente
      imageUrl = _existingImageUrl;
    }

    try {

      String? birthDayMonth;
      String dateWB=_dateWBController.text;
      // Valida se a data tem o formato correto (dd/mm/aaaa)
      if (dateWB.length == 10 && dateWB[2] == '/' && dateWB[5] == '/') {
        // Extrai o dia e o mês e formata como MM-DD
        final parts = dateWB.split('/');
        final day = parts[0];
        final month = parts[1];
        bool validDate=Utils.validDate(dateWB);
        if(!validDate){
          Utils.snak('attention'.tr, 'invalidDate'.tr, false, Colors.red);
          return;
        }
        birthDayMonth = '$month-$day';
        final Map<String, dynamic> data = {
          'name': _nameController.text,
          'email': _emailController.text,
          'dateWB': _dateWBController.text,
          'imageUrl': imageUrl,
          'birthDayMonth': birthDayMonth,
          'searchKeywords': _generateKeywords(_nameController.text, _emailController.text),
        };


        if (_isEditing) {
          await FirebaseFirestore.instance.collection('customer').doc(
              widget.customerDoc!.id).update(data);
        } else {
          bool existe = await Db.emailJaCadastrado(_emailController.text);
          if(existe){
            Utils.snak('attention'.tr, 'emailAlready'.tr, false, Colors.red);
            return;
          }
          data['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance.collection('customer').add(data);
          ///MAND MENSAGENS DE CUIDADOSBÁSICOS
          String? texto = await Utils.getLongTextFromFirestore();
          Utils.enviarEmail(_emailController.text,'note_title'.tr,texto!);
        }

        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar cliente: $e')));
      print('Erro ao salvar cliente: $e');
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }
// MÉTODO CORRIGIDO USANDO fromCountryCode
  Widget _buildLanguageButton({
    required BuildContext context,
    required String countryCodeForFlag, // 'BR', 'ES', 'AU'
    required String languageCodeForLocale, // 'pt', 'es', 'en'
    required String countryCodeForLocale, // 'BR', 'ES', 'AU'
    required String tooltipMessage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          // Lógica para mudar o idioma usando GetX
          var locale = Locale(languageCodeForLocale, countryCodeForLocale);
          Get.updateLocale(locale);
        },
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: '${"changeTo".tr} $tooltipMessage',
          child: ClipOval(
            // Garante que a bandeira seja perfeitamente redonda
            child: CountryFlag.fromCountryCode(
              countryCodeForFlag, // <-- AQUI ESTÁ A MUDANÇA PRINCIPAL
              height: 32,
              width: 32,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFa49494),
        actions: [
          // Chamada para o Brasil
          _buildLanguageButton(
            context: context,
            countryCodeForFlag: 'BR',        // Código para a bandeira
            languageCodeForLocale: 'pt',     // Código de idioma para o GetX
            countryCodeForLocale: 'BR',      // Código de país para o GetX
            tooltipMessage: 'Português (Brasil)',
          ),
          // Chamada para a Espanha
          _buildLanguageButton(
            context: context,
            countryCodeForFlag: 'ES',
            languageCodeForLocale: 'es',
            countryCodeForLocale: 'ES',
            tooltipMessage: 'Español',
          ),
          // Chamada para a Austrália
          _buildLanguageButton(
            context: context,
            countryCodeForFlag: 'AU',
            languageCodeForLocale: 'en',
            countryCodeForLocale: 'AU',
            tooltipMessage: 'English (Australia)',
          ),
          const SizedBox(width: 16), // Espaçamento à direita
        ],

      ),
      body: Center(
        child:Container(
          width: MediaQuery.of(context).size.width * 0.50,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Texto(tit:'info_data'.tr,bottom: 20,tam: 22,),
                  Texto(tit:'data_use'.tr,linhas: 3,bottom: 30,),
                  CustomTextFiel(controller: _nameController, label: 'name'.tr, hintText: 'enterName'.tr,
                    prefixIcon: Icons.person, obrigatorio: true,bottom: 10,
                  ),

                  CustomTextFiel(controller: _emailController, label: 'email'.tr, hintText: 'enterEmail'.tr,
                    prefixIcon: Icons.email_outlined, obrigatorio: true,bottom: 10,
                  ),

                  CustomTextFiel(controller: _dateWBController, label: 'birth_date'.tr, hintText: 'birth_date'.tr,
                    prefixIcon: Icons.calendar_month, obrigatorio: true,bottom: 20,inputFormatters: [Utils.maskDt],
                  ),

                 AppButton(
                     text: 'save'.tr,
                     onPressed: _saveCustomer,
                   backgroundColor: Color(0xFFa49494),
                   width: 400,
                   textColor: Colors.white,
                 ),

                ],
              ),
            ),
          ),
        ) ,
      )
    );
  }
}