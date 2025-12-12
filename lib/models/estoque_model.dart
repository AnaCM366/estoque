class NovoEstoque {
  final String id;
  final String nomeProduto;
  final DateTime dataInclusao;
  final int quantidade;
  final String categoria;
  final String descricao;
  final bool disponivel;

  NovoEstoque({
    required this.id,
    required this.nomeProduto,
    required this.dataInclusao,
    required this.quantidade,
    required this.categoria,
    required this.descricao,
    required this.disponivel,
  });

  factory NovoEstoque.fromJson(Map<String, dynamic> json) {
    return NovoEstoque(
      id: json['id'],
      nomeProduto: json['produto'],
      dataInclusao: DateTime.fromMicrosecondsSinceEpoch(json['data']),
      quantidade: json['quantidade'],
      categoria: json['categoria'],
      descricao: json['descricao'],
      disponivel: json['disponivel'],
    );
  }
}
