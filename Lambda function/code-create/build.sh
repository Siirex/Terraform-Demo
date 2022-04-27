
#!/bin/bash
source ~/.profile #update GOLANG
go mod init main && go get #chạy mới build được GOLANG
go build -o ./code/main ./code/main.go
zip ./code/create.zip ./code/main
