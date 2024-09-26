import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TelaInicial(
        title: 'Chamada Virtual',
      ),
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key, required this.title});
  final String title;

  @override
  State<TelaInicial> createState() => TelaInicialState();
}

class TelaInicialState extends State<TelaInicial> {
  List<String> turmas = [];

  void adicionarTurma() {
    setState(() {
      turmas.add('Turma ${turmas.length + 1}');
    });
  }

  void abrirTurma(String turma) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TurmaPage(turma: turma),
      ),
    );
  }

  void excluirTurma(int index) {
    setState(() {
      turmas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Turmas'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        backgroundColor: const Color.fromARGB(255, 139, 57, 153),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 2,
          crossAxisCount: 2, // Número de colunas
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: turmas.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color.fromARGB(255, 252, 243, 253),
            elevation: 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          abrirTurma(turmas[index]), // Abre a tela da turma
                      child: Center(
                        child: Text(
                          turmas[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: .1,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => excluirTurma(index), // Exclui a turma
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarTurma, // Adiciona uma turma ao clicar
        tooltip: 'Adicionar Turma',
        backgroundColor: const Color.fromARGB(255, 139, 57, 153),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TurmaPage extends StatefulWidget {
  final String turma;

  const TurmaPage({Key? key, required this.turma}) : super(key: key);

  @override
  TurmaPageState createState() => TurmaPageState();
}

class TurmaPageState extends State<TurmaPage> {
  List<Map<String, dynamic>> alunos = []; //Lista de alunos
  TextEditingController nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? alunosString = prefs.getString('alunos');

    if (alunos != null) {
      setState(() {
        alunos = List<Map<String, dynamic>>.from(json.decode(alunosString!));
      });
    }
  }

  Future<void> salvarDados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String alunosString = json.encode(alunos);
    await prefs.setString('alunos', alunosString);
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

  void adicionarAluno(String nome) {
    if (nome.isNotEmpty) {
      setState(() {
        alunos.add({'nome': nome, 'presente': false});
        salvarDados();
      });
    }
  }

  void marcarPresenca(int index, bool? valor) {
    setState(() {
      alunos[index]['presente'] = valor ?? false;
      salvarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Lista de Alunos da ${widget.turma}'), // Acessando o widget.turma
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
