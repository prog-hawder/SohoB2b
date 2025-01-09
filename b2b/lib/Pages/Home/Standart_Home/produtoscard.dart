// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, unused_local_variable

import 'package:b2b/Lists/product.dart';
import 'package:b2b/Pages/Produto/ProdutoPage.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Produtoscard extends StatefulWidget {
  const Produtoscard({super.key});

  @override
  State<Produtoscard> createState() => _ProdutoscardState();
}

class _ProdutoscardState extends State<Produtoscard> {
  Future<List<Produtos>>? produtos;

  @override
  void initState() {
    super.initState();
    produtos = fetchProdutos();
  }

  Future<List<Produtos>> fetchProdutos() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codcliente = prefs.getString('codCliente');
    String? acesso = prefs.getString('acesso'); 

    if (codcliente == null || token == null) {
      throw Exception('Credenciais inválidas');
    }

    final response = await http.get(
      Uri.parse('$acesso/snsistemasb2b-api/api/v1/cliente/$codcliente/produtos/mais-vendidos'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> produtosJson = jsonResponse['content'];
      return produtosJson.map((data) => Produtos.fromJson(data)).toList();
    } else {
      throw Exception('Erro ao carregar produtos');
    }
  }

  final formatCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 23,
                mainAxisSpacing: 18,
                childAspectRatio: 0.66,
              ),
              itemCount: produtosList.length,
              itemBuilder: (context, index) {
                final produto = produtosList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Produtopage(produtos: produto)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                          Container(
                            height: MediaQuery.of(context).size.width * 0.27,
                            width: MediaQuery.of(context).size.width * 0.27,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: produto.imgPath == 'null'
                                  ? Image.asset('assets/Logo.png', fit: BoxFit.cover)
                                  : Image.memory(base64Decode(produto.imgPath), fit: BoxFit.fill),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                capitalizeFirstLetter(produto.nome)
                                , maxLines: 3,
  overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                formatCurrency.format(double.parse(produto.preco)).replaceAll('.', ','),
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
