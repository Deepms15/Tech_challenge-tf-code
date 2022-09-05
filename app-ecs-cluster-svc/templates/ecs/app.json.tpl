[
  {
    "name": "${app_name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "${logs_stream_pfx}"
        }
    },    
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "command": ["serve"],
    "environment" : [
			{
				"name": "VTT_LISTENHOST",
				"value": "0.0.0.0"
			},
      {
        "name": "VTT_DBHOST",
				"value": "rds-endpoints"
      }
		]
  }
]