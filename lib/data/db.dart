import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:convert';

import '../const/const.dart';
import '../models/coins_field.dart';
import '../models/users.dart';
import '../service/utils.dart';

class Db {
  static List<CustomerField> coins = [];

  static Future<bool> emailJaCadastrado(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('customer')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }


  ///Atualiza a ordem dos compostamentos **************************************
 /*
  static Future<void> upDateOrdem(var idDoc, int ordem) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(TB_NAME).doc(idDoc);
      await docRef.update({
        'ordem': ordem,
      }
      );
    } catch (e) {
      Utils.snak('attention'.tr,e.toString(), false, Colors.red);

    }
  }

  */

  static Future<void> upDatePassWord(String passWord, var idDoc) async {
    try {
      final docRef = FirebaseFirestore.instance.collection(TB_USER).doc(idDoc);
      await docRef.update({
        'password': passWord,
      }
      );
    } catch (e) {
      Utils.snak('attention'.tr,e.toString(), false, Colors.red);

    }
  }

  // Função para pegar o maior valor de "ordem"
  static  Future<int?> getMaxOrdem() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('coins')
        .orderBy('ordem', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs.first.data() as Map<String, dynamic>;
      return docData['ordem'];
    }
    return null;
  }

  static add(var  data ){
    coins.add(
      CustomerField(
        data.id,data['idCustomer'], data['name'], data['email'], data['image'],data['dateWB'],),
    );
  }


  /// Get user data by Email and Password **************************************
  static Future getCoins(String idUser,String tipo) async {

    List<DocumentSnapshot>? documents;
    coins.clear();
    await FirebaseFirestore.instance
        .collection('customer')
        .orderBy('email')
        .where('email', isEqualTo: idUser)
        .get().then((event) {
          if (event.docs.isNotEmpty) {
            documents = event.docs;
            documents!.forEach((data) async{
              await add(data);
            });
          }
    }).catchError((e) => print("error fetching data: $e"));
    return coins;

  }
/*
  static Future delCoin(String coin,BuildContext context) async {
    bool excluir = await Utils.showDlg('atencao'.tr, 'conf_del'.tr, context,'yesS'.tr,'no'.tr);
    if(excluir) {
      FirebaseFirestore.instance.collection(TB_NAME)
          .doc(coin) // <-- Doc ID to be deleted.
          .delete() // <-- Delete
          .then((_) =>
          Utils.snak('atencao'.tr, 'success'.tr, false, Colors.green))
          .catchError((error) =>
          Utils.snak('atencao'.tr, error, false, Colors.green));
      return true;
    }else{
      return false;
    }
  }

 */

}