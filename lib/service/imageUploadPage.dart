import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../const/const.dart';

class ImageUploadPage extends StatefulWidget {
  final DocumentSnapshot? customerDoc;

  const ImageUploadPage({Key? key, this.customerDoc}) : super(key: key);

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  Uint8List? _imageData;
  String? _fileName;
  String _status = 'Nenhuma imagem selecionada.';

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _imageData = result.files.first.bytes;
        _fileName = result.files.first.name;
        _status = 'Imagem selecionada: $_fileName';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageData == null || _fileName == null) {
      setState(() {
        _status = 'Selecione uma imagem primeiro!';
      });
      return;
    }

    final uri = Uri.parse(pathPhpFiles+'/upload.php'); // Altere aqui
    String idCustomer=widget.customerDoc!.id.toString().trim();
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file', // nome do campo usado no $_FILES['file']
        _imageData!,
        filename: '$idCustomer.png',
      ));

    setState(() {
      _status = 'Enviando imagem...';
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = {
        'imageUrl': '$idCustomer.png'
      };
      await FirebaseFirestore.instance.collection('customer').doc(widget.customerDoc!.id).update(data);


      setState(() {
        _status = 'Upload concluído com sucesso!';
      });
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _status = 'Erro ao enviar. Código: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Upload de Imagem - Flutter Web')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageData != null)
              Image.memory(_imageData!, height: 200),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _pickImage, child: Text('Selecionar Imagem')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _uploadImage, child: Text('Enviar')),
            SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
