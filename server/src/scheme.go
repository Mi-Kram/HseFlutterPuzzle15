package main

import (
	"puzzle15/puzzle"
	"time"
)

type dateKey [3]int

var minYear, minMonth, minDay int

func init() {
	minYear = time.Now().Year() - 7
	minMonth = 2
	minDay = 5
}

type MinPuzzleResponse struct {
	Year  int `json:"year"`
	Month int `json:"month"`
	Day   int `json:"day"`
}

type PuzzleResponse struct {
	Puzzle puzzle.PuzzleGrid `json:"puzzle"`
}

type SolvePuzzleRequest struct {
	Puzzle puzzle.PuzzleGrid `json:"puzzle"`
}

type SolvePuzzleResponse struct {
	Moves []puzzle.Direction `json:"moves"`
}

type ErrorResponse struct {
	Message string `json:"message"`
}
