class ClienteVenda {
  final String nome;
  final String cpfCnpj;
  final List<Cobranca> cobrancas;

  ClienteVenda(
      {required this.nome, required this.cpfCnpj, required this.cobrancas});

  factory ClienteVenda.fromJson(Map<String, dynamic> json) {
    // Adaptar conforme a estrutura do seu JSON
    var cobrancasJson = json['listCobrancas'] as List;
    List<Cobranca> cobrancasList =
        cobrancasJson.map((data) => Cobranca.fromJson(data)).toList();

    return ClienteVenda(
      nome: json['nome'] ?? '',
      cpfCnpj: json['cpfCnpj'] ?? '',
      cobrancas: cobrancasList,
    );
  }
}

class Cobranca {
  final String codigo;
  final String descricao;
  final List<PrazoPagamento> planosPagamentos;

  Cobranca({required this.descricao, required this.planosPagamentos, required this.codigo});

  factory Cobranca.fromJson(Map<String, dynamic> json) {
    var planosJson = json['listPlanoPagamentos'] as List;
    List<PrazoPagamento> planosList =
        planosJson.map((data) => PrazoPagamento.fromJson(data)).toList();

    return Cobranca(
      codigo :json['codigo'] ?? '',
      descricao: json['descricao'] ?? '',
      planosPagamentos: planosList,
    );
  }
}

class PrazoPagamento {
  final int codigo;
  final String descricao;
  final double txFinanPgto;

  PrazoPagamento({required this.descricao, required this.txFinanPgto, required this.codigo});

  factory PrazoPagamento.fromJson(Map<String, dynamic> json) {
    return PrazoPagamento(
      codigo:json['codigo'] ?? '',
      descricao: json['descricao'] ?? '',
      txFinanPgto: json['txFinanPgto']?.toDouble() ?? 0.0,
    );
  }
}
