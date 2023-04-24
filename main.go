package main

import (
	"errors"
	"log"
	"os"

	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()

	go BootHelloGRPCService(os.Getenv("HELLO_GRPC_SERVER_ADDR"), helloNew())

	forever := make(chan int)
	<-forever
}

func errorData(fn string) error {
	log.Println(fn)
	return errors.New("error")
}
