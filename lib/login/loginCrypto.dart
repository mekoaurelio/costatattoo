import 'package:cookia/apps/crypto/login/recover.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/db.dart';
import '../../../utils/footer.dart';
import '../../../utils/forgotPassword.dart';
import '../../../utils/noAccount.dart';
import '../../../utils/utils.dart';
import '../../../widget/custom_butom.dart';
import '../../../widget/texto.dart';
import '../../base/field.dart';
import '../coins/coin_list.dart';
import 'signup.dart';

class LoginCrypto extends StatefulWidget {
  const LoginCrypto({Key? key}) : super(key: key);

  @override
  State<LoginCrypto> createState() => _LoginCryptoState();
}

class _LoginCryptoState extends State<LoginCrypto> with TickerProviderStateMixin {
  final TextEditingController _edUser = TextEditingController();
  final TextEditingController _edPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading=false;
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _edUser.dispose();
    _edPass.dispose();
    super.dispose();
  }
  // Signup


  _login() async{
    if (_formKey.currentState!.validate()) {
      final email = _edUser.text;
      final password = _edPass.text;

      setState(() {
        _isLoading = true;
      });
      try {
        final userData = await Db.getUserByEmailPassword('email', email, 'password', password);
        if (userData.isEmpty) {
          Utils.snak('attention'.tr, 'emailOrPasswordNF'.tr, false, Colors.red);
        } else {
           Utils.setUserName(userData[0].name);
           Utils.setIdUser(userData[0].idUser);
          Get.offAll(() => ListCoins(idUser: userData[0].idUser), arguments: {});
        }
      } finally {
        setState(() {
          _isLoading=false;
        });
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
                 ///EMAIL
                  Field.values(
                    labelText: 'Email',
                    hintText: '',
                    controller: _edUser,// Example of customization
                  ),
                  const SizedBox(height: 10),
                  Field.values(
                    labelText: 'Senha',
                    hintText: '',
                    controller: _edPass,
                    obscureText: _obscureText,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),
                  AppButton(text: 'login'.tr, onPressed: _login, isLoading: _isLoading,),
                  ForgotPassword(
                    recoverPasswordBuilder: () => RecoverPassWord(), // Pass a function that creates the Widget
                  ),
                  NoAccount(
                    recoverPasswordWidget: Signup(), // Pass a function that creates the Widget
                  ),
                  const SizedBox(height: 30),
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