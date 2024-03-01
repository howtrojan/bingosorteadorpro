import 'package:flutter/material.dart';

import 'package:com.meuapp.bingosorteadorpro/ad_helper.dart';


class BingoWinPage extends StatefulWidget {
  @override
  _BingoWinPageState createState() => _BingoWinPageState();
}

class _BingoWinPageState extends State<BingoWinPage> {
  @override
  void initState() {
    super.initState(); // Adicione esta linha

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bingo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/bingo_win.gif',  // Substitua com o caminho correto para o seu arquivo GIF
              width: 200, // Ajuste o tamanho conforme necessário
            ),
            SizedBox(height: 16),
            Text(
              'Bingo!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegar de volta para a página anterior (se necessário)
                Navigator.of(context).pop();
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
