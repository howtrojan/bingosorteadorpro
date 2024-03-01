import 'package:flutter/material.dart';
import 'package:com.meuapp.bingosorteadorpro/main.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<void> _backgroundsLoaded; // Future para carregar os backgrounds

  @override
  void initState() {
    super.initState();
    // Inicie o carregamento dos backgrounds em segundo plano
    _backgroundsLoaded = _preLoadBackgrounds();

    // Aguarde 2 segundos (ou o tempo que desejar)
    Future.delayed(Duration(seconds: 2), () {
      // Após 2 segundos (ou quando os backgrounds estiverem carregados), navegue para a próxima tela
      if (_backgroundsLoaded != null) {
        _backgroundsLoaded.then((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BingoGame()));
        });
      }
    });
  }

  Future<void> _preLoadBackgrounds() async {
    try {
      // Carregue os backgrounds em segundo plano
      await loadImage('assets/background1.png'); // Substitua pelo caminho das imagens
      await loadImage('assets/background2.png');
      // Adicione mais backgrounds, se necessário
    } catch (error) {
      // Lide com erros de carregamento de imagens
    }
  }

  Future<void> loadImage(String imagePath) async {
    // Simule um atraso de carregamento de imagem
    await Future.delayed(Duration(seconds: 1));
    // Carregue a imagem de verdade aqui
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'assets/imageminicial.png',
                fit: BoxFit.fill, // Preenche a altura e largura da tela
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
