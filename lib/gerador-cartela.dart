import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:com.meuapp.bingosorteadorpro/bingo-win.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:com.meuapp.bingosorteadorpro/ad_helper.dart';



bool fullCardEnabled = false;
bool verticalEnabled = false;
bool horizontalEnabled = false;
bool cornersEnabled = false;
bool transversalEnabled = false;
bool horizontalBingo = false;
bool verticalBingo = false;
bool cornersBingo = false;
bool transversalBingo = false;
bool fullCardBingo = false;
late List<List<String>> card;
List<List<bool>> markedNumbers = [];
Color selectedColor = Colors.blue[100]!;





class BingoCardPage extends StatefulWidget {
  final int numbersPerRound;

  BingoCardPage({required this.numbersPerRound});

  @override
  _BingoCardPageState createState() => _BingoCardPageState();

}





class _BingoCardPageState extends State<BingoCardPage> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StrokeText(
          text: 'Cartela de Bingo',
          textStyle: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 20,
          ),
          strokeWidth: 2,
          strokeColor: Colors.black,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Desabilitar todas as variáveis de controle antes de voltar à página inicial
            fullCardEnabled = false;
            verticalEnabled = false;
            horizontalEnabled = false;
            cornersEnabled = false;
            transversalEnabled = false;
            horizontalBingo = false;
            verticalBingo = false;
            cornersBingo = false;
            transversalBingo = false;
            fullCardBingo = false;

            // Voltar à página inicial
            Navigator.pop(context);
          },
        ),
        actions: [

        ],
      ),
      body: Column(
        children: [
          BingoCardOptions(),
          Expanded(
            child: Center(
              child: BingoCard(maxNumber: widget.numbersPerRound), // Acesse a propriedade do widget usando widget.numbersPerRound
            ),
          ),
        ],
      ),
    );
  }
}


class ColorPickerDialog extends StatefulWidget {
  final Function(Color) onColorSelected;

  ColorPickerDialog({required this.onColorSelected});

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color selectedColor = Colors.blue; // Cor inicial selecionada

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Selecione a Cor da Cartela"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Mostra a cor selecionada
            Container(
              width: 50,
              height: 50,
              color: selectedColor,
            ),
            SizedBox(height: 10),
            // Slider de seleção de cor
            Slider(
              value: selectedColor.red.toDouble(),
              min: 0,
              max: 255,
              onChanged: (value) {
                setState(() {
                  selectedColor = Color.fromARGB(
                    selectedColor.alpha,
                    value.toInt(),
                    selectedColor.green,
                    selectedColor.blue,
                  );
                });
              },
            ),
            Slider(
              value: selectedColor.green.toDouble(),
              min: 0,
              max: 255,
              onChanged: (value) {
                setState(() {
                  selectedColor = Color.fromARGB(
                    selectedColor.alpha,
                    selectedColor.red,
                    value.toInt(),
                    selectedColor.blue,
                  );
                });
              },
            ),
            Slider(
              value: selectedColor.blue.toDouble(),
              min: 0,
              max: 255,
              onChanged: (value) {
                setState(() {
                  selectedColor = Color.fromARGB(
                    selectedColor.alpha,
                    selectedColor.red,
                    selectedColor.green,
                    value.toInt(),
                  );
                });
              },
            ),
            // Botão para confirmar a seleção de cor
            ElevatedButton(
              onPressed: () {
                widget.onColorSelected(selectedColor); // Chama a função de retorno com a cor selecionada
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: Text("Selecionar"),
            ),
          ],
        ),
      ),
    );
  }
}


  class BingoCard extends StatefulWidget {
  final int rows = 5;
  final int columns = 5;
  final int maxNumber; // Número máximo do bingo
  final double minCellSize = 40.0; // Tamanho mínimo das células

  BingoCard({required this.maxNumber});

  @override
  _BingoCardState createState() => _BingoCardState();
}




Widget strokedText(String text, TextStyle textStyle) {
  return StrokeText(
    text: text,
    textStyle: textStyle,
    strokeWidth: 2, // Largura do contorno
    strokeColor: Colors.black, // Cor do contorno
  );
}

bool isFullCardBingo(List<List<bool>> card) {
  for (int row = 0; row < card.length; row++) {
    for (int col = 0; col < card[row].length; col++) {
      if (!card[row][col] && !(row == 2 && col == 2)) {
        return false;
      }
    }
  }
  return true;
}




bool isVerticalBingo(List<List<bool>> card) {
  for (int col = 0; col < card[0].length; col++) {
    bool isBingo = true;
    for (int row = 0; row < card.length; row++) {
      if (!card[row][col]) {
        isBingo = false;
        break;
      }
    }
    if (isBingo) {
      return true;
    }
  }
  // Verifique se a coluna do meio (N) também contém o "FREE"
  if (card[0][2] && card[1][2] && card[3][2] && card[4][2]) {
    return true;
  }
  return false;
}

bool isHorizontalBingo(List<List<bool>> card) {
  for (int row = 0; row < card.length; row++) {
    bool isBingo = true;
    for (int col = 0; col < card[row].length; col++) {
      if (!card[row][col]) {
        isBingo = false;
        break;
      }
    }
    if (isBingo) {
      return true;
    }
  }
  // Verifique se a linha do meio (N) também contém o "FREE"
  if (card[2][0] && card[2][1] && card[2][3] && card[2][4]) {
    return true;
  }
  return false;
}



bool isCornersBingo(List<List<bool>> card) {
  return card[0][0] && card[0][card[0].length - 1] && card[card.length - 1][0] && card[card.length - 1][card[0].length - 1];
}

bool isTransversalBingo(List<List<bool>> card) {
  bool isBingo = true;

  // Verifique a diagonal superior esquerda para a diagonal inferior direita
  for (int i = 0; i < card.length; i++) {
    if (!card[i][i] && !(i == 2 && i == 2)) {
      isBingo = false;
      break;
    }
  }

  // Se a diagonal superior esquerda para a diagonal inferior direita não for um bingo,
  // verifique a diagonal superior direita para a diagonal inferior esquerda
  if (!isBingo) {
    isBingo = true;
    for (int i = 0; i < card.length; i++) {
      if (!card[i][card.length - 1 - i] && !(i == 2 && card.length - 1 - i == 2)) {
        isBingo = false;
        break;
      }
    }
  }

  return isBingo;
}



class _BingoCardState extends State<BingoCard> {

  late Color cardColor; // Nova variável para armazenar a cor da cartela
  late List<List<String>> originalCard;

  @override
  void initState() {
    super.initState();

    // Crie e carregue o banner de anúncios

    card = generateRandomCard();
    cardColor = _getRandomCardColor();
    originalCard = List.generate(widget.rows, (row) {
      return List.generate(widget.columns, (col) {
        if (row == 2 && col == 2) {
          return 'FREE';
        } else {
          int min = col * (widget.maxNumber ~/ widget.columns) + 1;
          int max = (col + 1) * (widget.maxNumber ~/ widget.columns);
          return (Random().nextInt(max - min + 1) + min).toString();
        }
      });
    });

    markedNumbers = List.generate(widget.rows, (row) {
      return List.generate(widget.columns, (col) => false);
    });


  }






  // Lista de cores disponíveis
  final List<Color> cardColors = [
    Colors.blue[100]!,
    Colors.yellow[100]!,
    Colors.pink[100]!,
    Colors.green[100]!,
    Colors.red[100]!,
  ];

  Color _getRandomCardColor() {
    final random = Random();
    return cardColors[random.nextInt(cardColors.length)];
  }

  List<List<String>> generateRandomCard() {
    Set<String> usedNumbers = Set<String>(); // Para rastrear os números usados
    List<List<String>> newCard = List.generate(widget.rows, (row) {
      return List.generate(widget.columns, (col) {
        if (row == 2 && col == 2) {
          return 'FREE';
        } else {
          int min = col * (widget.maxNumber ~/ widget.columns) + 1;
          int max = (col + 1) * (widget.maxNumber ~/ widget.columns);
          String number;

          // Gerar um número aleatório único que não tenha sido usado
          do {
            number = (Random().nextInt(max - min + 1) + min).toString();
          } while (usedNumbers.contains(number));

          usedNumbers.add(number); // Adicionar o número usado ao conjunto

          return number;
        }
      });
    });
    return newCard;
  }




  void toggleNumber(int row, int col) {
    if (row != 2 || col != 2) {
      setState(() {
        markedNumbers[row][col] = !markedNumbers[row][col];

        if (!fullCardBingo && fullCardEnabled && isFullCardBingo(markedNumbers)) {
          // Bingo na Cartela Cheia
          // Exibir uma mensagem de Bingo ou executar ação desejada

          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BingoWinPage()));
          fullCardBingo = true;
        }

        if (!verticalBingo && verticalEnabled && isVerticalBingo(markedNumbers)) {
          // Bingo Vertical
          // Exibir uma mensagem de Bingo ou executar ação desejada
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BingoWinPage()));
          verticalBingo = true;

        }

        if (!horizontalBingo && horizontalEnabled && isHorizontalBingo(markedNumbers)) {
          // Bingo Horizontal
          // Exibir uma mensagem de Bingo ou executar ação desejada
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BingoWinPage()));
          horizontalBingo = true;
        }

        if (!cornersBingo && cornersEnabled && isCornersBingo(markedNumbers)) {
          // Bingo nos 4 Cantos
          // Exibir uma mensagem de Bingo ou executar ação desejada
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BingoWinPage()));
          cornersBingo = true;
        }

        if (!transversalBingo && transversalEnabled && isTransversalBingo(markedNumbers)) {
          // Bingo Transversal
          // Exibir uma mensagem de Bingo ou executar ação desejada
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BingoWinPage()));
          transversalBingo = true;
        }
      });
    }
  }


  Widget buildCell(int row, int col, double cellSize) {
    final isMarked = markedNumbers[row][col];
    final cellValue = card[row][col];

    final List<TextSpan> children = [];

    if (isMarked) {
      children.add(
        TextSpan(
          text: '$cellValue ',
          style: TextStyle(
            fontSize: cellSize / 3,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
      children.add(
        TextSpan(
          text: 'X',
          style: TextStyle(
            fontSize: cellSize / 3,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      );
    } else {
      children.add(
        TextSpan(
          text: '$cellValue',
          style: TextStyle(
            fontSize: cellSize / 3,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        toggleNumber(row, col);
      },
      child: Center(
        child: SizedBox(
          width: cellSize,
          height: cellSize,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: RichText(
              text: TextSpan(
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }









  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxCellWidth = screenSize.width / widget.columns;
    final maxCellHeight = screenSize.height / widget.rows;
    final cellSize = min(maxCellWidth, maxCellHeight) * 0.9;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Container(
                color: cardColor,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var letter in ['B', 'I', 'N', 'G', 'O'])
                          _buildBingoCell(letter, cellSize),
                      ],
                    ),
                    Table(
                      defaultColumnWidth: FixedColumnWidth(cellSize),
                      border: TableBorder.all(),
                      children: List.generate(widget.rows, (row) {
                        return TableRow(
                          children: List.generate(widget.columns, (col) {
                            return buildCell(row, col, cellSize);
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }





  Widget _buildBingoCell(String letter, double cellSize) {
    return Expanded(
      child: Center(
        child: StrokeText(
          text: letter,
          textStyle: TextStyle(
            fontSize: cellSize / 3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          strokeWidth: 2, // Largura do contorno
          strokeColor: Colors.black, // Cor do contorno
        ),
      ),
    );
  }
}

  class MarkedNumbersList extends StatefulWidget {
  @override
  _MarkedNumbersListState createState() => _MarkedNumbersListState();
}

class _MarkedNumbersListState extends State<MarkedNumbersList> {
  List<String> markedNumbers = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Números Marcados:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class BingoCardOptions extends StatefulWidget {
  @override
  _BingoCardOptionsState createState() => _BingoCardOptionsState();
}

class _BingoCardOptionsState extends State<BingoCardOptions> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
          children: [
            SizedBox(height: 8),
            ExpansionTile(
              title: StrokeText(
                text: 'Opções de Marcação', // Título do ExpansionTile
                textStyle: TextStyle(
                  color: Colors.white,
                ),
                strokeWidth: 2,
                strokeColor: Colors.black,
              ),
              children: [
                SwitchListTile(
                  title: StrokeText(
                    text: 'Cartela Cheia',
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    strokeWidth: 2,
                    strokeColor: Colors.black,
                  ),
                  value: fullCardEnabled,
                  onChanged: (value) {
                    setState(() {
                      fullCardEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: StrokeText(
                    text: 'Vertical',
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    strokeWidth: 2,
                    strokeColor: Colors.black,
                  ),
                  value: verticalEnabled,
                  onChanged: (value) {
                    setState(() {
                      verticalEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: StrokeText(
                    text: 'Horizontal',
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    strokeWidth: 2,
                    strokeColor: Colors.black,
                  ),
                  value: horizontalEnabled,
                  onChanged: (value) {
                    setState(() {
                      horizontalEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: StrokeText(
                    text: '4 Cantos',
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    strokeWidth: 2,
                    strokeColor: Colors.black,
                  ),
                  value: cornersEnabled,
                  onChanged: (value) {
                    setState(() {
                      cornersEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: StrokeText(
                    text: 'Transversal',
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    strokeWidth: 2,
                    strokeColor: Colors.black,
                  ),
                  value: transversalEnabled,
                  onChanged: (value) {
                    setState(() {
                      transversalEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ]

      ),
    );
  }
}

