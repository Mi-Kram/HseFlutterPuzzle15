package puzzle

import (
	"container/heap"
	"errors"
	"fmt"
	"math"
	"slices"
	"strconv"
	"strings"
)

type State struct {
	board []int
	zero  int
	g     int       // пройденная стоимость
	h     int       // эвристика
	f     int       // g + h
	prev  *State    // предыдущее состояние
	move  Direction // ход, приведший сюда
	index int       // индекс в куче
}

func IsSolvedBoard(values []int) bool {
	for i := 0; i < len(values)-1; i++ {
		if values[i] != i+1 {
			return false
		}
	}
	return values[len(values)-1] == 0
}

func IsSolvableBoard(values []int) bool {
	size := int(math.Sqrt(float64(len(values))))
	if len(values) != size*size {
		return false
	}

	var inversions int
	for i := range values {
		if values[i] == 0 {
			continue
		}
		for j := i + 1; j < len(values); j++ {
			if values[j] != 0 && values[j] < values[i] {
				inversions++
			}
		}
	}

	if size%2 == 1 {
		return inversions%2 == 0
	}

	zeroIndex := slices.Index(values, 0)
	rowFromBottom := size - zeroIndex/size

	if rowFromBottom%2 == 0 {
		return inversions%2 == 1
	}
	return inversions%2 == 0
}

func PrintBoard(board []int) {
	n := int(math.Sqrt(float64(len(board))))
	mxLen := len(strconv.Itoa(len(board) - 1))
	format := fmt.Sprintf("%%%dd ", mxLen)

	for i := range n {
		for j := range n {
			fmt.Printf(format, board[i*n+j])
		}
		fmt.Println()
	}
}

func IsValidBoard(arr []int) error {
	n := int(math.Sqrt(float64(len(arr))))
	if len(arr) != n*n {
		return errors.New("некорректный размер поля")
	}
	if len(arr) == 0 {
		return errors.New("пустое поле")
	}

	set := make([]bool, len(arr))
	for _, num := range arr {
		if num < 0 || len(arr) <= num || set[num] {
			return errors.New("некорректное значение поля")
		}
		set[num] = true
	}

	if !IsSolvableBoard(arr) {
		return errors.New("эта конфигурация не решается")
	}

	return nil
}

type OptimalSolver struct {
}

func SolveOptimal(start []int) ([]Direction, error) {
	n := int(math.Sqrt(float64(len(start))))
	if len(start) != n*n {
		return nil, errors.New("некорректный размер поля")
	}
	if err := IsValidBoard(start); err != nil {
		return nil, err
	}
	if IsSolvedBoard(start) {
		return nil, nil
	}

	var solver OptimalSolver

	goal := solver.encode(solver.goalBoard(n))
	startState := &State{
		board: solver.copyBoard(start),
		zero:  slices.Index(start, 0),
	}
	startState.h = solver.manhattan(startState.board, n)
	startState.f = startState.h

	open := &PriorityQueue{}
	heap.Init(open)
	heap.Push(open, startState)

	gScore := map[string]int{
		solver.encode(startState.board): 0,
	}

	closed := make(map[string]bool)

	for open.Len() > 0 {
		cur := heap.Pop(open).(*State)
		key := solver.encode(cur.board)

		if key == goal {
			return solver.reconstructPath(cur), nil
		}
		if closed[key] {
			continue
		}
		closed[key] = true

		for _, nb := range solver.neighbors(cur, n) {
			nbKey := solver.encode(nb.board)
			if closed[nbKey] {
				continue
			}
			if oldG, ok := gScore[nbKey]; !ok || nb.g < oldG {
				gScore[nbKey] = nb.g
				heap.Push(open, nb)
			}
		}
	}

	return nil, errors.New("решение не найдено")
}

func (OptimalSolver) encode(board []int) string {
	var sb strings.Builder
	for _, v := range board {
		sb.WriteString(fmt.Sprintf("%d,", v))
	}
	return sb.String()
}

func (OptimalSolver) goalBoard(n int) []int {
	g := make([]int, n*n)
	for i := 1; i < n*n; i++ {
		g[i-1] = i
	}
	return g
}

func (OptimalSolver) manhattan(board []int, n int) int {
	dist := 0
	for i, v := range board {
		if v == 0 {
			continue
		}
		target := v - 1
		r1, c1 := i/n, i%n
		r2, c2 := target/n, target%n
		dist += abs(r1-r2) + abs(c1-c2)
	}
	return dist
}

func (OptimalSolver) copyBoard(board []int) []int {
	cp := make([]int, len(board))
	copy(cp, board)
	return cp
}

func (solver OptimalSolver) neighbors(s *State, n int) []*State {
	var result []*State
	r, c := s.zero/n, s.zero%n

	dirs := []struct {
		dr, dc int
		name   Direction
	}{
		{1, 0, DirectionUp},
		{-1, 0, DirectionDown},
		{0, 1, DirectionLeft},
		{0, -1, DirectionRight},
	}

	for _, d := range dirs {
		nr, nc := r+d.dr, c+d.dc
		if nr < 0 || nr >= n || nc < 0 || nc >= n {
			continue
		}
		nz := nr*n + nc
		nb := solver.copyBoard(s.board)
		nb[s.zero], nb[nz] = nb[nz], nb[s.zero]

		ns := &State{
			board: nb,
			zero:  nz,
			g:     s.g + 1,
			prev:  s,
			move:  d.name,
		}
		ns.h = solver.manhattan(ns.board, n)
		ns.f = ns.g + ns.h
		result = append(result, ns)
	}

	return result
}

func (OptimalSolver) reconstructPath(end *State) []Direction {
	var path []Direction
	for cur := end; cur != nil && cur.prev != nil; cur = cur.prev {
		path = append(path, cur.move)
	}
	// reverse
	for i, j := 0, len(path)-1; i < j; i, j = i+1, j-1 {
		path[i], path[j] = path[j], path[i]
	}
	return path
}
