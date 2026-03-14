package main

import (
	"fmt"
	"net/http"
	"puzzle15/puzzle"
	"strconv"

	"github.com/gin-gonic/gin"
)

func registerRoutes(r *gin.Engine) {
	r.GET("/status", getStatusHandler)

	api := r.Group("/api")
	{
		puzzle := api.Group("/puzzle")
		{
			puzzle.GET("/min", getMinPuzzleDateHandler)
			puzzle.GET("/:year/:month/:day", getPuzzleHandler)
			puzzle.POST("/solve", solvePuzzleHandler)
		}
	}
}

func getStatusHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "ok",
	})
}

func getMinPuzzleDateHandler(c *gin.Context) {
	response := MinPuzzleResponse{
		Year:  minYear,
		Month: minMonth,
		Day:   minDay,
	}

	c.JSON(http.StatusOK, response)
}

func getPuzzleHandler(c *gin.Context) {
	yearStr, monthStr, dayStr := c.Param("year"), c.Param("month"), c.Param("day")
	fmt.Println(yearStr, monthStr, dayStr)

	year, err := strconv.Atoi(yearStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Message: "неправильный год"})
		return
	}

	month, err := strconv.Atoi(monthStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Message: "неправильный месяц"})
		return
	}

	day, err := strconv.Atoi(dayStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Message: "неправильный день"})
		return
	}

	puzzle, err := getDaylyPuzzle(year, month, day)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, PuzzleResponse{puzzle})
}

func solvePuzzleHandler(c *gin.Context) {
	var request SolvePuzzleRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Message: "invalid request body"})
		return
	}

	moves, err := puzzle.SolvePuzzle(request.Puzzle)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, SolvePuzzleResponse{moves})
}
