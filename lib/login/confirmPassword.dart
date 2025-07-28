import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/db.dart';
import '../service/utils.dart';
import '../widgets/custom_butom.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/texto.dart';

class ConfirmPassword extends StatefulWidget {
  final String verificationCode;
  final String userId;

  const ConfirmPassword({
    Key? key,
    required this.verificationCode,
    required this.userId
  }) : super(key: key);

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordState();
}

class _ConfirmPasswordState extends State<ConfirmPassword> with TickerProviderStateMixin {
  final TextEditingController _edPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool validEmail = false;
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _edPass.dispose();
    super.dispose();
  }

  void _updatePassWord() async {
    if (_formKey.currentState!.validate()) {
      final passWord = _edPass.text;// Example
      Db.upDatePassWord(passWord, widget.userId);
      Utils.setIdUser(widget.userId);
      Get.offAll(() => ListCoins(idUser: widget.userId), arguments: {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Utils.logo('assets/icons/cryptIcon.png'),
                  const SizedBox(height: 20),
                  Center(
                    child: Texto(tit: 'welcome'.tr, bottom: 40, top: 10, cor: Colors.black87, tam: 16,),
                  ),
                  Texto(tit:'enter_code'.tr,cor: Colors.black54,),
                  CustomTextFiel(
                    controller:_edPass ,
                    label:'code'.tr ,
                    hintText: 'code',
                    prefixIcon:Icons.display_settings_outlined,
                  ),
                  AppButton(
                    top: 20,
                    text: 'send'.tr,
                    onPressed: _updatePassWord,
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