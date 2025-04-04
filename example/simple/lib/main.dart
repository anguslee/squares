import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:squares/squares.dart';
import 'package:square_bishop/square_bishop.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squares Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bishop.Game game;
  late SquaresState state;
  int player = Squares.white;
  bool aiThinking = false;
  bool flipBoard = false;

  @override
  void initState() {
    _resetGame(false);
    super.initState();
  }

  void _resetGame([bool ss = true]) {
    game = bishop.Game(variant: bishop.Xiangqi.variant());
    state = game.squaresState(player);
    if (ss) setState(() {});
  }

  void _flipBoard() => setState(() => flipBoard = !flipBoard);

  void _onMove(Move move) async {
    bool result = game.makeSquaresMove(move);
    if (result) {
      setState(() => state = game.squaresState(player));
    }
    if (state.state == PlayState.theirTurn && !aiThinking) {
      setState(() => aiThinking = true);
      await Future.delayed(
          Duration(milliseconds: Random().nextInt(4750) + 250));
      game.makeRandomMove();
      setState(() {
        aiThinking = false;
        state = game.squaresState(player);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Squares Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: BoardController(
                    state: flipBoard ? state.board.flipped() : state.board,
                    playState: state.state,
                    pieceSet: PieceSet.xiangqi(),
                    size: state.size,
                    background: Squares.xiangqiBackground,
                    backgroundConfig: BackgroundConfig.xiangqi,
                    labelConfig: LabelConfig.disabled,
                    theme: BoardTheme.brown,
                    moves: state.moves,
                    onMove: _onMove,
                    onPremove: _onMove,
                    piecePadding: 0.075,
                    dragFeedbackSize: 1.5,
                    markerTheme: MarkerTheme(
                      empty: MarkerTheme.dot,
                      piece: MarkerTheme.corners(),
                    ),
                    dragTargetFeedback: ColourDragTargetFeedback.fromTheme(
                        theme: BoardTheme.brown,
                        shape: BoxShape.circle
                    ),
                    promotionBehaviour: PromotionBehaviour.autoPremove,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: _resetGame,
                child: const Text('New Game'),
              ),
              IconButton(
                onPressed: _flipBoard,
                icon: const Icon(Icons.rotate_left),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
