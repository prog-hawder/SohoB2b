import 'package:b2b/Pages/Home/home.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AcompanharPedidos extends StatefulWidget {
  const AcompanharPedidos({super.key});

  @override
  State<AcompanharPedidos> createState() => _AcompanharPedidosState();
}

class _AcompanharPedidosState extends State<AcompanharPedidos> {
  late Future<List<Pedido>> pedidos;

  @override
  void initState() {
    super.initState();
    pedidos = fetchPedidos();
  }

  Future<List<Pedido>> fetchPedidos() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codcliente = prefs.getString('codCliente');
    String? acesso = prefs.getString('acesso');

    if (codcliente == null || token == null) {
      throw Exception('Credenciais inválidas');
    }

    final response = await http.get(
      Uri.parse('$acesso/snsistemasb2b-api/api/v1/cliente/$codcliente/pedidos'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['content'];
      return data.map((json) => Pedido.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar pedidos');
    }
  }

  // Função para exibir o showDialog com informações detalhadas do pedido
  void _showPedidoDetails(BuildContext context, Pedido pedido) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Produtos do Pedido - ${pedido.numPedido}',style:
                                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...pedido.itens.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          item.produto,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantidade: ${item.quantidade}'),
                            Text(
                              'Total: R\$ ${item.vlTotal.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar Pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: FutureBuilder<List<Pedido>>(
        future: pedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum pedido encontrado.'));
          } else {
            final pedidos = snapshot.data!;
            return ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 16,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(  
              color: _getStatusColor(pedido.status) ,
              width: 2, 
            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppColors.background.withOpacity(0.6),
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Row(
                        children: [
                          Icon(
                            _getStatusIcon(pedido.status),
                            color: _getStatusColor(pedido.status),
                          ),
                          Text(
                              '    Pedido ${pedido.status} - ${pedido.numPedido}'),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Text(
                                'Data do pedido: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(pedido.dtEmissao))}'),
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
                            child: Text(
                                'Previsão de Entrega: ${pedido.dtPrevisaoEntrega}'),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                                'Total do Pedido: R\$ ${pedido.vlTotalPedido.toStringAsFixed(2)}'),
                          )
                        ],
                      ),
                      onTap: () => _showPedidoDetails(context, pedido),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Pedido {
  final int numPedido;
  final String status;
  final String dtEmissao;
  final String dtPrevisaoEntrega;
  final double vlTotalPedido;
  final List<Item> itens;

  Pedido({
    required this.numPedido,
    required this.status,
    required this.dtEmissao,
    required this.dtPrevisaoEntrega,
    required this.vlTotalPedido,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    var list = json['itens'] as List;
    List<Item> itemList = list.map((i) => Item.fromJson(i)).toList();

    return Pedido(
      numPedido: json['numPedido'],
      status: json['status'],
      dtEmissao: json['dtEmissao'],
      dtPrevisaoEntrega: json['dtPrevEntrega'],
      vlTotalPedido: json['vlTotalPedido'].toDouble(),
      itens: itemList,
    );
  }
}

class Item {
  final String produto;
  final double quantidade;
  final double vlTotal;

  Item({
    required this.produto,
    required this.quantidade,
    required this.vlTotal,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      produto: json['produto'],
      quantidade: json['quantidade'].toDouble(),
      vlTotal: json['vlTotal'].toDouble(),
    );
  }
}

IconData _getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'entregue':
      return Icons.check_circle; // Ícone de check verde
    case 'pendente':
      return Icons.access_time; // Ícone de relógio amarelo
    case 'cancelado':
      return Icons.cancel; // Ícone de X vermelho
    case 'caminho entrega':
      return Icons.local_shipping; // Ícone de caminhão verde
    default:
      return Icons.help_outline; // Caso o status seja desconhecido
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'entregue':
      return Colors.green; // Cor verde para "entregue"
    case 'pendente':
      return Colors.amber; // Cor amarela para "pendente"
    case 'cancelado':
      return Colors.red; // Cor vermelha para "cancelado"
    case 'caminho entrega':
      return Colors.green; // Cor verde para "caminho entrega"
    default:
      return Colors
          .grey; // Cor padrão (cinza) caso o status não seja encontrado
  }
}
