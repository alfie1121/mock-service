#!/bin/bash

# EX: ./auto.sh hello

if [ "$1" == "" ];then
    echo "參數錯誤"
    exit
fi

p=$1
# path=vendor/backend/protobufs/$p/
path=protobufs/$p/
line=$(cat $path$p.pb.go|grep -n -i "type $1Server interface"|awk -F: '{print $1}')
serverName=$(echo $p | awk '{for (i=1;i<=NF;i++)printf toupper(substr($i,0,1))substr($i,2,length($i))"";printf "\n"}')

fileFlag=""
if [ -f "$p.go" ];then
    fileFlag="_2"
fi

# echo $line
startLine=$line
flag=""
endLine=0
while [ "$flag" != "}" ]
do
    flag=$(sed -n $startLine'p' $path$p.pb.go)
    (( startLine++ ))
    (( endLine++ ))
done

((endLine=line+endLine-2))
((line++))

echo '
package main

import (
	"context"
    // "backend/protobufs/'$p'"
	"mock/protobufs/'$p'"
	"log"
	"net"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type '$p'Server struct{}

func '$p'New() *'$p'Server {
	return &'$p'Server{}
}
'>>$p$fileFlag.go

for ((i=$line;i<=$endLine;i++))
do
    jump=$(sed -n $i'p' $path$p.pb.go|grep -c "//")

    if [ "$jump" == "1" ];then
        continue
    fi

    test=$(sed -n $i'p' $path$p.pb.go| sed 's/*/*'$p'./g')

    funcName=$(echo $test | awk -F'(' '{print $1}')

    stream=$(sed -n $i'p' $path$p.pb.go|grep -c $serverName"_")

    if [ "$stream" == "0" ];then
        ctx1=$(echo $test | awk -F'(' '{print $2}'| awk '{print $1}')
        ctx2=$(echo $test | awk -F'(' '{print $2}'| awk '{print $2}')

        req1=$(echo $test | awk -F'(' '{print $2}'| awk '{print $3}')
        req2=$(echo $test | awk -F'(' '{print $2}'| awk '{print $4}')

        resp1=$(echo $test | awk '{print $3}')
        resp2=$(echo $test | awk '{print $4}')

        echo '
        func (s *'$p'Server) '$funcName'(ctx '$ctx1' in '$ctx2' '$req1' '$req2' '$resp1$resp2' {
            return nil,errorData("'$p'.'$funcName'")
        }

        '>>$p$fileFlag.go
    else
        req=$(echo $test | awk -F'(' '{print $2}')

        echo '
        func (s *'$p'Server) '$funcName'(server '$p'.'$req' {
            return errorData('$p'.'$funcName')
        }

        '>>$p$fileFlag.go
    fi
done


echo '
func Boot'$serverName'GRPCService(serveAddr string, src '$p'.'$serverName'Server) {
    lis, err := net.Listen("tcp", serveAddr)
	if err != nil {
		log.Fatal("Boot'$p'GRPCService Error: ", err)
	}

	s := grpc.NewServer(grpc.ConnectionTimeout(30 * time.Second))
	'$p'.Register'$serverName'Server(s, src)
	reflection.Register(s)

	log.Println("'$p' GRPC server listen and serve: ", serveAddr)
	if err = s.Serve(lis); err != nil {
		log.Fatal("'$p' GRPC server failed to serve: ", err)
	}
}
' >>$p$fileFlag.go

gofmt -w $p$fileFlag.go