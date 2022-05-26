
# Set Boto3: https://aws.amazon.com/vi/sdk-for-python/

import boto3

def lambda_handler(event, context):
    print('Starting a new build ...')
    cb = boto3.client('codebuild')
    build = {
      # 'projectName': 'terraform_codebuild' //dùng khi function được trigger từ SNS Topic
      
      # Dựa trên argument 'custom_data' trong cấu hình CodeCommit Trigger
      'projectName': event['Records'][0]['customData'],
      'sourceVersion': event['Records'][0]['codecommit']['references'][0]['commit']
    }
    cb.start_build(**build)
    print('Successfully launched a new CodeBuild project!')

    return "Success"
