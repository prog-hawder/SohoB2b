// ignore_for_file: camel_case_types

import 'dart:convert';
import 'package:b2b/Lists/cliente.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  Future<Cliente>? cliente;

  @override
  void initState() {
    super.initState();
    cliente = fetchCliente();
  }

  Future<Cliente> fetchCliente() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codCliente = prefs.getString('codCliente');
    String? acesso = prefs.getString('acesso');

    if (codCliente == null || token == null) {
      throw Exception('Token ou código do cliente não encontrado');
    }

    try {
      final response = await http.get(
        Uri.parse('$acesso/snsistemasb2b-api/api/v1/cliente/$codCliente'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Cliente.fromJson(
            jsonResponse); // Assegure que a classe Cliente tenha o método fromJson
      } else {
        throw Exception('Erro ao carregar produto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao realizar a requisição: $e');
    }
  }

  final formatCurrency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<Cliente>(
            future: cliente,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Nenhum dado encontrado.'));
              }

              final cliente = snapshot.data!;

              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(height: 60),
                  ListTile(
                    title: Row(
                      children: [
                        const Icon(
                          Icons.account_circle_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          capitalizeFirstLetter(cliente.nome).length > 20
      ? capitalizeFirstLetter(cliente.nome).substring(0,28)
      : capitalizeFirstLetter(cliente.nome),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SizedBox(
                        height: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.paid_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Limite total: ${formatCurrency.format(cliente.vlLimiteCredito)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.paid_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Limite utilizado: ${formatCurrency.format(cliente.vlCreditoUtilizado)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.paid_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Limite disponivel: ${formatCurrency.format(cliente.vlCreditoUtilizado)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.black45,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        SizedBox(
                            height: 60,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/svgicons/store.svg',
                                  color: AppColors.primary,
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox( width: 20,),
                                const Text('Inicio', style: TextStyle(color: AppColors.primary, fontSize: 20),)
                              ],
                            )),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
