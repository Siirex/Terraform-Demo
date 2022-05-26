
# Cập nhật phiên bản mới (release) của Lambda Function source lên S3 Bucket

include .env

build: clean
	zip function_codebuild.zip function_codebuild.py
	zip function_logs.zip function_logs.py

upload_1: function_codebuild.zip
	aws s3 cp function_codebuild.zip s3://$(BUCKET_NAME)/$(BUCKET_FUNCTION_BUILD_KEY)

upload_2: function_logs.zip
	aws s3 cp function_logs.zip s3://$(BUCKET_NAME)/$(BUCKET_FUNCTION_LOGS_KEY)

update_lambda:
	aws lambda update-function-code --function-name $(FUNCTION_BUILD_NAME) --s3-bucket $(BUCKET_NAME) --s3-key $(BUCKET_FUNCTION_BUILD_KEY)
	aws lambda update-function-code --function-name $(FUNCTION_LOGS_NAME) --s3-bucket $(BUCKET_NAME) --s3-key $(BUCKET_FUNCTION_LOGS_KEY)

clean:
	rm function_codebuild.zip function_logs.zip || echo "Already clean!!!"
