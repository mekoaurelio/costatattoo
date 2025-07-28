import 'package:cloud_firestore/cloud_firestore.dart';

String calcularDiferencaTempo(Timestamp firestoreDate) {
  final now = DateTime.now();
  final dateFromFirestore = firestoreDate.toDate();

  Duration diff = now.difference(dateFromFirestore);
  int totalDays = diff.inDays;
  int totalHours = diff.inHours;
  int totalMinutes = diff.inMinutes;

  int anos = (totalDays / 365).floor();
  int meses = ((totalDays % 365) / 30).floor();
  int semanas = ((totalDays % 30) / 7).floor();
  int dias = (totalDays % 7);
  int horas = (diff.inHours % 24);
  int minutos = (diff.inMinutes % 60);

  List<String> partes = [];

  if (anos > 0) partes.add('$anos ${anos == 1 ? 'year' : 'years'}');
  if (meses > 0) partes.add('$meses ${meses == 1 ? 'month' : 'months'}');
  if (semanas > 0) partes.add('$semanas ${semanas == 1 ? 'week' : 'weeks'}');
  if (dias > 0) partes.add('$dias ${dias == 1 ? 'day' : 'days'}');
  if (horas > 0) partes.add('$horas ${horas == 1 ? 'hour' : 'hours'}');
  if (minutos > 0 && partes.isEmpty) partes.add('$minutos minutes');

  return partes.isNotEmpty ? partes.join(', ') : 'right now';
}
