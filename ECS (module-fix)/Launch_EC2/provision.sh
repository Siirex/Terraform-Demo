
#!/bin/bash

# Cho biết Instance này sẽ nằm trong ECS Cluster nào?
# Nếu không có nó, các Container sẽ không tìm thấy Instance nào, đồng nghĩa Task sẽ không thành công!!! 
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config
