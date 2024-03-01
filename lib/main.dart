import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:com.meuapp.bingosorteadorpro/gerador-cartela.dart';
import 'package:com.meuapp.bingosorteadorpro/gerador-cartela-codigo.dart';
import 'package:com.meuapp.bingosorteadorpro/loading_page.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter/material.dart';




void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 20,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      home: LoadingScreen(),
    );
  }
}

class BingoGame extends StatefulWidget {
  @override
  _BingoGameState createState() => _BingoGameState();
}

class _BingoGameState extends State<BingoGame> {


  double speechRate = 0.3;
  int numbersPerRound = 75;
  List<int> numbersCalled = [];
  Set<int> markedNumbers = Set();
  List<int> last5Numbers = [];
  FlutterTts flutterTts = FlutterTts();
  bool isAssistantEnabled = true;
  bool isVibrationEnabled = false; // Adicione esta variável
  bool isScreenAwake = false;
  String currentBackground =
      'assets/background1.jpg'; // Substitua com o caminho da imagem de fundo padrão

  final AudioPlayer audioPlayer = AudioPlayer();
  int userDefinedNumber = 0;
  String gameCode = '';
  int gameSeed = 0;
  String code = "";


// ...


  @override
  void initState() {
    super.initState();
    initTts();
    gameCode = generateGameCode(0);

    // Inicialize o Google Mobile Ads SDK


    // Crie e carregue o banner de anúncios
  }


  Future initTts() async {
    await flutterTts.setLanguage("pt-BR"); // Defina o idioma apropriado
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(speechRate);
  }

  Map<String, List<int>> columnNumbers = {
    'B': [],
    'I': [],
    'N': [],
    'G': [],
    'O': [],
  };

  _BingoGameState() {
    generateColumnNumbers();
  }

  Future<void> playBingoSound() async {
    final player = AudioPlayer();
    await player.setAsset('assets/audio.mp3');
    await player.play();
  }

  void generateColumnNumbers() {
    columnNumbers = {
      'B': List.generate(numbersPerRound ~/ 5, (index) => index + 1),
      'I': List.generate(
          numbersPerRound ~/ 5, (index) => index + numbersPerRound ~/ 5 + 1),
      'N': List.generate(numbersPerRound ~/ 5,
              (index) => index + numbersPerRound ~/ 5 * 2 + 1),
      'G': List.generate(numbersPerRound ~/ 5,
              (index) => index + numbersPerRound ~/ 5 * 3 + 1),
      'O': List.generate(numbersPerRound ~/ 5,
              (index) => index + numbersPerRound ~/ 5 * 4 + 1),
    };
  }

  int drawNumber() {
    List<int> availableNumbers = [];
    columnNumbers.values.forEach((column) {
      availableNumbers
          .addAll(column.where((num) => !numbersCalled.contains(num)));
    });
    if (availableNumbers.isEmpty) {
      return -1;
    }
    int drawnNumber =
    availableNumbers[Random().nextInt(availableNumbers.length)];
    numbersCalled.add(drawnNumber);

    if (last5Numbers.length == 5) {
      last5Numbers.removeAt(0);
    }
    last5Numbers.add(drawnNumber);

    return drawnNumber;
  }

  void speakNumber(String letra, int number) async {
    if (isAssistantEnabled) {
      await flutterTts.speak(letra + number.toString());
    }
  }

  Widget strokedText(String text, TextStyle textStyle) {
    return StrokeText(
      text: text,
      textStyle: textStyle,
      strokeWidth: 2, // Largura do contorno
      strokeColor: Colors.black, // Cor do contorno
    );
  }

  Future<void> changeBackground(BuildContext context) async {
    String? newBackground = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: strokedText('Escolher Fundo', TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 15,
          ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: strokedText('Fundo 1', TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontSize: 15,
                ),),
                onTap: () {
                  Navigator.pop(context, 'assets/background1.jpg');
                },
              ),
              ListTile(
                title: strokedText('Fundo 2', TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontSize: 15,
                ),),
                onTap: () {
                  Navigator.pop(context, 'assets/background2.jpg');
                },
              ),
              // Adicione mais opções conforme necessário
            ],
          ),
        );
      },
    );

    if (newBackground != null) {
      setState(() {
        currentBackground = newBackground;
      });
    }
  }

  String generateGameCode(int seed) {
    Random random = Random(seed);
    String letters = String.fromCharCodes(
        List.generate(2, (index) => random.nextInt(26) + 65));
    String numbers = (random.nextInt(10000) % 1000).toString().padLeft(3, '0');
    return '$letters$numbers';
  }


  void showNumberOfNumbersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Escolha a quantidade de números:'),
          children: [
            for (int value in [75, 30, 80, 90])
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    numbersPerRound = value;
                    generateColumnNumbers();
                    numbersCalled.clear();
                    markedNumbers.clear();
                    last5Numbers.clear();
                  });
                  Navigator.pop(context);
                },
                child: Text('$value números'),
              ),
          ],
        );
      },
    );
  }

  void showGenerateCardDialogCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: strokedText(
                  'Gerar Cartela com Código',
                  TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              strokedText(
                'Digite o código (5 caracteres):',
                TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              TextField(
                onChanged: (value) {
                  code = value.toUpperCase();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: strokedText(
                'Cancelar',
                TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (code.length == 5 && RegExp(r'^[A-Z0-9]*$').hasMatch(code)) {
                  // O código tem exatamente 5 caracteres e contém apenas letras maiúsculas e números
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GenerateCardWithCodePage(
                            numbersPerRound: numbersPerRound,
                            code: code,
                          ),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Erro',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            color: Colors.red,
                          ),
                        ),
                        content: Text(
                          'O código deve ter 5 caracteres alfanuméricos.',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: strokedText(
                'Gerar Cartela',
                TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void showGenerateCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: strokedText('Gerar Cartela', TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 15,
          ),),
          content: strokedText('Escolha uma opção:', TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 15,
          ),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BingoCardPage(
                          numbersPerRound: numbersPerRound,
                        ),
                  ),
                );
              },
              child: strokedText('Gerar Cartela', TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontSize: 15,
              ),),
            ),
            TextButton(
              onPressed: () {
                showGenerateCardDialogCode(context);
              },
              child: strokedText('Cartela com Código', TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontSize: 15,
              ),),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StrokeText(
          text: 'Bingo PRO: Caller, Sorting e Playing',
          textStyle: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 20,
          ),
          strokeWidth: 2,
          strokeColor: Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: strokedText(
                      'Reiniciar o Jogo',
                      TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    content: strokedText(
                      'Tem certeza de que deseja reiniciar o jogo?',
                      TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Fecha o diálogo
                        },
                        child: strokedText(
                          'Cancelar',
                          TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            // Incrementa a semente para gerar um novo código
                            gameSeed++;
                            // Atualiza o código do jogo
                            gameCode = generateGameCode(gameSeed);
                            // Limpe todas as variáveis do jogo para reiniciá-lo
                            numbersCalled.clear();
                            markedNumbers.clear();
                            last5Numbers.clear();
                            generateColumnNumbers();
                          });
                          Navigator.pop(context); // Fecha o diálogo
                        },
                        child: strokedText(
                          'Reiniciar',
                          TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              isAssistantEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isAssistantEnabled = !isAssistantEnabled;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            color: Colors.white,
            onPressed: () {
              showNumberOfNumbersDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(""), // Substitua pelo seu nome
              accountEmail: Text(""), // Substitua pelo seu e-mail
              currentAccountPicture: Align(
                alignment: Alignment.center, // Centraliza a imagem
                child: CircleAvatar(
                  radius: 1000, // Define o tamanho do círculo
                  backgroundImage: AssetImage("assets/icone.png"), // Caminho da imagem do ícone
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black, Colors.black], // Mesma cor para preencher o espaço
                ),
              ),
            ),
            ListTile(
              title: strokedText(
                'Trocar Fundo',
                TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                changeBackground(context);
              },
            ),
            ListTile(
              title: strokedText(
                'Gerar Cartela',
                TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                showGenerateCardDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(currentBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: strokedText(
                    'Código do Jogo: $gameCode',
                    TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Future.delayed(const Duration(seconds: 1), () {
                      int drawnNumber = drawNumber();
                      if (drawnNumber != -1) {
                        String columnLetter = '';
                        for (var entry in columnNumbers.entries) {
                          if (entry.value.contains(drawnNumber)) {
                            columnLetter = entry.key;
                            break;
                          }
                        }
                        speakNumber(columnLetter + ' , ', drawnNumber);
                        showPlatformDialog(
                          context: context,
                          builder: (_) => BasicDialogAlert(
                            title: Text('$columnLetter $drawnNumber'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/vitoria.gif', // Substitua com o caminho correto para o seu GIF
                                  width: 100, // Ajuste o tamanho conforme necessário
                                  height: 100,
                                ),
                                Text(
                                  'Pressione OK para continuar',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              BasicDialogAction(
                                title: Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    markedNumbers.add(drawnNumber);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                'Todos os números foram sorteados!',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              content: Text(
                                'O jogo acabou!',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 20,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });
                    // Reproduza o som de bingo
                    playBingoSound();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(20),
                    primary: Colors.redAccent,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: strokedText(
                    'Sortear Número',
                    TextStyle(fontFamily: 'Roboto'),
                  ),
                ),

                SizedBox(height: 20),
                strokedText(
                  'Números Sorteados:',
                  TextStyle(fontFamily: 'Roboto'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (var number in last5Numbers)
                      Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(),
                          color: Colors.redAccent,
                        ),
                        child: Center(
                          child: strokedText(
                            number.toString(),
                            TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    Container(
                      height: 50,
                      width: 10,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (var column in ['B', 'I', 'N', 'G', 'O'])
                      Column(
                        children: [
                          strokedText(
                            column,
                            TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          ...columnNumbers[column]!.map((number) {
                            bool isMarked = markedNumbers.contains(number);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (markedNumbers.contains(number)) {
                                    markedNumbers.remove(number);
                                    last5Numbers.remove(number);
                                  } else {
                                    markedNumbers.add(number);
                                    last5Numbers.add(number);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(),
                                    color: isMarked ? Colors.red : Colors.grey,
                                  ),
                                  child: Center(
                                    child: strokedText(
                                      number.toString(),
                                      TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isMarked
                                            ? Colors.white
                                            : Colors.white,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );

  }

}

