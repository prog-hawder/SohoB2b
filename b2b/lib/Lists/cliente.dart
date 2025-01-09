class Cliente {
  final int codempresa;
  final String nome;
  final String email;
  final double vlLimiteCredito;
  final double vlCreditoUtilizado;
  final double vlCreditoDisponivel;
  final double vlMinimoPedido;

  Cliente(
      {required this.nome,
      required this.email,
      required this.vlLimiteCredito,
      required this.vlCreditoUtilizado,
      required this.vlCreditoDisponivel,
      required this.vlMinimoPedido,
      required this.codempresa});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      codempresa: json['codEmpresa'],
      vlMinimoPedido: json['vlMinimoPedido'],
      nome: json['nome'].toString(),
      email: json['email'],
      vlLimiteCredito: json['vlLimiteCredito'],
      vlCreditoUtilizado: json['vlCreditoUtilizado'],
      vlCreditoDisponivel: json['vlCreditoUtilizado'],
    );
  }
}
