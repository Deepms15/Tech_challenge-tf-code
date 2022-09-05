

resource "aws_alb_listener_rule" "rule" {
    count = length(var.path_patterns)

    listener_arn = var.listener_arn
    priority     = var.priority + count.index

    action {
    type             = "forward"
    target_group_arn = var.target_group_arn
    }

    # Always pass host-based routing condition, with '*.*' being default
    #
    # NOTE: You can have multiple paths but only a single hostname
   
   condition {
    host_header {
      values = [var.host_header]
	  }
	 }

    condition {
    path_pattern {
      values = ["${element(var.path_patterns, count.index)}"]
      }
     }
}