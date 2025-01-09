// ignore_for_file: use_super_parameters, annotate_overrides, prefer_const_constructors

import 'dart:convert';
import 'package:b2b/Pages/Produto/ProdutoPage.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:http/http.dart' as http;
import 'package:b2b/Lists/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Outros extends StatefulWidget {
  final Produtos produto;

  const Outros({Key? key, required this.produto}) : super(key: key);

  @override
  State<Outros> createState() => _OutrosState();
}

class _OutrosState extends State<Outros> {
  Future<List<Produtos>>? produtos;

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
          '$acesso/snsistemasb2b-api/api/v1/cliente/$codcliente/produtos/departamento/${widget.produto.departamento}'),
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
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
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

          List<Produtos> produtosLimitados = produtosList.take(6).toList();

          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: produtosLimitados.length,
              itemBuilder: (context, index) {
                final produto = produtosLimitados[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Produtopage(produtos: produto)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.height * 0.18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.width * 0.05),
                          Container(
                              height: MediaQuery.of(context).size.width * 0.27,
                              width: MediaQuery.of(context).size.width * 0.27,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15)),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.10,
                              child: Text(
                                capitalizeFirstLetter(produto.nome),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.width * 0.02),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                formatCurrency
                                    .format(double.parse(produto.preco))
                                    .replaceAll('.', ','),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
