import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  //var teste = getApiLocal();
}

Future<List<Nome>> getApi() async {
  var url = "https://servicodados.ibge.gov.br/api/v2/censos/nomes/ranking";
  var response = await http.get(Uri.parse(url));
  var json = jsonDecode(response.body)[0];
  var res = json['res'] as List;

  var dados = res.map((data) => Nome.fromJson(data)).toList();

  return dados;
}

Future<List<Nome>> getApiLocal() async {
  HttpClient client = HttpClient();
  //COMO É LOCAL TEM QUE ADD ESSA CONFIGURAÇÃO DE VERIFICADOR DE CERTIFICADO
  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  var url = "https://10.0.2.2:7164/Users";
  var request = await client.getUrl(
    Uri.parse(url),
  );

  var response = await request.close();
  var json = await response.transform(const Utf8Decoder()).join();

  var res = jsonDecode(json) as List;
  var dados = res.map((data) => Nome.fromJson(data)).toList();

  return dados;
}

class Nome {
  String nome;
  int frequencia;
  int ranking;

  Nome({required this.nome, required this.frequencia, required this.ranking});

  factory Nome.fromJson(Map<String, dynamic> json) {
    return Nome(
        nome: json['nome'],
        frequencia: json['frequencia'],
        ranking: json['ranking']);
  }

  @override
  String toString() {
    return 'Nome: {nome: $nome, frequencia: $frequencia, ranking: $ranking}}';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root
  // of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "ListView.builder",
        theme: ThemeData(primarySwatch: Colors.green),
        debugShowCheckedModeBanner: false,
        home: const ListViewBuilder());
  }
}

class ListViewBuilder extends StatefulWidget {
  const ListViewBuilder({Key? key}) : super(key: key);

  @override
  State<ListViewBuilder> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<ListViewBuilder> {
  List<Nome> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData(); // Loading the diary when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ListView.builder")),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text("Nome: " + data[index].nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Frequencia: " + data[index].frequencia.toString()),
                        Text("Ranking: " + data[index].ranking.toString()),
                        const Divider(),
                      ],
                    ));
              }),
    );
  }

  void getData() async {
    //Api Externa
    //var api = await getApi();
    //Api Local
    var api = await getApiLocal();
    setState(() {
      data = api;
      isLoading = false;
    });
  }
}
