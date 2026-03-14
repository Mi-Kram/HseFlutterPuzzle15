package main

import (
	"math/rand"
	"puzzle15/puzzle"
	"time"
)

func getDaylyPuzzle(year, month, day int) (puzzle.PuzzleGrid, error) {
	if err := IsValidDate(year, month, day); err != nil {
		return nil, err
	}

	puzzle := getPuzzleByDate(year, month, day)
	if puzzle != nil {
		return puzzle, nil
	}

	puzzle = generateDaylyField()
	setPuzzleByDate(year, month, day, puzzle)
	return puzzle, nil
}

var probs = [][2]int{
	// size, sum of probabililies
	{3, 10},  // 10%
	{4, 40},  // 30%
	{5, 65},  // 25%
	{6, 80},  // 15%
	{7, 90},  // 10%
	{8, 95},  // 5%
	{9, 100}, // 5%
}

func generateDaylyField() puzzle.PuzzleGrid {
	r, size := int(rand.Float32()*float32(probs[len(probs)-1][1])), 4
	for _, p := range probs {
		if r < p[1] {
			size = p[0]
			break
		}
	}
	return generateField(size)
}

func generateField(size int) puzzle.PuzzleGrid {
	values := make([]int, size*size)
	for i := range len(values) {
		values[i] = i
	}

	r := rand.New(rand.NewSource(time.Now().UnixNano()))

	for {
		r.Shuffle(len(values), func(i, j int) {
			values[i], values[j] = values[j], values[i]
		})

		if puzzle.IsSolvableBoard(values) && !puzzle.IsSolvedBoard(values) {
			break
		}
	}

	result := make(puzzle.PuzzleGrid, size)
	for r := range size {
		row := make(puzzle.PuzzleRow, size)
		for c := range size {
			row[c] = values[r*size+c]
		}
		result[r] = row
	}

	return result
}
