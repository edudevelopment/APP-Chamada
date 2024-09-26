import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste/turmapage.dart';

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
  List<Map<String, dynamic>> turmas = [];

  @override
  void initState() {
    super.initState();
    carregarTurmas();
  }

  Future<void> carregarTurmas() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? turmasString = prefs.getString('turmas');

      if(turmasString != null) {
        setState(() {
          turmas = List<Map<String, dynamic>>.from(json.decode(turmasString));
        });
      }
  }

  Future<void> salvarTurmas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String turmasString = json.encode(turmas);
    await prefs.setString('turmas', turmasString);
  }

  void adicionarTurma() {
    setState(() {
      turmas.add({'nome': 'Turma ${turmas.length + 1}', 'alunos': []});
    });
  } 

  void abrirTurma(Map<String, dynamic> turma) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TurmaPage(turma: 'turma'),
      ),
    ).then((_) => salvarTurmas());
  }

  void excluirTurma(int index) {
    setState(() {
      turmas.removeAt(index);
      salvarTurmas();
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
                          turmas[index]['nome'],
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