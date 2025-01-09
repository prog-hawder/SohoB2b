// ignore_for_file: use_super_parameters, annotate_overrides, prefer_const_constructors, sized_box_for_whitespace, unnecessary_null_comparison, prefer_const_literals_to_create_immutables, file_names

import 'dart:convert';
import 'package:b2b/Lists/departamentos.dart';
import 'package:b2b/Lists/product.dart';
import 'package:b2b/Pages/Home/home.dart';
import 'package:b2b/Pages/Produto/ProdutoPage.dart';
import 'package:b2b/Standart/appbar.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Proddepart extends StatefulWidget {
  final Departamento departamento;

  const Proddepart({Key? key, required this.departamento}) : super(key: key);

  @override
  State<Proddepart> createState() => _ProddepartState();
}

class _ProddepartState extends State<Proddepart> {
  Future<List<Produtos>>? produtos;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    produtos = fetchProdutos();
  }

  Future<List<Produtos>> fetchProdutos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codcliente = prefs.getString('codCliente');
        String? acesso = prefs.getString('acesso'); 

    if (codcliente == null || token == null) {
      throw Exception('Token ou código do cliente não encontrado');
    }

    final response = await http.get(
      Uri.parse(
          '$acesso/snsistemasb2b-api/api/v1/cliente/$codcliente/produtos/departamento/${widget.departamento.codigo}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (!jsonResponse.containsKey('content')) {
        throw Exception('Chave "content" não encontrada na resposta');
      }

      List<dynamic> produtosJson = jsonResponse['content'];
      return produtosJson.map((data) => Produtos.fromJson(data)).toList();
    } else {
      throw Exception(
          'Erro ao carregar produtos: Token: $token, Código do Cliente: $codcliente');
    }
  }

  final formatCurrency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text; // Handle empty string
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: 20),
          Appbarwidget(
            scaffoldKey: _scaffoldKey,
            icon: Icons.arrow_back,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          departamentos(),
        ],
      ),
    );
  }

  Expanded departamentos() {
    return Expanded(
          child: FutureBuilder<List<Produtos>>(
            future: produtos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Nenhum produto encontrado.'));
              }

              List<Produtos> produtosList = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: produtosList.length,
                itemBuilder: (context, index) {
                  final produto = produtosList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Produtopage(produtos: produto)),
                        );
                      },
                      child: Container(
                        height:  MediaQuery.of(context).size.width * 0.32,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white, // Cor de fundo blush
                          borderRadius: BorderRadius.circular(
                              20), // Bordas arredondadas
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  height: MediaQuery.of(context).size.width * 0.27,
                                  width: MediaQuery.of(context).size.width * 0.27,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: produto.imgPath == 'null'
                                        ? Image.asset(
                                            'assets/Logo.png',
                                          )
                                        : Image.memory(
                                            base64Decode(produto.imgPath),
                                            fit: BoxFit.fill,
                                          ),
                                  )),
                            ),
                            SizedBox(
                              width:  MediaQuery.of(context).size.width * 0.03,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height:  MediaQuery.of(context).size.width * 0.05,
                                ),
                                SizedBox(
                                  height:  MediaQuery.of(context).size.width * 0.14,
                                  width:  MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    capitalizeFirstLetter(produto.nome), maxLines: 2,
  overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  formatCurrency
                                      .format(double.parse(produto.preco)),
                                  style: TextStyle(
                                      fontSize: 20, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
  }
}
