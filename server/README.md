# Puzzle15 - Сервер

### Команда для запуска:
```
cd src
go run .
```

### API

API | Описание | Input | Output
|--|--|--|--|
GET: `/status` | Проверка жив ли сервер | | 200
GET: `/api/puzzle/min` | Получение минимальной даты для ежедневных головоломок | | `{year, month, day}`
GET: `/api/puzzle/:year/:month/:day` | Получить конфигурацию ежедневной головоломки по дате | | `{puzzle: int[][]}`
POST: `/api/puzzle/solve` | Получить алгоритм для сборки головоломки | `{puzzle: int[][]}` | `{moves: string[]}`
