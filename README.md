# mock-service
自建自起一個私有專案的 grpc mock service

```
init_porto.go -> 填上自己要用的 protobufs
go.mod -> 填上自己要用的版本 
go mod init mock (如是從頭寫新的需要這行) 
go mod tidy 
go mod vendor (這裡會是 gitlab 或是 github 的 protobufs)

auto.sh 的 path 與 import 要換上自己的資料夾位置

EX: ./auto.sh hello 
hello 資料夾為示範，如有自己的 gitlab 或是 github 在自行調整

mv .env_example .env
```
