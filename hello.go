package main

import (
	"context"
	// "backend/protobufs/hello"
	"log"
	"mock/protobufs/hello"
	"net"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type helloServer struct{}

func helloNew() *helloServer {
	return &helloServer{}
}

func (s *helloServer) Ping(ctx context.Context, in *hello.PingRequest) (*hello.PingResponse, error) {
	return nil, errorData("hello.Ping")
}

func (s *helloServer) Hello(ctx context.Context, in *hello.HelloRequest) (*hello.HelloResponse, error) {
	return nil, errorData("hello.Hello")
}

func BootHelloGRPCService(serveAddr string, src hello.HelloServer) {
	lis, err := net.Listen("tcp", serveAddr)
	if err != nil {
		log.Fatal("BoothelloGRPCService Error: ", err)
	}

	s := grpc.NewServer(grpc.ConnectionTimeout(30 * time.Second))
	hello.RegisterHelloServer(s, src)
	reflection.Register(s)

	log.Println("hello GRPC server listen and serve: ", serveAddr)
	if err = s.Serve(lis); err != nil {
		log.Fatal("hello GRPC server failed to serve: ", err)
	}
}
