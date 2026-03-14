package puzzle

type Direction string

const (
	DirectionUp    Direction = "U"
	DirectionDown  Direction = "D"
	DirectionRight Direction = "R"
	DirectionLeft  Direction = "L"
)

type PuzzleRow []int
type PuzzleGrid []PuzzleRow

type Point struct {
	Row int
	Col int
}

func (p PuzzleGrid) Copy() PuzzleGrid {
	value := make(PuzzleGrid, len(p))
	for i := range len(p) {
		value[i] = make(PuzzleRow, len(p[i]))
		copy(value[i], p[i])
	}
	return value
}

func NewPoint(row, col int) Point {
	return Point{Row: row, Col: col}
}

func (p Point) NewRelative(dr, dc int) Point {
	return Point{
		Row: p.Row + dr,
		Col: p.Col + dc,
	}
}

func (p Point) Equals(other Point) bool {
	return p.Row == other.Row && p.Col == other.Col
}

func (p Point) EqualsRC(row, col int) bool {
	return p.Row == row && p.Col == col
}

func (p Point) EqualsRows(other Point) bool {
	return p.Row == other.Row
}

func (p Point) EqualsCols(other Point) bool {
	return p.Col == other.Col
}

func (p Point) IsNear(other Point) bool {
	dr := p.Row - other.Row
	if dr < 0 {
		dr = -dr
	}
	dc := p.Col - other.Col
	if dc < 0 {
		dc = -dc
	}
	return dr+dc == 1
}

type PriorityQueue []*State

func (pq PriorityQueue) Len() int { return len(pq) }
func (pq PriorityQueue) Less(i, j int) bool {
	if pq[i].f == pq[j].f {
		return pq[i].h < pq[j].h
	}
	return pq[i].f < pq[j].f
}
func (pq PriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index = i
	pq[j].index = j
}
func (pq *PriorityQueue) Push(x interface{}) {
	item := x.(*State)
	item.index = len(*pq)
	*pq = append(*pq, item)
}
func (pq *PriorityQueue) Pop() interface{} {
	old := *pq
	n := len(old)
	item := old[n-1]
	item.index = -1
	*pq = old[:n-1]
	return item
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}
