import 'dart:convert';
import 'package:b2b/Lists/cliente_venda.dart';
import 'package:b2b/Pages/FinalizarpedidoPage/StandartFinalizarPedido/body.dart';
import 'package:b2b/Pages/Pedido/PedidoPage.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Pagamento extends StatefulWidget {
  const Pagamento({super.key});

  @override
  State<Pagamento> createState() => _PagamentoState();
}

class _PagamentoState extends State<Pagamento> {
  Future<ClienteVenda>? clienteVenda;
  Cobranca? selectedCobranca;
  PrazoPagamento? selectedPrazo;

  @override
  void initState() {
    super.initState();
    clienteVenda = fetchClienteVenda();
  }

  

  Future<ClienteVenda> fetchClienteVenda() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codcliente = prefs.getString('codCliente');
    String? acesso = prefs.getString('acesso');

    if (codcliente == null || token == null) {
      throw Exception('Token ou código do cliente não encontrado');
    }

    final response = await http.get(
      Uri.parse(
          '$acesso/snsistemasb2b-api/api/v1/cliente/cliente-venda/$codcliente'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return ClienteVenda.fromJson(jsonResponse);
    } else {
      throw Exception('Erro ao carregar dados');
    }
  }

  final formatCurrency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);

  // Função para exibir o pop-up de seleção de cobrança
  void _showCobrancaDialog(List<Cobranca> cobrancas) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecione uma Cobrança'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cobrancas.map((cobranca) {
                return ListTile(
                  title: Text(cobranca.descricao),
                  onTap: () {
                    setState(() {
                      selectedCobranca = cobranca;
                      selectedPrazo = null; // Limpa o prazo selecionado
                    });
                    Navigator.of(context).pop(); // Fecha o dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Função para exibir o pop-up de seleção de prazo
  void _showPrazoDialog(List<PrazoPagamento> prazos) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecione um Prazo'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: prazos.map((prazo) {
                return ListTile(
                  title: Text(prazo.descricao),
                  onTap: () {
                    setState(() {
                      selectedPrazo = prazo;
                    });
                    Navigator.of(context).pop(); // Fecha o dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  String? _opcaoSelecionada = 'Entrega';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () {
        // Fecha o teclado quando o usuário clica fora
        FocusScope.of(context).requestFocus(FocusNode());
      },
        child: FutureBuilder<ClienteVenda>(
          future: clienteVenda,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('Nenhum dado encontrado.'));
            } else {
              ClienteVenda cliente = snapshot.data!;
        
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Pedido()),
                            );
                          },
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pagamento',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(width: 50),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        // Radio Buttons para seleção de entrega ou retirada
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _opcaoSelecionada = 'Entrega';
                                      });
                                    },
                                    child: Container(
                                      width: 150,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Entrega',
                                                style: TextStyle(
                                                    color: AppColors.background)),
                                            Radio<String>(
                                              value: 'Entrega',
                                              groupValue: _opcaoSelecionada,
                                              onChanged: (String? value) {
                                                setState(() {});
                                              },
                                              activeColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _opcaoSelecionada = 'Retirada';
                                      });
                                    },
                                    child: Container(
                                      width: 150,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Retirada',
                                                style: TextStyle(
                                                    color: AppColors.background)),
                                            Radio<String>(
                                              value: 'Retirada',
                                              groupValue: _opcaoSelecionada,
                                              onChanged: (String? value) {
                                                setState(() {});
                                              },
                                              activeColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
        
                        SizedBox(height: 20),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Forma de pagamento:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(width: 40),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showCobrancaDialog(cliente.cobrancas);
                                  },
                                  child: Container(
                                    width: 210,
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        selectedCobranca != null
                                            ? selectedCobranca!.descricao
                                            : 'Selecione uma Cobrança',
                                        style: TextStyle(
                                            color: AppColors.background,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 40),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(width: 40),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: selectedCobranca == null
                                      ? null // Desabilita o botão se nenhuma cobrança foi selecionada
                                      : () {
                                          _showPrazoDialog(
                                              selectedCobranca!.planosPagamentos);
                                        },
                                  child: Container(
                                    width: 150,
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        selectedPrazo != null
                                            ? selectedPrazo!.descricao
                                            : 'Selecione o Prazo',
                                        style: TextStyle(
                                            color: AppColors.background,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 40),
                              ],
                            ),
                          ],
                        ),
                        // Botão para Prazo
                      ],
                    ),
                    SizedBox(width: 40),
                    Valores( plano: selectedPrazo != null ? selectedPrazo!.codigo : 0, cobranca: selectedCobranca != null ? selectedCobranca!.codigo : '',),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
  
}
