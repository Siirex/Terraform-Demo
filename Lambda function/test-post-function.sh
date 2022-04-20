
#! /bin/bash

# Call Function 'create' with POST Method:
api_url="https://y260clap1b.execute-api.ap-southeast-1.amazonaws.com/Test_1/post-create"
echo `curl -sX POST -d '{"id":3, "name": "SIIREX", "author": "TERRAFORM"}' $api_url`

# hoặc dùng Postman: https://www.youtube.com/watch?v=M91vXdjve7A
