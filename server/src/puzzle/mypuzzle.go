package puzzle

import (
	"errors"
	"fmt"
	"math/rand"
	"slices"
	"strconv"
	"time"
)

type PuzzleSolver struct {
	size       int
	puzzle     PuzzleGrid
	puzzleLock [][]bool
	moves      []Point
	zeroPoint  Point
	rnd        *rand.Rand
}

func SolvePuzzle(puzzle PuzzleGrid) ([]Direction, error) {
	if err := IsValidPuzzle(puzzle); err != nil {
		return nil, err
	}
	if IsSolvedPuzzle(puzzle) {
		return nil, nil
	}

	p := &PuzzleSolver{
		puzzle:     puzzle.Copy(),
		puzzleLock: make([][]bool, len(puzzle)),
		size:       len(puzzle),
		moves:      make([]Point, 0),
		rnd:        rand.New(rand.NewSource(time.Now().UnixNano())),
	}

	for i := range len(puzzle) {
		p.puzzleLock[i] = make([]bool, len(puzzle[i]))
	}

	var zr, zc int
zeroLoop:
	for r, row := range puzzle {
		for c, num := range row {
			if num == 0 {
				p.zeroPoint, zr, zc = Point{r, c}, r, c
				break zeroLoop
			}
		}
	}

	if err := p.solve(); err != nil {
		return nil, err
	}

	res := make([]Direction, 0, len(p.moves))
	for _, m := range p.moves {
		if m.Row == zr {
			if m.Col < zc {
				res = append(res, DirectionRight)
				zc--
			} else {
				res = append(res, DirectionLeft)
				zc++
			}
		} else {
			if m.Row < zr {
				res = append(res, DirectionDown)
				zr--
			} else {
				res = append(res, DirectionUp)
				zr++
			}
		}
	}

	return res, nil
}

func IsSolvedPuzzle(puzzle PuzzleGrid) bool {
	n := len(puzzle) * len(puzzle)
	for i := 0; i < n-1; i++ {
		if puzzle[i/len(puzzle)][i%len(puzzle)] != i+1 {
			return false
		}
	}
	return puzzle[len(puzzle)-1][len(puzzle)-1] == 0
}

func IsSolvablePuzzle(puzzle PuzzleGrid) bool {
	inversions, n, size := 0, len(puzzle), len(puzzle)*len(puzzle)
	for i := range size {
		if puzzle[i/n][i%n] == 0 {
			continue
		}
		for j := i + 1; j < size; j++ {
			if puzzle[j/n][j%n] != 0 && puzzle[j/n][j%n] < puzzle[i/n][i%n] {
				inversions++
			}
		}
	}

	if n%2 == 1 {
		return inversions%2 == 0
	}

	var rowFromBottom int
	for i, row := range puzzle {
		if slices.Index(row, 0) != -1 {
			rowFromBottom = n - i
			break
		}
	}

	if rowFromBottom%2 == 0 {
		return inversions%2 == 1
	}
	return inversions%2 == 0
}

func PrintPuzzle(puzzle PuzzleGrid) {
	mxLen := len(strconv.Itoa(len(puzzle)*len(puzzle) - 1))
	format := fmt.Sprintf("%%%dd ", mxLen)

	for _, row := range puzzle {
		for _, num := range row {
			fmt.Printf(format, num)
		}
		fmt.Println()
	}
}

func IsValidPuzzle(puzzle PuzzleGrid) error {
	if len(puzzle) == 0 {
		return errors.New("пустое поле")
	}

	width := len(puzzle[0])
	if len(puzzle) != width {
		return errors.New("неверный размер поля")
	}
	for _, row := range puzzle {
		if len(row) != width {
			return errors.New("неверный размер поля")
		}
	}

	size := len(puzzle) * len(puzzle)
	set := make([]bool, size)
	for _, row := range puzzle {
		for _, num := range row {
			if num < 0 || size <= num || set[num] {
				return errors.New("некорректное значение поля")
			}
			set[num] = true
		}
	}

	if !IsSolvablePuzzle(puzzle) {
		return errors.New("эта конфигурация не решается")
	}

	return nil
}

func (p *PuzzleSolver) solve() error {
	startEmptyPosition := p.zeroPoint

	for row := 0; row < p.size-2; row++ {
		if err := p.simpleWay(row*p.size + row + 1); err != nil {
			return err
		}
		p.lock(row, row)

		for col := row + 1; col < p.size-2; col++ {
			if err := p.simpleWay(row*p.size + col + 1); err != nil {
				return err
			}
			p.lock(row, col)
		}

		if err := p.setRight(row); err != nil {
			return err
		}
		p.lock(row, p.size-2)
		p.lock(row, p.size-1)

		for col := row + 1; col < p.size-2; col++ {
			if err := p.simpleWay(col*p.size + row + 1); err != nil {
				return err
			}
			p.lock(col, row)
		}

		if err := p.setBottom(row); err != nil {
			return err
		}
		p.lock(p.size-1, row)
		p.lock(p.size-2, row)
	}

	if err := p.setLastThree(); err != nil {
		return err
	}
	p.removeRepeatMoves(startEmptyPosition)
	return nil
}

func (p *PuzzleSolver) setPoint(point Point, value int) {
	p.puzzle[point.Row][point.Col] = value
}

func (p *PuzzleSolver) getPoint(point Point) int {
	return p.puzzle[point.Row][point.Col]
}

func (p *PuzzleSolver) lockPoint(point Point) {
	p.puzzleLock[point.Row][point.Col] = true
}

func (p *PuzzleSolver) lock(row, col int) {
	p.puzzleLock[row][col] = true
}

func (p *PuzzleSolver) unlockPoint(point Point) {
	p.puzzleLock[point.Row][point.Col] = false
}

func (p *PuzzleSolver) unlock(row, col int) {
	p.puzzleLock[row][col] = false
}

func (p *PuzzleSolver) getIndexPoint(index int) Point {
	row := index / p.size
	col := index % p.size
	return Point{Row: row, Col: col}
}

func (p *PuzzleSolver) getNumPoint(num int) *Point {
	for i := 0; i < p.size; i++ {
		for j := 0; j < p.size; j++ {
			if p.puzzle[i][j] == num {
				pt := Point{Row: i, Col: j}
				return &pt
			}
		}
	}
	return nil
}

func (p *PuzzleSolver) removeRepeatMoves(empty Point) {
	var prev *Point
	var prev2 *Point

	for i := 0; i < len(p.moves); i++ {
		if i == 0 {
			tmp2 := empty
			tmp := p.moves[0]
			prev2 = &tmp2
			prev = &tmp
			continue
		}

		if prev2 != nil && prev2.Equals(p.moves[i]) {
			p.moves = append(p.moves[:i], p.moves[i+1:]...)
			i--
			p.moves = append(p.moves[:i], p.moves[i+1:]...)
			i--

			if i <= 0 {
				i = -1
				prev = nil
				prev2 = nil
			} else {
				tmp := *prev2
				prev = &tmp
				tmp2 := p.moves[i-1]
				prev2 = &tmp2
			}
			continue
		}

		tmp2 := *prev
		tmp := p.moves[i]
		prev2 = &tmp2
		prev = &tmp
	}
}

func (p *PuzzleSolver) movePath(points []Point) {
	if len(points) == 0 {
		return
	}

	for _, point := range points {
		p.moves = append(p.moves, point)
		p.setPoint(p.zeroPoint, p.getPoint(point))
		p.zeroPoint = point
	}
	p.setPoint(p.zeroPoint, 0)
}

func (p *PuzzleSolver) move(point Point) {
	p.moves = append(p.moves, point)
	p.setPoint(p.zeroPoint, p.getPoint(point))
	p.zeroPoint = point
	p.setPoint(p.zeroPoint, 0)
}

func (p *PuzzleSolver) getWay(fromPoint, destPoint Point) []Point {
	if fromPoint.Equals(destPoint) {
		return []Point{}
	}

	matrix := make([][]int, p.size)
	for i := 0; i < p.size; i++ {
		matrix[i] = make([]int, p.size)
		for j, lock := range p.puzzleLock[i] {
			if lock {
				matrix[i][j] = -1
			}
		}
	}

	curValue := 1
	matrix[destPoint.Row][destPoint.Col] = curValue

	curPos := []Point{destPoint}
	nextPos := make([]Point, 0)

	for len(curPos) > 0 {
		curValue++

		for _, point := range curPos {
			if point.Row > 0 && matrix[point.Row-1][point.Col] == 0 {
				nextPos = append(nextPos, point.NewRelative(-1, 0))
				matrix[point.Row-1][point.Col] = curValue
			}
			if point.Row+1 < p.size && matrix[point.Row+1][point.Col] == 0 {
				nextPos = append(nextPos, point.NewRelative(1, 0))
				matrix[point.Row+1][point.Col] = curValue
			}
			if point.Col > 0 && matrix[point.Row][point.Col-1] == 0 {
				nextPos = append(nextPos, point.NewRelative(0, -1))
				matrix[point.Row][point.Col-1] = curValue
			}
			if point.Col+1 < p.size && matrix[point.Row][point.Col+1] == 0 {
				nextPos = append(nextPos, point.NewRelative(0, 1))
				matrix[point.Row][point.Col+1] = curValue
			}
		}

		for _, point := range nextPos {
			if point.Equals(fromPoint) {
				result := make([]Point, 0)
				value := curValue
				cur := point

				for value > 1 {
					if cur.Row > 0 && matrix[cur.Row-1][cur.Col] == value-1 {
						cur.Row--
						value = matrix[cur.Row][cur.Col]
					} else if cur.Row+1 < p.size && matrix[cur.Row+1][cur.Col] == value-1 {
						cur.Row++
						value = matrix[cur.Row][cur.Col]
					} else if cur.Col > 0 && matrix[cur.Row][cur.Col-1] == value-1 {
						cur.Col--
						value = matrix[cur.Row][cur.Col]
					} else if cur.Col+1 < p.size && matrix[cur.Row][cur.Col+1] == value-1 {
						cur.Col++
						value = matrix[cur.Row][cur.Col]
					} else {
						value = 0
					}

					result = append(result, cur)
				}

				return result
			}
		}

		curPos = nextPos
		nextPos = make([]Point, 0)
	}

	return nil
}

func (p *PuzzleSolver) moveItem(num int, finalPoint Point) error {
	numPoint := p.getNumPoint(num)
	if numPoint == nil {
		return errors.New("number not found")
	}
	if numPoint.Equals(finalPoint) {
		return nil
	}

	numWay := p.getWay(*numPoint, finalPoint)
	if numWay == nil {
		return errors.New("эта конфигурация не решается")
	}

	currentNumPoint := *numPoint

	for _, nPoint := range numWay {
		if !p.zeroPoint.Equals(nPoint) {
			p.lockPoint(currentNumPoint)
			zeroWay := p.getWay(p.zeroPoint, nPoint)
			p.unlockPoint(currentNumPoint)

			if zeroWay == nil {
				return errors.New("эта конфигурация не решается")
			}
			p.movePath(zeroWay)
		}

		p.move(currentNumPoint)
		currentNumPoint = nPoint
	}

	p.setPoint(p.zeroPoint, 0)
	return nil
}

func (p *PuzzleSolver) simpleWay(num int) error {
	finalPoint := p.getIndexPoint(num - 1)
	return p.moveItem(num, finalPoint)
}

func (p *PuzzleSolver) setRight(rowIndex int) error {
	if err := p.rightFirst(p.size*rowIndex + p.size - 1); err != nil {
		return err
	}
	return p.rightSecond(p.size*rowIndex + p.size)
}

func (p *PuzzleSolver) rightFirst(num int) error {
	finalPoint := p.getIndexPoint(num)
	return p.moveItem(num, finalPoint)
}

func (p *PuzzleSolver) rightSecond(num int) error {
	finalPoint := p.getIndexPoint(num - 1)

	numPoint := p.getNumPoint(num)
	if numPoint == nil {
		return errors.New("number not found")
	}

	fail := numPoint.EqualsRC(finalPoint.Row, finalPoint.Col-1)
	if fail {
		p.lockPoint(finalPoint)
		if err := p.moveItem(num, finalPoint.NewRelative(1, -1)); err != nil {
			return err
		}
		p.unlockPoint(finalPoint)
		numPoint = p.getNumPoint(num)
		if numPoint == nil {
			return errors.New("number not found")
		}
	}

	fail = numPoint.EqualsRC(finalPoint.Row+1, finalPoint.Col-1) &&
		p.zeroPoint.EqualsRC(finalPoint.Row, finalPoint.Col-1)

	if fail {
		p.move(finalPoint.NewRelative(0, 0))
		p.move(finalPoint.NewRelative(1, 0))
		p.move(finalPoint.NewRelative(1, -1))
		p.move(finalPoint.NewRelative(2, -1))
		p.move(finalPoint.NewRelative(2, 0))
		p.move(finalPoint.NewRelative(1, 0))
		p.move(finalPoint.NewRelative(0, 0))
		p.move(finalPoint.NewRelative(0, -1))
	}

	p.lockPoint(finalPoint)
	if err := p.moveItem(num, finalPoint.NewRelative(1, 0)); err != nil {
		return err
	}
	p.unlockPoint(finalPoint)

	p.lock(finalPoint.Row+1, finalPoint.Col)
	if err := p.moveItem(num-1, finalPoint.NewRelative(0, -1)); err != nil {
		return err
	}
	p.unlock(finalPoint.Row+1, finalPoint.Col)

	if err := p.moveItem(num, finalPoint); err != nil {
		return err
	}

	p.setPoint(p.zeroPoint, 0)
	return nil
}

func (p *PuzzleSolver) setBottom(colIndex int) error {
	if err := p.bottomFirst(p.size*(p.size-2) + colIndex + 1); err != nil {
		return err
	}
	return p.bottomSecond(p.size*(p.size-1) + colIndex + 1)
}

func (p *PuzzleSolver) bottomFirst(num int) error {
	finalPoint := p.getIndexPoint(num + p.size - 1)
	return p.moveItem(num, finalPoint)
}

func (p *PuzzleSolver) bottomSecond(num int) error {
	finalPoint := p.getIndexPoint(num - 1)

	numPoint := p.getNumPoint(num)
	if numPoint == nil {
		return errors.New("number not found")
	}

	fail := numPoint.EqualsRC(finalPoint.Row-1, finalPoint.Col)
	if fail {
		p.lockPoint(finalPoint)
		if err := p.moveItem(num, finalPoint.NewRelative(-1, 1)); err != nil {
			return err
		}
		p.unlockPoint(finalPoint)
		numPoint = p.getNumPoint(num)
		if numPoint == nil {
			return errors.New("number not found")
		}
	}

	fail = numPoint.EqualsRC(finalPoint.Row-1, finalPoint.Col+1) &&
		p.zeroPoint.EqualsRC(finalPoint.Row-1, finalPoint.Col)

	if fail {
		p.move(finalPoint.NewRelative(0, 0))
		p.move(finalPoint.NewRelative(0, 1))
		p.move(finalPoint.NewRelative(-1, 1))
		p.move(finalPoint.NewRelative(-1, 2))
		p.move(finalPoint.NewRelative(0, 2))
		p.move(finalPoint.NewRelative(0, 1))
		p.move(finalPoint.NewRelative(0, 0))
		p.move(finalPoint.NewRelative(-1, 0))
	}

	p.lockPoint(finalPoint)
	if err := p.moveItem(num, finalPoint.NewRelative(0, 1)); err != nil {
		return err
	}
	p.unlockPoint(finalPoint)

	p.lock(finalPoint.Row, finalPoint.Col+1)
	if err := p.moveItem(num-p.size, finalPoint.NewRelative(-1, 0)); err != nil {
		return err
	}
	p.unlock(finalPoint.Row, finalPoint.Col+1)

	if err := p.moveItem(num, finalPoint); err != nil {
		return err
	}

	p.setPoint(p.zeroPoint, 0)
	return nil
}

func (p *PuzzleSolver) setLastThree() error {
	minNum := p.size*p.size - p.size - 1
	minNextNum := p.size*p.size - p.size
	lastNum := p.size*p.size - 1

	lastFinalPoint := p.getIndexPoint(p.size*p.size - 2)
	minFinalPoint := lastFinalPoint.NewRelative(-1, 0)
	minNextFinalPoint := minFinalPoint.NewRelative(0, 1)

	minPoint := p.getNumPoint(minNum)
	minNextPoint := p.getNumPoint(minNextNum)
	lastPoint := p.getNumPoint(lastNum)

	if minPoint == nil || minNextPoint == nil || lastPoint == nil {
		return errors.New("number not found")
	}

	if minFinalPoint.Equals(*minPoint) {
		p.lockPoint(minFinalPoint)
		return p.setLastTwo(minNextNum, lastNum)
	}

	if minNextFinalPoint.Equals(*minNextPoint) {
		p.lockPoint(minNextFinalPoint)
		return p.setLastTwo(minNum, lastNum)
	}

	if lastFinalPoint.Equals(*lastPoint) {
		p.lockPoint(lastFinalPoint)
		return p.setLastTwo(minNum, minNextNum)
	}

	if p.zeroPoint.EqualsRC(p.size-1, p.size-1) {
		if p.zeroPoint.IsNear(*lastPoint) {
			p.move(p.zeroPoint.NewRelative(-1, 0))
			p.move(p.zeroPoint.NewRelative(0, -1))
			p.move(p.zeroPoint.NewRelative(1, 0))
			p.move(p.zeroPoint.NewRelative(0, 1))
		} else {
			p.move(p.zeroPoint.NewRelative(0, -1))
			p.move(p.zeroPoint.NewRelative(-1, 0))
			p.move(p.zeroPoint.NewRelative(0, 1))
			p.move(p.zeroPoint.NewRelative(1, 0))
		}
	} else if p.zeroPoint.EqualsRC(p.size-2, p.size-1) {
		if p.zeroPoint.IsNear(*minNextPoint) {
			p.move(p.zeroPoint.NewRelative(0, -1))
			p.move(p.zeroPoint.NewRelative(1, 0))
			p.move(p.zeroPoint.NewRelative(0, 1))
		} else {
			p.move(p.zeroPoint.NewRelative(1, 0))
			p.move(p.zeroPoint.NewRelative(0, -1))
			p.move(p.zeroPoint.NewRelative(-1, 0))
			p.move(p.zeroPoint.NewRelative(0, 1))
			p.move(p.zeroPoint.NewRelative(1, 0))
		}
	} else if p.zeroPoint.EqualsRC(p.size-2, p.size-2) {
		return errors.New("эта конфигурация не решается")
	} else if p.zeroPoint.EqualsRC(p.size-1, p.size-2) {
		if p.zeroPoint.IsNear(*lastPoint) {
			p.move(p.zeroPoint.NewRelative(-1, 0))
			p.move(p.zeroPoint.NewRelative(0, 1))
			p.move(p.zeroPoint.NewRelative(1, 0))
		} else {
			p.move(p.zeroPoint.NewRelative(0, 1))
			p.move(p.zeroPoint.NewRelative(-1, 0))
			p.move(p.zeroPoint.NewRelative(0, -1))
			p.move(p.zeroPoint.NewRelative(1, 0))
			p.move(p.zeroPoint.NewRelative(0, 1))
		}
	}

	minPoint = p.getNumPoint(minNum)
	minNextPoint = p.getNumPoint(minNextNum)
	lastPoint = p.getNumPoint(lastNum)

	if minPoint == nil || minNextPoint == nil || lastPoint == nil {
		return errors.New("number not found")
	}

	if !minFinalPoint.Equals(*minPoint) ||
		!minNextFinalPoint.Equals(*minNextPoint) ||
		!lastFinalPoint.Equals(*lastPoint) {
		return errors.New("эта конфигурация не решается")
	}

	p.lockPoint(minFinalPoint)
	p.lockPoint(minNextFinalPoint)
	p.lockPoint(lastFinalPoint)

	return nil
}

func (p *PuzzleSolver) setLastTwo(num1, num2 int) error {
	num1FinalPoint := p.getIndexPoint(num1 - 1)
	num2FinalPoint := p.getIndexPoint(num2 - 1)

	num1Point := p.getNumPoint(num1)
	num2Point := p.getNumPoint(num2)

	if num1Point == nil || num2Point == nil {
		return errors.New("number not found")
	}

	if num1FinalPoint.Equals(*num1Point) && num2FinalPoint.Equals(*num2Point) {
		p.lockPoint(num1FinalPoint)
		p.lockPoint(num2FinalPoint)
		return nil
	}

	if num1FinalPoint.Equals(*num1Point) {
		p.lockPoint(num1FinalPoint)
		if err := p.moveItem(num2, num2FinalPoint); err != nil {
			return err
		}
		p.lockPoint(num2FinalPoint)
		return nil
	}

	if num2FinalPoint.Equals(*num2Point) {
		p.lockPoint(num2FinalPoint)
		if err := p.moveItem(num1, num1FinalPoint); err != nil {
			return err
		}
		p.lockPoint(num1FinalPoint)
		return nil
	}

	if num1Point.IsNear(p.zeroPoint) {
		if err := p.moveItem(num1, num1FinalPoint); err != nil {
			return err
		}
		p.lockPoint(num1FinalPoint)

		if err := p.moveItem(num2, num2FinalPoint); err != nil {
			return err
		}
		p.lockPoint(num2FinalPoint)
		return nil
	}

	if num2Point.IsNear(p.zeroPoint) {
		if err := p.moveItem(num2, num2FinalPoint); err != nil {
			return err
		}
		p.lockPoint(num2FinalPoint)

		if err := p.moveItem(num1, num1FinalPoint); err != nil {
			return err
		}
		p.lockPoint(num1FinalPoint)
		return nil
	}

	return errors.New("эта конфигурация не решается")
}
