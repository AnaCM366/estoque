import 'package:dio/dio.dart';
import 'package:estoque/models/estoque_model.dart';
import 'package:estoque/pages/estoque_form_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NovoEstoque> estoques = [];

  bool isloading = true;

  @override
  void initState() {
    super.initState();
    _carregarEstoques();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _carregarEstoques() async {
    setState(() {
      isloading = true;
    });

    var dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        baseUrl: 'https://6912666052a60f10c8218ac5.mockapi.io/api/v1',
      ),
    );

    var response = await dio.get('/estoque');

    var listarDados = response.data as List;
    for (var dados in listarDados) {
      var estoque = NovoEstoque(
        nomeProduto: dados['produto'],
        quantidade: dados['quantidade'],
        dataInclusao: DateTime.parse(dados['data']),
      );
      estoques.add(estoque);
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: isloading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: estoques.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(estoques[index].nomeProduto),
                  subtitle: Column(
                    children: [
                      Text(estoques[index].quantidade.toString()),
                      Text(estoques[index].dataInclusao.toString()),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Confirmar exclusão"),
                            content: const Text(
                              "Deseja realmente excluir este item?",
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Cancelar"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text(
                                  "Excluir",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmar == true) {
                        setState(() {
                          estoques.removeAt(index);
                        });
                      }
                    },
                  ),
                  isThreeLine: true,
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarEstoque,
        tooltip: 'Adicionar Estoque',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _adicionarEstoque() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) {
              return EstoqueFormPage();
            },
          ),
        )
        .then((_) {
          estoques.clear();
          _carregarEstoques();
        });
  }
}
