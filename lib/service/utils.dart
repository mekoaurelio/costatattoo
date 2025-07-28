import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import '../const/const.dart';
import '../widgets/formFieldData.dart';
import '../widgets/texto.dart';

class Utils {

  static final formKeyListNotificacaoDetalhe = GlobalKey<FormState>();
  static final maskPerc = MaskTextInputFormatter(mask: '###', filter: { "#": RegExp(r'[0-9]') });
  static final doisDigitos = MaskTextInputFormatter(mask: '##', filter: { "#": RegExp(r'[0-9]') });
  static final tresDigitos = MaskTextInputFormatter(mask: '#.##', filter: { "#": RegExp(r'[0-9]') });
  static final maskDt = MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') });
  static final maskFn2 = MaskTextInputFormatter(mask: '##-#-####-####', filter: { "#": RegExp(r'[0-9]') });
  static final maskFoneFixo = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });
  static final formatVr = NumberFormat("#,##0.00", "pt_BR");
  static var formatterD =  DateFormat('dd/MM/yyyy');
  static var formatterh =  DateFormat('hh:mm');

  static validDate(var dt){
    final parts = dt.split('/');
    final day = parts[0];
    final month = parts[1];
    if(int.parse(day)>31){
      return false;
    }
    if(int.parse(month)>12){
      return false;
    }
    return true;
  }

  static Future<String?> getLongTextFromFirestore() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('note')
          .doc('text')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['longText'] as String?;
      } else {
        print('Documento não encontrado');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar longText: $e');
      return null;
    }
  }

  static idade(Timestamp firestoreDate){
    final now = DateTime.now();
    final dateFromFirestore = firestoreDate.toDate();

    Duration diff = now.difference(dateFromFirestore);
    int totalDays = diff.inDays;
    int anos = (totalDays / 365).floor();
    return anos;
  }


  static Future<dynamic> enviarEmail(String email,String title,String msg)async {
    try {

      var em='mekoaurelio@gmail.com';
      var url = '${pathPhpFiles}/email.php?email=$em&title=$title&msg=$msg';

      final response = await http.get(Uri.parse(url),
          headers: {
            "Accept": "application/json",
            "Access-Control_Allow_Origin": "*"
          });

      if (response.statusCode == 200) {
        print('Email enviado!');
      } else {
        print('Erro: ${response.body}');
      }

    } catch (e) {
      print('ACONTECEU UMM ERRO '+e.toString());
    }
  }

  static Future<String> getCurrentDateTime() async {
    try {
      final response = await http.get(Uri.parse('http://worldtimeapi.org/api/timezone/Etc/UTC'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final DateTime utcTime = DateTime.parse(data['utc_datetime']);
        final DateTime localTime = utcTime.toLocal(); // Converte para o horário local se necessário

        var formatterD = DateFormat('yyyy-MM-dd');
        var formatterH = DateFormat('HH:mm:ss');

        String dt = formatterD.format(localTime);
        String hr = formatterH.format(localTime);

        return '$dt $hr';
      } else {
        throw Exception('Failed to load time');
      }
    } catch (exception) {
      return exception.toString();
    }
  }

  static dataToSave(){
    DateTime now = DateTime.now().isUtc ? DateTime.now() : DateTime.now().toUtc();
    Timestamp _TimeStamp = Timestamp.fromDate(now);
    return _TimeStamp;
  }


  static String formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }


  static BoxDecoration decor() {
    return BoxDecoration(
      // color: Colors.blueGrey[100], // Cor de fundo do container
      border: Border.all(
        color: Colors.grey.shade300, // Cor da borda
        width: 1.0, // Espessura da borda
        style: BorderStyle.solid, // Estilo da borda (sólida, tracejada, etc.)
      ),
      borderRadius: BorderRadius.circular(
          10.0), // Opcional: bordas arredondadas
    );
  }

  static Widget vazio(var texto,{double height=150,double width=150 }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/indisponivel.png",
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
          //Expanded(
           // child: Texto(tit: texto, cor: Colors.grey, tam: 18,top: 10,),
         // )
          Texto(tit: texto, cor: Colors.grey, tam: 18,top: 10,),
        ],
      ),
    );
  }


  static  borda(){
    return  const Border(
      bottom: BorderSide(
        color: Colors.white70  , // Cor da borda
        width: 0.2, // Espessura da borda
      ),
    );
  }

  static vrStringToDouble(String valorInformado)async{
    String vrInformado=await saldoToSave(valorInformado);
    vrInformado=vrInformado.replaceAll('.', '');
    return double.parse(vrInformado);
  }

  static String saldoToSave(String tex) {
    String sl=tex;
    if(tex.contains('%')) {
      sl = tex.replaceAll('%','');
      sl =sl.trim();
    }
    if(tex.contains('\$')) {
      sl = tex.substring(3, tex.length);
    }
    sl=sl.replaceAll('.', '');
    sl=sl.replaceAll(',', '.');
    return sl;
  }

  ///USUÄRIO
  static void setIdUser(var idClinica) {
    html.window.localStorage['idUser'] = idClinica;
  }

  static getIdUser(){
    return html.window.localStorage['idUser'];
  }

  static void setUserName(var UserName) {
    html.window.localStorage['UserName'] = UserName;
  }

  static getUserName(){
    return html.window.localStorage['UserName'];
  }

  static String randomNumber(){
    String verificador ='';
    var _random = Random.secure();
    var random = List<int>.generate(22, (i) => _random.nextInt(256));
    verificador = base64Url.encode(random);
    verificador=verificador.substring(0,6);
    verificador=verificador.toUpperCase();
    return verificador;
  }

  ///DATAS ****************************
  static DateTime parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) throw const FormatException('Formato inválido');

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      throw FormatException('Data inválida: $dateStr');
    }
  }

  static int calculateYearsDifference(DateTime fromDate) {
    final now = DateTime.now();
    int years = now.year - fromDate.year;

    // Ajuste se ainda não chegou o aniversário este ano
    if (now.month < fromDate.month ||
        (now.month == fromDate.month && now.day < fromDate.day)) {
      years--;
    }

    return years;
  }

  static logo(){
    return Container(
      width: 250,
      height: 150,
      decoration: BoxDecoration(
        image:  DecorationImage(
          image: AssetImage('assets/costatattoo_l1.jpeg'),
          // fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        color: Color(0xFFEFE7DE),
       // shape: BoxShape.circle,
      ),
    );
  }

  static Widget line(var tex, double tam, [Alignment? alignment]) {
    return Container(
      width: tam,
      alignment: alignment ?? Alignment.center,
      child: Texto(
        tit: tex,
        cor: Colors.black,
        tam: 12,
        top: 10,
        bottom: 10,
      ),
    );
  }

  static vrBco(var vr){
    double xVr=double.parse(vr);
    return toReal(xVr);
  }

  static toReal(double vr){
    return 'R\$ '+Utils.formatVr.format(vr).toString();
  }

  static showDlg(String titulo,String frase,BuildContext context,var positivo,var negativo) async{
    bool volta=false;
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Colors.green,
              width: 0.0,
            ),
          ),

          title: Center(child: Texto(tit:titulo,tam: 17,negrito: true,cor:Colors.blue,linhas: 2,)),
          content:  Column(
              mainAxisSize: MainAxisSize.min,
              children:  <Widget>[
                Text(frase,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red,),
                ),
              ]
          ),
          actions: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  OutlinedButton(
                    style: OutlinedButtonStlo(false,6,Colors.white),
                    child: Texto(tit:negativo,negrito: true,tam: 17,cor:Colors.red),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      volta=false;
                    },
                  ),
                  OutlinedButton(
                    style: OutlinedButtonStlo(false,6,Colors.white),
                    child: Texto(tit:positivo,negrito: true,tam: 17,cor:Colors.blue),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      volta=true;
                    },
                  ),
                ]
            ),
          ],
        ));
    return volta;
  }

  static ButtonStyle OutlinedButtonStlo(bool mostraCircular, double elevacao,Color cor){
    return OutlinedButton.styleFrom(
        padding: mostraCircular?const EdgeInsets.symmetric(horizontal: 50, vertical: 15)
            :const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: cor,
        elevation: elevacao,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),)
    );
  }

  static snak(String tit,String frase,bool dismiss,Color corFundo){
    return Get.snackbar(
      tit,
      frase,
      icon: Icon(Icons.person, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: corFundo,
      borderRadius: 20,
      margin: EdgeInsets.all(15),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      isDismissible: false,
      //showProgressIndicator:true,
      //dismissDirection: SnackDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.easeOutBack,

    );
  }
}//441