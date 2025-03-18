import 'package:flutter/material.dart';

import 'models/tilewidget.dart';

void main() {
  runApp(Match3Game());
}

class Match3Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match 3 Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends  State<GameScreen> with SingleTickerProviderStateMixin {
  static const int gridSize = 8;
  List<List<int>> grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
  int? selectedRow;
  int? selectedCol;
  int? currentLevel = 0;
  int? score = 0;
  int movesLeft = 30;
  int clearedTiles = 0;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  int? _swapFromRow, _swapFromCol, _swapToRow, _swapToCol;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _initializeGrid();
  }

  void _initializeGrid() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        grid[i][j] = _getRandomTile();
      }
    }
    _checkMatches();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  int _getRandomTile() {
    return 1 + (DateTime.now().millisecond % 5); // Random number between 1 and 5
  }

  void _onTileTap(int row, int col) {
    if (selectedRow == null && selectedCol == null) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    } else {
      if ((selectedRow == row && (selectedCol == col - 1 || selectedCol == col + 1)) ||
          (selectedCol == col && (selectedRow == row - 1 || selectedRow == row + 1))) {
        _swapTiles(row, col, selectedRow!, selectedCol!);
        _checkMatches();
      }
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });
    }
  }

  void _swapTiles(int row1, int col1, int row2, int col2) {
    int temp = grid[row1][col1];
    grid[row1][col1] = grid[row2][col2];
    grid[row2][col2] = temp;
  }

  bool _checkMatches() {
    bool matchFound = false;

    // Check horizontal matches
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 2; j++) {
        if (grid[i][j] != 0 && grid[i][j] == grid[i][j + 1] && grid[i][j] == grid[i][j + 2]) {
          matchFound = true;
          grid[i][j] = grid[i][j + 1] = grid[i][j + 2] = 0;
        }
      }
    }

    // Check vertical matches
    for (int j = 0; j < gridSize; j++) {
      for (int i = 0; i < gridSize - 2; i++) {
        if (grid[i][j] != 0 && grid[i][j] == grid[i + 1][j] && grid[i][j] == grid[i + 2][j]) {
          matchFound = true;
          grid[i][j] = grid[i + 1][j] = grid[i + 2][j] = 0;
        }
      }
    }

    if (matchFound) {
      _fillEmptyTiles();
      _checkMatches(); // Recursively check for new matches
    }
    return matchFound;
  }

  void _fillEmptyTiles() {
    for (int j = 0; j < gridSize; j++) {
      for (int i = gridSize - 1; i >= 0; i--) {
        if (grid[i][j] == 0) {
          for (int k = i - 1; k >= 0; k--) {
            if (grid[k][j] != 0) {
              grid[i][j] = grid[k][j];
              grid[k][j] = 0;
              break;
            }
          }
          if (grid[i][j] == 0) {
            grid[i][j] = _getRandomTile();
          }
        }
      }
    }
  }

  void _onSwap(int fromRow, int fromCol, int toRow, int toCol) {
    if (toRow >= 0 &&
        toRow < grid.length &&
        toCol >= 0 &&
        toCol < grid[0].length) {
      setState(() {
        _swapFromRow = fromRow;
        _swapFromCol = fromCol;
        _swapToRow = toRow;
        _swapToCol = toCol;
      });

      // Swap tiles temporarily
      _swapTiles(fromRow, fromCol, toRow, toCol);

      // Check for matches
      if (!_checkMatches()) {
        // No matches found, animate back
        _animateSwapBack();
      } else {
        // Matches found, proceed with the game
        setState(() {
          movesLeft--;
        });
      }
    }
  }

  void _animateSwapBack() {
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(
        (_swapToCol! - _swapFromCol!).toDouble(),
        (_swapToRow! - _swapFromRow!).toDouble(),
      ),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward().then((_) {
      // Swap back after animation completes
      _swapTiles(_swapToRow!, _swapToCol!, _swapFromRow!, _swapFromCol!);
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match 3 Game - Level ${currentLevel! + 1}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Moves Left: $movesLeft'),
                Text('Score: $score'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid.length,
                childAspectRatio: 1.0,
              ),
              itemCount: grid.length * grid.length,
              itemBuilder: (context, index) {
                int row = index ~/ grid.length;
                int col = index % grid.length;
                return TileWidget(
                  row: row,
                  col: col,
                  tile: grid[row][col],
                  isSelected: selectedRow == row && selectedCol == col,
                  onTap: _onTileTap,
                  onSwap: _onSwap,
                  animation: (row == _swapFromRow && col == _swapFromCol) ||
                      (row == _swapToRow && col == _swapToCol)
                      ? _animation
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Objectives: ${clearedTiles.toString()}'),
          ),
        ],
      ),
    );
  }


  Color _getTileColor(int tile) {
    switch (tile) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.yellow;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}