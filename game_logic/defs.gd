extends Object

class_name Defs

enum Direction {
	UP
	DOWN
	RIGHT
	LEFT
}

# used to convert int to vec2 via the Direction enum
const direction_vectors: Array = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
const direction_opposites: Array = [Direction.DOWN, Direction.UP, Direction.LEFT, Direction.RIGHT]

const WAVE_MAX_SIZE: int = 10
