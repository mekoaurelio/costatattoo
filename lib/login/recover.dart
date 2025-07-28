import 'dart:convert' show base64Url;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/db.dart';
import '../../../utils/footer.dart';
import '../../../utils/utils.dart';
import '../../../widget/custom_butom.dart';
import '../../../widget/texto.dart';
import '../../base/field.dart';
import 'confirmPassword.dart';

class RecoverPassWord extends StatefulWidget {
  const RecoverPassWord({Key? key}) : super(key: key);

  @override
  State<RecoverPassWord> createState() => _RecoverPassWordState();
}

class _RecoverPassWordState extends State<RecoverPassWord> with TickerProviderStateMixin {
  final TextEditingController _edUser = TextEditingController();
  final TextEditingController _edPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool validEmail=false;

  @override
  void dispose() {
    _edUser.dispose();
    _edPass.dispose();
    super.dispose();
  }

  void _sandCode() async {
    if (_formKey.currentState!.validate()) {
      String verificador=Utils.randomNumber();
      final email = _edUser.text;
      List userData = await Db.getUserByEmail('email', email);
      if (userData.isEmpty) {
        Utils.snak('attention'.tr, 'emailNF'.tr, false, Colors.red);
      } else {
      //  await Utils.enviarEmail(email,'Informe esse código $verificador:','Código Verificador');
        Get.to(() => ConfirmPassword(verificationCode:verificador,userId:userData[0].idUser ,));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Make the layout scrollable
          padding: const EdgeInsets.all(20.0), // Add some padding around the content
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600), // Limit the maximum width
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Utils.logo('assets/icons/cryptIcon.png'),
                  const SizedBox(height: 20),
                  Center(
                    child:
                    Texto(tit: 'welcome'.tr, bottom: 20, top: 10,cor: Colors.black87,tam: 16,),
                  ),
                  Texto(tit: 'send_code_to_email'.tr,cor: Colors.black54,bottom: 10,),
                  ///EMAIL
                  Field.values(controller: _edUser, labelText: 'Email', hintText: 'Email'
                  ),
                  AppButton(
                    text: 'send'.tr,
                    top: 20,
                    bottom: 30,
                    onPressed: _sandCode,
                  ),
                  Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}