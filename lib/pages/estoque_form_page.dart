import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:estoque/models/estoque_model.dart';
import 'package:flutter/services.dart';

//page de formulário de estoque

class EstoqueFormPage extends StatefulWidget {
  final String? id;
  const EstoqueFormPage({super.key, this.id});

  @override
  State<EstoqueFormPage> createState() => _EstoqueFormPageState();
}

class _EstoqueFormPageState extends State<EstoqueFormPage> {
  late TextEditingController controllerProduto;
  late TextEditingController controllerQuantidade;
  late TextEditingController controllerCategoria;
  late TextEditingController controllerDescricao;
  late TextEditingController controllerData;
  DateTime selectedDate = DateTime.now();
  late TextEditingController controllerDisponivel;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  NovoEstoque? _estoque;

  @override
  void initState() {
    controllerProduto = TextEditingController();
    controllerQuantidade = TextEditingController();
    controllerCategoria = TextEditingController();
    controllerDescricao = TextEditingController();
    controllerData = TextEditingController(
      text: selectedDate.toIso8601String(),
    );
    controllerDisponivel = TextEditingController();

    if (widget.id != null) {
      _loadNovoEstoque(widget.id!);
    }
    super.initState();
  }

  @override
  void dispose() {
    controllerProduto.dispose();
    controllerQuantidade.dispose();
    controllerCategoria.dispose();
    controllerDescricao.dispose();
    controllerData.dispose();
    controllerDisponivel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.id == null ? "Cadastro de Estoque" : "Editar Estoque",
        ),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              // função de adicionar informação do nome do produto
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerProduto,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite o nome do produto',
                ),
                validator: (value) => _validarProduto(value),
              ),
            ),
            Padding(
              // função de adicionar informação da quantidade do produto
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerQuantidade,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite a quantidade',
                ),
                validator: (value) => _validarQuantidade(value),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerCategoria,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite a categoria',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerDescricao,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite a descrição',
                ),
              ),
            ),
            Padding(
              // função de adicionar informação da data de inclusão do produto
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerData,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite a data',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: controllerDisponivel.text == "true",
                    onChanged: (value) {
                      setState(() {
                        controllerDisponivel.text = value == true
                            ? "true"
                            : "false";
                      });
                    },
                  ),
                  const Text("Disponível"),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _salvarEstoque,
              label: Text("Salvar Produto"),
              icon: Icon(Icons.save_alt_outlined),
            ),
          ],
        ),
      ),
    );
  }

  String? _validarProduto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O nome do produto é obrigatório.';
    }
    return null;
  }

  String? _validarQuantidade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'A quantidade é obrigatória.';
    }
    final quantidade = int.tryParse(value);
    if (quantidade == null || quantidade < 0) {
      return 'A quantidade deve ser um número inteiro positivo.';
    }
    return null;
  }

  Future<void> _salvarEstoque() async {
    final nomeProduto = controllerProduto.text;
    final quantidade = int.parse(controllerQuantidade.text);
    final categoria = controllerCategoria.text;
    final descricao = controllerDescricao.text;
    final dataInclusao = selectedDate.microsecondsSinceEpoch;
    final disponivel = controllerDisponivel.text.toLowerCase() == 'true';

    if (formKey.currentState?.validate() == true) {
      // Aqui você pode salvar o novo estoque no banco de dados ou em outra fonte de dados.
      var dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 30),
          baseUrl: 'https://6912666052a60f10c8218ac5.mockapi.io/api/v1',
        ),
      );

      if (widget.id == null) {
        await dio.post(
          '/estoque',
          data: {
            'produto': nomeProduto,
            'quantidade': quantidade,
            'categoria': categoria,
            'descricao': descricao,
            'data': dataInclusao,
            'disponivel': disponivel,
          },
        );
      } else {
        await dio.put(
          '/estoque/${widget.id}',
          data: {
            'produto': nomeProduto,
            'quantidade': quantidade,
            'categoria': categoria,
            'descricao': descricao,
            'data': dataInclusao,
            'disponivel': disponivel,
          },
        );
      }

      if (!context.mounted) return;
      Navigator.pop(context); // Volta para a tela anterior após salvar.
    }
  }

  Future<void> _loadNovoEstoque(String id) async {
    var dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        baseUrl: 'https://6912666052a60f10c8218ac5.mockapi.io/api/v1',
      ),
    );

    var response = await dio.get('/estoque/$id');
    if (response.statusCode == 200) {
      setState(() {
        _estoque = NovoEstoque.fromJson(response.data);
        controllerProduto.text = _estoque!.nomeProduto;
        controllerQuantidade.text = _estoque!.quantidade.toString();
        controllerCategoria.text = _estoque!.categoria;
        controllerDescricao.text = _estoque!.descricao;
        controllerData.text = _estoque!.dataInclusao.toIso8601String();
        controllerDisponivel.text = _estoque!.disponivel.toString();
      });
    } else {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar o estoque.')));
    }
  }
}
