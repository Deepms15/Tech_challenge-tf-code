
aws = {
    region = "ap-southeast-1"
    profile = "Tech-challenge" 
}

#vpc_id is read from fabric state file
#vpc_id = "vpc-#################"

### add additional tags whenever needed
common_tags = {
    Author       = "Deep-tech"
    project-code = "Tech-challenge"
    environment  = "Test"
    creation     = "Terraform"
}


name   = "ecs-Tech-challenge"

#env_name = "VTT_LISTENHOST"
#env_value = "0.0.0.0"

usr_ecs_cluster = [
    {
        subnets     = ["sub-a-app","sub-c-app"]
        security_groups = ["sgrp-ecs-app"]
        template    = "./templates/ecs/app.json.tpl" 
        task_definition = {
            execution_role  = "ecsTaskExecutionRole"
            network_mode    = "awsvpc"
            compatibilities = "FARGATE"
            #Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)
            cpu             = 256
            #Fargate instance memory to provision (in MiB)
            memory          = 512
        } 
        service = {
            #Number of docker containers to run
            desired_count = 1
            launch_type = "FARGATE"
            assign_public_ip = false
            #Port exposed by the docker image to redirect traffic to
            port             = 3000
            #Docker image to run in the ECS cluster
            image            = "123456789.dkr.ecr.ap-southeast-1.amazonaws.com/tech:latest"
            log_group        = "/ecs/ecs-tech-challenge-lg"
            logs_stream_pfx  = "ecs"
            log_retention    = 7
            autoscale        = true
            #Autoscaling configuration - Valid only if autoscale=true            
            max_count        = 4
            max_cpu_util     = 80
            scale_in_cooldown = 300
            scale_out_cooldown= 300
            autoScalingRole   = "AWSServiceRoleForApplicationAutoScaling_ECSService"             
        }            
    }
]
