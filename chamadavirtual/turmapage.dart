import 'package:flutter/material.dart';


class TurmaPage extends StatefulWidget {
  final String turma;

  const TurmaPage({super.key, required this.turma});

  @override
  TurmaPageState createState() => TurmaPageState();
}

class TurmaPageState extends State<TurmaPage> {
  List<Map<String, dynamic>> alunos = []; //Lista de alunos
  TextEditingController nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    alunos = List<Map<String, dynamic>>.from(widget.turma['alunos']);
  }

  void salvarAlunos() {
    setState(() {
      widget.turma['alunos'] = alunos;
    });
  }

   void adicionarAluno(String nome) {
    if (nome.isNotEmpty) {
      setState(() {
        alunos.add({'nome': nome, 'presente': false});
        salvarAlunos();
      });
    }
  }

   void marcarPresenca(int index, bool? valor) {
    setState(() {
      alunos[index]['presente'] = valor ?? false;
      salvarAlunos();
    });
  }

  void abrirDialogCadastrarAluno() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cadastrar Aluno'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(hintText: 'Nome do Aluno'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                adicionarAluno(nomeController.text);
                nomeController.clear();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Lista de Alunos da ${widget.turma[2]}'), // Acessando o widget.turma
        backgroundColor: const Color.fromARGB(255, 174, 101, 187),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: abrirDialogCadastrarAluno,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: alunos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Checkbox(
              value: alunos[index]['presente'],
              onChanged: (valor) => marcarPresenca(index, valor),
            ),
            title: Text(alunos[index]['nome']),
          );
        },
      ),
    );
  }
}