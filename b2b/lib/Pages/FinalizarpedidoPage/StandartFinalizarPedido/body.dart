import 'package:b2b/Lists/cart.provider.dart';
import 'package:b2b/Pages/FinalizarpedidoPage/StandartFinalizarPedido/finalizei.dart';
import 'package:b2b/Themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class Valores extends StatefulWidget {
  final int plano;
  final String cobranca;
  const Valores({super.key, required this.plano, required this.cobranca});
  @override
  State<Valores> createState() => _ValoresState();
}

class _ValoresState extends State<Valores> {
  final formatCurrency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);
  String errorMessage = '';
  double vlTotProdutos = 0.0;
  double vlTotImposto = 0.0;
  double vlTotPedido = 0.0;
  List<Map<String, dynamic>> impostos = [];
  List<Map<String, dynamic>> datas = [];
  late Set<int> unavailableWeekdays;
  DateTime _focusedDay = DateTime.now();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _consulta();
    unavailableWeekdays = _mapToWeekday(datas);
  }

  Future<void> _enviarPedido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codcliente = prefs.getString('codCliente');
    String? acesso = prefs.getString('acesso');

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final produtosNoCarrinho = cartProvider.cartItems;

    List<Map<String, dynamic>> itensPedido = [];
    for (var item in produtosNoCarrinho) {
      double precoUnitario = item.preco != null
          ? double.tryParse(item.preco.toString()) ?? 0.0
          : 0.0;
      int quantidade = item.quantidade;
      double vlTotal = precoUnitario * quantidade;

      itensPedido.add({
        "codProduto": item.codigo,
        "quantidade": quantidade,
        "vlUnitario": precoUnitario,
        "vlDesconto": 0.00,
        "vlVenda": vlTotal,
        "perDesconto": 0.00,
        "vlTotal": vlTotal,
      });
    }

    Map<String, dynamic> requestBody = {
      "codPlanoPgto": widget.plano,
      "statusLogistica": "Aprovado",
      "codCobranca": widget.cobranca,
      "observacao": observacoes,
      "vlTotalProdutos": vlTotProdutos,
      "perDesconto": 0.00,
      "vlDesconto": 0.00,
      "vlTotalPedido": vlTotPedido,
      "dtPrevEntrega": dateFormat.format(_selectedDate),
      "itens": itensPedido,
    };
    try {
      final response = await http.post(
        Uri.parse(
            '$acesso/snsistemasb2b-api/api/v1/cliente/$codcliente/pedidos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PedidoConcluidoPage(),
          ),
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erro ao enviar pedido:'),
                content: Text('${response.statusCode}'),
                actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
              );
            });
      }
    } catch (e) {
      showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erro ao enviar pedido:'),
                content: Text('Erro de conexão: $e'),
                 actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
              );
            });
    }
  }

  Future<void> _consulta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? codcliente = prefs.getString('codCliente');
    String? acesso = prefs.getString('acesso');
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final produtosNoCarrinho = cartProvider.cartItems;

    try {
      // Dicionário para armazenar produtos agrupados por código de produto
      Map<String, Map<String, dynamic>> itensPedido = {};

      // Agrupar os produtos com o mesmo código e somar as quantidades
      for (var item in produtosNoCarrinho) {
        // Garantir que 'preco' seja um valor válido e 'quantidade' seja um número inteiro
        double precoUnitario = item.preco != null
            ? double.tryParse(item.preco.toString()) ?? 0.0
            : 0.0;
        int quantidade = item.quantidade;

        // Agrupar os itens por código de produto
        if (itensPedido.containsKey(item.codigo)) {
          // Se o produto já está no mapa, somamos a quantidade
          itensPedido[item.codigo]!['quantidade'] += quantidade;
        } else {
          // Caso contrário, adicionamos o produto ao mapa
          itensPedido[item.codigo.toString()] = {
            "codProduto": item.codigo,
            "quantidade": quantidade,
            "vlUnitario": precoUnitario,
            "vlDesconto": 0.00,
            "vlVenda": precoUnitario,
            "perDesconto": 0.00
          };
        }
      }

      // Converte os produtos agrupados em uma lista
      List<Map<String, dynamic>> listaItens = itensPedido.values.toList();

      // Corpo da requisição
      Map<String, dynamic> requestBody = {
        "codPlanoPgto": widget.plano,
        "statusLogistica": "P",
        "itens": listaItens,
      };

      final response = await http.post(
        Uri.parse(
            '$acesso/snsistemasb2b-api/api/v1/cliente/$codcliente/pedidos/calcular-pedido'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Cabeçalho Content-Type
        },
        body: jsonEncode(requestBody), // Corpo da requisição como JSON
      );

      if (response.statusCode == 200) {
        // Parse da resposta
        var data = jsonDecode(response.body);

        setState(() {
          vlTotProdutos = data['vlTotProdutos'] ?? 0.0;
          vlTotImposto = data['vlTotImposto'] ?? 0.0;
          vlTotPedido = data['vlTotPedido'] ?? 0.0;
          impostos = List<Map<String, dynamic>>.from(data['impostos'] ?? []);
          datas = List<Map<String, dynamic>>.from(
              data['diasNaoSelecionaveisDtEntrega'] ?? []);
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao calcular pedido: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de conexão: $e';
      });
    }
  }

  Set<int> _mapToWeekday(List<Map<String, dynamic>> datas) {
    final Map<String, int> weekDayMap = {
      "monday": DateTime.monday,
      "tuesday": DateTime.tuesday,
      "wednesday": DateTime.wednesday,
      "thursday": DateTime.thursday,
      "friday": DateTime.friday,
      "saturday": DateTime.saturday,
      "sunday": DateTime.sunday,
    };

    // Garantir que o mapeamento esteja correto
    Set<int> unavailableDays = datas
        .map((item) => weekDayMap[item['dia'].toLowerCase()])
        .where(
            (day) => day != null) // Filtro para garantir que o dia seja válido
        .cast<int>()
        .toSet();

    return unavailableDays;
  }

  DateTime _selectedDate = DateTime.now();
  String observacoes = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data de entrega desejada:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      _showCalendarDialog(context);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        dateFormat.format(_selectedDate), // Formata a data
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Observações sobre o pedido:',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextField(
              onChanged: (text) {
                setState(() {
                  observacoes = text; // Atualiza o estado com as observações
                });
              },
              decoration: InputDecoration(
                hintText: 'Digite suas observações aqui...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2, // Limita o número de linhas do campo de texto
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Produtos:',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(formatCurrency.format(vlTotProdutos),
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Imposto:',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(formatCurrency.format(vlTotImposto),
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Pedido:',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(formatCurrency.format(vlTotPedido),
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  // Mostrar detalhes dos impostos ao clicar
                  _mostrarDetalhesImpostos(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Consultar Impostos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.help,
                      color: AppColors.primary,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed:(widget.plano == 0 || widget.cobranca == 0) ? null : _enviarPedido,
                style: ElevatedButton.styleFrom(
                  backgroundColor:(widget.plano == 0 || widget.cobranca == 0) 
    ? Colors.blueGrey
    : AppColors.primary, 
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Enviar Pedido',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Escolha uma Data'),
              content: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height *
                    0.55, // Altura ajustada para acomodar o calendário
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2050, 12, 31),
                      focusedDay: _focusedDay, // Usando _focusedDay aqui
                      selectedDayPredicate: (day) {
                        return isSameDay(day,
                            _selectedDate); // Verifica se o dia é o selecionado
                      },
                      availableGestures: AvailableGestures.all,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.green, // Cor da data selecionada
                          shape: BoxShape.circle,
                        ),
                        outsideDecoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setDialogState(() {
                          // Atualiza o estado local do dialog
                          _selectedDate = selectedDay; // Atualiza _selectedDate
                          _focusedDay = focusedDay;
                        });
                      },
                      enabledDayPredicate: (day) {
                        return !unavailableWeekdays
                            .contains(day.weekday); // Dias disponíveis
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fechar o dialog
                        setState(() {
                          // Atualiza o estado da tela principal para exibir a nova data
                        });
                      },
                      child: Text('Confirmar Data'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDetalhesImpostos(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes dos Impostos'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: impostos.isNotEmpty
                ? impostos.map((imposto) {
                    return Text(
                        '${imposto['impostoNome']}: ${formatCurrency.format(imposto['impostoValor'])}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ));
                  }).toList()
                : [
                    Text(
                        'Não há impostos aplicados. Valor total da nota: ${formatCurrency.format(vlTotPedido)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ))
                  ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
