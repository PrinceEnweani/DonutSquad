class Level {
  final int levelNumber;
  final int gridSize;
  final int movesAllowed;
  final int targetScore;
  final Map<int, int> targetTiles; // Tile type -> number of tiles to clear

  Level({
    required this.levelNumber,
    required this.gridSize,
    required this.movesAllowed,
    required this.targetScore,
    required this.targetTiles,
  });
}

final List<Level> levels = [
  Level(
    levelNumber: 1,
    gridSize: 6,
    movesAllowed: 20,
    targetScore: 1000,
    targetTiles: {1: 10, 2: 10}, // Clear 10 red and 10 blue tiles
  ),
  Level(
    levelNumber: 2,
    gridSize: 7,
    movesAllowed: 15,
    targetScore: 2000,
    targetTiles: {3: 15, 4: 15}, // Clear 15 green and 15 yellow tiles
  ),
  Level(
    levelNumber: 3,
    gridSize: 8,
    movesAllowed: 10,
    targetScore: 3000,
    targetTiles: {5: 20}, // Clear 20 purple tiles
  ),
];