

variable "name" {type=string}

variable "common_tags" {
    type        = map
    default     = {}
}

resource "aws_ecs_cluster" "main" {
    name = "${var.name}-cluster"

    tags = merge(
        {
            Name="${var.name}-cluster", 
        },
        var.common_tags,
    )
}

output "id" {
    value = aws_ecs_cluster.main.id
}