
package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
)

type Books struct {
	Id     int    `json:"id"`
	Name   string `json:"name"`
	Author string `json:"author"`
}

/*
func list() (string, error) {
	books := []Books{
		{Id: 1, Name: "NodeJS", Author: "NodeJS"},
		{Id: 2, Name: "Golang", Author: "Golang"},
	}

	res, _ := json.Marshal(&books)
	return string(res), nil
}
*/

type Response struct {
	StatusCode int    `json:"statusCode"`
	Body       string `json:"body"`
}

func list() (Response, error) {
	books := []Books{
		{Id: 1, Name: "NodeJS", Author: "NodeJS"},
		{Id: 2, Name: "Golang", Author: "Golang"},
	}

	res, _ := json.Marshal(&books)
	// return string(res), nil // response not valid format of API Gateway
	return Response{
		StatusCode: 200,
		Body: string(res),
	}, nil
}

func main() {
	lambda.Start(list)
}

