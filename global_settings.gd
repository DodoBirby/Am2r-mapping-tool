extends Node
enum COLORS {BLUE, CYAN, GREEN, PURPLE}
enum CORNER_TYPES {DIAG, ROUND}

var corner_tile_list = ["O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h"]

var corner_conversion = {
	0: "0",
	1: "4",
	2: "3",
	3: "7",
	4: "1",
	5: "8",
	6: "9",
	7: "D",
	8: "2",
	9: "A",
	10: "6",
	11: "C",
	12: "5",
	13: "E",
	14: "B",
	15: "F",
	16: "G",
	17: "H",
	18: "I",
	19: "J",
	20: "K",
	21: "L",
	22: "M",
	23: "N"
}
