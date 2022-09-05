aws = {
    region = "ap-southeast-1"     
    profile = "Tech-challenge"
}

### add additional tags whenever needed
common_tags = {
    Author       = "Deepak"
    project-code = "Tech-challenge"
    environment  = "Test"
    creation     = "Terraform"
}


alb = [
    {
        name   = "alb-tech-challenge"
        subnets = ["sub-a-pub","sub-c-pub"]
        security_groups = ["sgrp-pub-lb"]  
        usr ={
            target_group = {
                #name = "usr-rp-target-group"
                name = "ecs-target-group"
                port = 3000
                protocol = "HTTP"
                target_type = "ip"
                healthcheck = {
                    healthy_threshold   = 2
                    interval            = 30
                    protocol            = "HTTP"
                    matcher             = 200
                    timeout             = null
                    path                = "/"
                    unhealthy_threshold = 2            
                }
            }   
        }
        listener = {
            port = 80
            protocol = "HTTP"
            type = "forward"
        }                
    }
]
