
# Function dựa trên package os để in ra giá trị của 'event'
# ... và thông tin của các biến môi trường 'os.environ' được lambda sử dụng:

import os

def entrypoint(event, context):
    print('Starting a new build ...')
    print('## ENVIRONMENT VARIABLES')
    print(os.environ)
    print('## EVENT')
    print(event)
