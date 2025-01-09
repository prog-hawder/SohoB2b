// ignore_for_file: file_names, use_super_parameters, annotate_overrides, prefer_const_constructors

import 'dart:convert';
import 'package:b2b/Pages/Pedido/PedidoPage.dart';
import 'package:provider/provider.dart';
import 'package:b2b/Lists/cart.provider.dart';
import 'package:b2b/Lists/product.dart';
import 'package:b2b/Pages/Home/home.dart';
import 'package:b2b/Pages/Produto/Standart/outros.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Produtopage extends StatefulWidget {
  final Produtos produtos;
  const Produtopage({Key? key, required this.produtos}) : super(key: key);

  @override
  State<Produtopage> createState() => _ProdutopageState();
}

class _ProdutopageState extends State<Produtopage> {
  Future<Produtos>? produto;
  int quantidade = 1;
  @override
  void initState() {
    super.initState();
    produto = fetchProduto();
  }

  Future<Produtos> fetchProduto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codcliente = prefs.getString('codCliente');
    String? acesso = prefs.getString('acesso');

    if (codcliente == null || token == null) {
      throw Exception('Token ou código do cliente não encontrado');
    }

    final response = await http.get(
      Uri.parse(
          '$acesso/snsistemasb2b-api/api/v1/cliente/$codcliente/produtos/${widget.produtos.codigo}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Produtos.fromJson(jsonResponse);
    } else {
      throw Exception(
          'Erro ao carregar produto: Token: $token, Código do Cliente: $codcliente');
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
      body: SingleChildScrollView(
        child: FutureBuilder<Produtos>(
          future: produto,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('Produto não encontrado.'));
            }
            Produtos produto = snapshot.data!;
            return Column(
              children: [
                Stack(children: [
                  SizedBox(
                    width: double.infinity,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return SizedBox(
                        height: constraints.maxWidth,
                        child: produto.imgPath == 'null'
                            ? Image.asset('assets/Logo.png', fit: BoxFit.fill)
                            : Image.memory(
                                base64Decode(produto.imgPath),
                                fit: BoxFit.fill,
                              ),
                      );
                    }),
                  ),
                  Positioned(
                    top: 40, // Distância do topo
                    left: 20,
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.13,
                      width: MediaQuery.of(context).size.width * 0.13,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.background,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          },
                        ),
                      ),
                    ),
                  )
                ]),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          produto.nome,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        )),
                  ),
                ),
                Center(
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 1.5,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                        height: 50,
                        width: 200,
                        child: Text(
                          capitalizeFirstLetter(produto.descricao),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.4)),
                        )),
                  ),
                ),
                Center(
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 1.5,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        height: 60,
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove,
                                  color: AppColors.primary, size: 17),
                              onPressed: () {
                                setState(() {
                                  if (quantidade > 1) {
                                    quantidade--;
                                  }
                                });
                              },
                            ),
                            Text(
                              quantidade.toString(),
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                            IconButton(
                              icon: Icon(Icons.add,
                                  color: AppColors.primary, size: 17),
                              onPressed: () {
                                setState(() {
                                  quantidade++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 40.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.8,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(
                                    produto.codigo,
                                    quantidade,
                                    produto.nome,
                                    produto.imgPath,
                                    produto.preco);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => Pedido()));
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Adicionar ao carrinho',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.background),
                              ),
                              Text(
                                '${formatCurrency.format(quantidade * double.parse(produto.preco))}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.background),
                              ),
                               
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Outros Produtos como esse',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      )),
                ),
                Outros(
                  produto: produto,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
