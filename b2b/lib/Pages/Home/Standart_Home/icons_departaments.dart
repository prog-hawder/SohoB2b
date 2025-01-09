// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, unused_local_variable

import 'package:b2b/Lists/departamentos.dart';
import 'package:b2b/Pages/ProductDepartamento/ProdDepart.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:b2b/Themes/text.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Depart extends StatefulWidget {
  const Depart({super.key});

  @override
  State<Depart> createState() => _DepartState();
}

class _DepartState extends State<Depart> {
  late Future<List<Departamento>> departamentos;

  @override
  void initState() {
    super.initState();
    departamentos = fetchDepartamentos(); // Inicia a busca dos departamentos
  }

  Future<List<Departamento>> fetchDepartamentos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? acesso = prefs.getString('acesso');
    // Recupera o token

    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.get(
      Uri.parse('$acesso/snsistemasb2b-api/api/v1/departamento'),
      headers: {
        'Authorization': 'Bearer $token', // Adiciona o cabeçalho de autorização
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Departamento.fromJson(data)).toList();
    } else {
      throw Exception('Falha ao carregar departamentos');
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text; // Handle empty string
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: FutureBuilder<List<Departamento>>(
        future: departamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum departamento encontrado.'));
          }

          List<Departamento> departamentosList = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: departamentosList.length,
            itemBuilder: (context, index) {
              final departamento = departamentosList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Proddepart(departamento: departamento),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 40.0,
                      margin: EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(3, 4),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                        color: AppColors.icons,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Icones-Departamentos/${departamento.nomeIcone}.svg',
                            width: 20.0,
                            height: 20.0,
                            color: Colors.black,
                          ),
                          Text(
                            capitalizeFirstLetter(departamento.descricao),
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
