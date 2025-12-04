import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EstoqueFormPage extends StatefulWidget {
  const EstoqueFormPage({super.key, required this.name});

  final ;

  @override
  State<EstoqueFormPage> createState() => _EstoqueFormPageState();
}

class _EstoqueFormPageState extends State<EstoqueFormPage> {
  late TextEditingController controllerProduto;
  late TextEditingController controllerQuantidade;
  late TextEditingController controllerData;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controllerProduto = TextEditingController();
    controllerQuantidade = TextEditingController();
    controllerData = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controllerProduto.dispose();
    controllerQuantidade.dispose();
    controllerData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro de Estoque")),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
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
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerQuantidade,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite a quantidade',
                ),
                validator: (value) => _validarQuantidade(value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerData,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite a data',
                ),
                validator: (value) => _validarData(value),
              ),
            ),
            ElevatedButton(
              onPressed: _salvarEstoque,
              child: Text("Salvar Estoque"),
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

  String? _validarData(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'A data é obrigatória.';
    }
    // Aqui você pode adicionar uma validação mais robusta para a data, se necessário.
    return null;
  }

  Future<void> _salvarEstoque() async {
    final nomeProduto = controllerProduto.text;
    final quantidade = int.parse(controllerQuantidade.text);
    final dataInclusao = DateTime.parse(controllerData.text);

    if (formKey.currentState?.validate() == true) {
      // Aqui você pode salvar o novo estoque no banco de dados ou em outra fonte de dados.
      var dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 30),
          baseUrl: 'https://6912666052a60f10c8218ac5.mockapi.io/api/v1',
        ),
      );
      var response = await dio.post(
        '/estoque',
        data: {
          'produto': nomeProduto,
          'quantidade': quantidade,
          'data': dataInclusao.toIso8601String(),
        },
      );
      if (!context.mounted) return;
      Navigator.pop(context); // Volta para a tela anterior após salvar.
    }
  }
}
