import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/db.dart';
import '../../../utils/footer.dart';
import '../../../utils/utils.dart';
import '../../../widget/custom_butom.dart';
import '../../../widget/texto.dart';
import '../../base/field.dart';
import '../coins/coin_list.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  final TextEditingController _edEmail = TextEditingController();
  final TextEditingController _edPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _buttonText = 'save'.tr;
  bool _obscureText = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _edEmail.dispose();
    _edPass.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _edEmail.text;
      final password = _edPass.text;

      setState(() {
        _buttonText = 'wait'.tr;
      });
      try {
        List userData = await Db.getUserByEmail('email', email);
        if (userData.isNotEmpty) {
          Utils.snak('attention'.tr, 'emailAlready'.tr, false, Colors.red);
        } else {
          final idUser= await Db.addNewUser(email,password);
           Utils.setIdUser(idUser);
          Get.offAll(() => ListCoins(idUser: idUser), arguments: {});
        }
      } finally {
        setState(() {
          _buttonText = 'save'.tr; // Reset button text
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
                  Field.values(
                    controller: _edEmail,labelText: 'Email',hintText: 'Email'
                  ),
                  const SizedBox(height: 16),
                  Field.values(
                    labelText: 'Usuario',
                    controller: _edPass,
                    obscureText: _obscureText,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),
                  AppButton(
                    text: 'signUp'.tr,
                    top: 20,
                    bottom: 30,
                    onPressed: _login,
                   // isLoading: _isLoading,
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