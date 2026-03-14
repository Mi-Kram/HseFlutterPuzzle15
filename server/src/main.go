package main

import (
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	registerRoutes(r)

	addr := getAddr()
	if err := r.Run(addr); err != nil {
		fmt.Println(err)
	}
}

func getAddr() string {
	if portEnv := os.Getenv("APP_PORT"); portEnv != "" {
		return ":" + portEnv
	}
	return ":8080"
}
