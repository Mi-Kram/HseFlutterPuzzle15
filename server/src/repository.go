package main

import "puzzle15/puzzle"

var storage = map[dateKey]puzzle.PuzzleGrid{}

func getPuzzleByDate(year, month, day int) puzzle.PuzzleGrid {
	key := [3]int{year, month, day}
	puzzle, exists := storage[key]
	if !exists {
		return nil
	}
	return puzzle.Copy()
}

func setPuzzleByDate(year, month, day int, puzzle puzzle.PuzzleGrid) {
	key := [3]int{year, month, day}
	storage[key] = puzzle.Copy()
}
