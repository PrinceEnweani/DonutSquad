import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int row;
  final int col;
  final int tile;
  final bool isSelected;
  final Function(int, int) onTap;
  final Function(int, int, int, int) onSwap;
  final Animation<Offset>? animation;

  const TileWidget({
    required this.row,
    required this.col,
    required this.tile,
    required this.isSelected,
    required this.onTap,
    required this.onSwap,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget tileContent = Container(
      margin: EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: _getTileColor(tile),
        border: Border.all(
          color: isSelected ? Colors.red : Colors.black,
          width: 2.0,
        ),
      ),
    );

    if (animation != null) {
      return SlideTransition(
        position: animation!,
        child: GestureDetector(
          onTap: () => onTap(row, col),
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swipe right
              onSwap(row, col, row, col + 1);
            } else if (details.primaryVelocity! < 0) {
              // Swipe left
              onSwap(row, col, row, col - 1);
            }
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swipe down
              onSwap(row, col, row + 1, col);
            } else if (details.primaryVelocity! < 0) {
              // Swipe up
              onSwap(row, col, row - 1, col);
            }
          },
          child: tileContent,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => onTap(row, col),
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe right
            onSwap(row, col, row, col + 1);
          } else if (details.primaryVelocity! < 0) {
            // Swipe left
            onSwap(row, col, row, col - 1);
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe down
            onSwap(row, col, row + 1, col);
          } else if (details.primaryVelocity! < 0) {
            // Swipe up
            onSwap(row, col, row - 1, col);
          }
        },
        child: tileContent,
      );
    }
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