locals {
  cw       = fileexists(var.csvfile) ? csvdecode(file(var.csvfile)) : []
  cw_specs      = length(var.cw_specs) > 0 ? var.cw_specs : local.cw
  cw_unique = local.cw_specs[*].sno
  cw_list       = zipmap(local.cw_unique, local.cw_specs)
  cw_action = {
    for key, value in local.cw_list :
    value.alarm_name => value
    if value.environment == var.environment && var.create_cw == "yes"

  }
}
#---------------------------------------------------------
#Fetching EC2 instance details
#---------------------------------------------------------
data "aws_instances" "thisinstances" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "ec2"
  }
  instance_tags = {
    Name = lookup(each.value,"instance_name")
  }

  instance_state_names = ["running", "stopped"]
}
data "aws_instance" "thisinstance" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "ec2"
  }
  instance_id =join(",",data.aws_instances.thisinstances[each.key].ids)
}
#---------------------------------------------------------
#Fetching LB instance details
#---------------------------------------------------------
data "aws_lb" "thislb" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "lb" && value.load_balancer_name != "" && value.load_balancer_tg_name != ""
  }
  name = lookup(each.value,"load_balancer_name")
}
data "aws_arn" "lbarn" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes"  && value.alarm_type == "lb"  && value.load_balancer_name != "" && value.load_balancer_tg_name != ""
  }
  arn = data.aws_lb.thislb[each.key].arn
}
#---------------------------------------------------------
#Fetching LB_TG instance details
#---------------------------------------------------------
data "aws_lb_target_group" "thistg" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "lb" && value.load_balancer_name != "" && value.load_balancer_tg_name != ""
  }
  name = lookup(each.value,"load_balancer_tg_name")
}
data "aws_arn" "tgarn" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "lb" && value.load_balancer_name != "" && value.load_balancer_tg_name != ""
  }
  arn = data.aws_lb_target_group.thistg[each.key].arn
}
#---------------------------------------------------------
#Fetching SNS  details
#
#Empty_SNS is a workaround for data source required SNS name
#---------------------------------------------------------
data "aws_sns_topic" "thissns" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type != "cdn" #&& value.sns_quantity == "1" #&& value.alarm_type == "lb" && value.load_balancer_name != "" && value.load_balancer_tg_name != ""
  }
  name = lookup(each.value,"sns_topic_name")
}

data "aws_sns_topic" "thissns2" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type != "cdn"
  }
  name = lookup(each.value,"sns_topic_name_2")
}

data "aws_sns_topic" "thissns3" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type != "cdn"
  }
  name = lookup(each.value,"sns_topic_name_3")
}
/* to see output
output "test1" {
  value = data.aws_sns_topic.thissns[*]
}

output "test2" {
  value = data.aws_sns_topic.thissns2[*]
}

output "test3" {
  value = data.aws_sns_topic.thissns3[*]
}
*/
#---------------------------------------------------------
#Fetching RDS instance details
#---------------------------------------------------------
data "aws_db_instance" "this_rds" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "rds"
  }
  db_instance_identifier = lookup(each.value,"rds_identifier")
}

#---------------------------------------------------------
#Alarm creation for disk_demensions
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_demensions_linux" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "disk_used_percent" && value.alarm_type == "ec2" && value.os_type == "linux"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  dimensions          = {
          "ImageId"=data.aws_instance.thisinstance[each.key].ami,
          "InstanceType"=data.aws_instance.thisinstance[each.key].instance_type,
          "device"=lookup(each.value,"device_for_disk_metric","nvme0n1p2"),
          "fstype"=lookup(each.value,"fstype_for_disk_metric","xfs"),
          "path"=lookup(each.value,"path_for_disk_metric","/"),
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
  }
  tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

resource "aws_cloudwatch_metric_alarm" "disk_demensions_windows" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "LogicalDisk % Free Space" && value.alarm_type == "ec2" && value.os_type == "windows"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  #alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  #ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]  
  dimensions          = {
          "ImageId"=data.aws_instance.thisinstance[each.key].ami,
          "InstanceType"=data.aws_instance.thisinstance[each.key].instance_type,
          "instance"=lookup(each.value,"instance_for_disk_metric","C:"),
          "objectname"=lookup(each.value,"objectname_for_disk_metric","LogicalDisk"),
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
  }
    tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}
#---------------------------------------------------------
#Alarm creation for memory_demensions
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_demensions_linux" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "mem_used_percent" && value.alarm_type == "ec2" && value.os_type == "linux"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  dimensions          = {
          "ImageId"=data.aws_instance.thisinstance[each.key].ami,
          "InstanceType"=data.aws_instance.thisinstance[each.key].instance_type,
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
  }
  tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}
resource "aws_cloudwatch_metric_alarm" "memory_demensions_windows" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "Memory % Committed Bytes In Use" && value.alarm_type == "ec2" && value.os_type == "windows"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  dimensions          = {
          "ImageId"=data.aws_instance.thisinstance[each.key].ami,
          "InstanceType"=data.aws_instance.thisinstance[each.key].instance_type,
          "objectname"=lookup(each.value,"objectname_for_memory_metric","Memory"),
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
  }
    tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

resource "aws_cloudwatch_metric_alarm" "custom_memory_demensions_windows" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "Mem_Used_Percent" && value.alarm_type == "ec2" && value.os_type == "windows"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  dimensions          = {
          "ImageId"=data.aws_instance.thisinstance[each.key].ami,
          "InstanceType"=data.aws_instance.thisinstance[each.key].instance_type,
          "objectname"=lookup(each.value,"objectname_for_memory_metric","Memory"),
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
  }
    tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for cpu_demensions
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "CPUUtilization" && value.alarm_type == "ec2"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  #alarm_actions       =["arn:aws:sns:ap-southeast-1:${var.account_no}:${lookup(each.value,"sns_topic_name")}"]
  #ok_actions          =["arn:aws:sns:ap-southeast-1:${var.account_no}:${lookup(each.value,"sns_topic_name")}"]
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  dimensions          = {
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
        }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for statuscheckfailed_inst_demensions
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "statuscheckfailed_inst_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "StatusCheckFailed_Instance" && value.alarm_type == "ec2"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  dimensions          = {
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
        }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for statuscheckfailed_inst_demensions
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "statuscheckfailed_sys_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "StatusCheckFailed_System" && value.alarm_type == "ec2"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn,data.aws_sns_topic.thissns3[each.key].arn]
  dimensions          = {
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
        }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for ec2_availability_dimensions
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ec2_availability" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "StatusCheckFailed" && value.alarm_type == "ec2"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  dimensions          = {
          "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
        }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for network_throughput
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_throughput" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "NetworkIn" && value.alarm_type == "ec2"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")                                                            
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  metric_query {
    id          = "e1"
    expression  = "((m1+m2)/300/1000/1000/1000*8)/0.75*100"
    label       = "Network Utilization"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name         = "NetworkIn"
      namespace           = "AWS/EC2"
      period              = lookup(each.value,"period")  
      stat                = "Sum"

      dimensions = {
#        NetworkIn = "AWS/EC2"
        "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name         = "NetworkOut"
      namespace           = "AWS/EC2"
      period              = lookup(each.value,"period")  
      stat                = "Sum"

      dimensions = {
#        NetworkOut = "AWS/EC2"
        "InstanceId"=join(",",data.aws_instances.thisinstances[each.key].ids)
      }
    }
  }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}
#---------------------------------------------------------
#Alarm creation for lb_demensions
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "lb_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "lb"  && value.load_balancer_name != "" && value.load_balancer_tg_name != ""
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${element(split("/",data.aws_arn.lbarn[each.key].resource),2)}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  dimensions          ={
            "TargetGroup"  = "${element(split("/",data.aws_arn.tgarn[each.key].resource),0)}/${element(split("/",data.aws_arn.tgarn[each.key].resource),1)}/${element(split("/",data.aws_arn.tgarn[each.key].resource),2)}",#/${element(split("/",data.aws_arn.tgarn[each.key].resource),3)}
            "LoadBalancer" = "${element(split("/",data.aws_arn.lbarn[each.key].resource),1)}/${element(split("/",data.aws_arn.lbarn[each.key].resource),2)}/${element(split("/",data.aws_arn.lbarn[each.key].resource),3)}"
          }
    tags = merge(
    {
      Name         =replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}
#---------------------------------------------------------
#Alarm creation for s3
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "s3_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "s3" 
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"s3_bucketname")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  dimensions          ={
    "StorageType"=lookup(each.value,"s3_storage_type"),
    "BucketName"=lookup(each.value,"s3_bucketname")
    }
    tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}
#---------------------------------------------------------
#Alarm creation for ASG
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "asg_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "asg" 
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"asg_group_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  dimensions          ={
    "AutoScalingGroupName"=lookup(each.value,"asg_group_name")
    }
  tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#CPU Alarm creation for ASG Instances
#---------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "asg_ec2_cpu_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "CPUUtilization" && value.alarm_type == "asg"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"asg_group_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  dimensions          = {
          "AutoScalingGroupName" = lookup(each.value,"asg_group_name")
        }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for Cloudtrail API
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this_cloudtrail_api_demensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "local_controls" 
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = lookup(each.value,"alarm_description")
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  treat_missing_data  = lookup(each.value, "treat_missing_data", "notBreaching")
  dimensions          = lookup(each.value, "dimensions", null)
  tags = merge(
    {
      Name         = lookup(each.value,"alarm_name",null)
    },
    var.common_tags
  )
}


#---------------------------------------------------------
#Alarm creation for rds
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_dimensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "rds"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods") 
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")   
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"rds_identifier")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
 
  dimensions = {
    DBInstanceIdentifier = lookup(each.value,"rds_identifier")
  }
  tags = merge(
    {
      Name         =replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for rds_availability_dimensions
#---------------------------------------------------------
resource "aws_db_event_subscription" "rds_availability_dimensions" {
   for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "rds" && value.metric_name == "Availability" 
  }
  name      = lookup(each.value,"alarm_name")
  sns_topic = data.aws_sns_topic.thissns[each.key].arn

  source_type = "db-instance"
  source_ids  = [lookup(each.value,"rds_identifier")]

  event_categories = [
    "availability"
  ]
}

#---------------------------------------------------------
#Alarm creation for rds_readreplication_dimension
#---------------------------------------------------------
resource "aws_db_event_subscription" "rds_readreplication_dimension" {
   for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "rds" && value.metric_name == "ReadReplica" 
  }
  name      = lookup(each.value,"alarm_name")
  sns_topic = data.aws_sns_topic.thissns[each.key].arn

  source_type = "db-instance"
  source_ids  = [lookup(each.value,"rds_identifier")]

  event_categories = [
    "read replica"
  ]
}


#---------------------------------------------------------
#Alarm creation for efs
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this_efs" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "efs" 
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods") 
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")   
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"efs_identifier")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       = distinct(compact(concat([data.aws_sns_topic.thissns[each.key].arn])))
  ok_actions          = distinct(compact(concat([data.aws_sns_topic.thissns[each.key].arn])))
  dimensions ={
    FileSystemId = lookup(each.value,"efs_identifier")
  }
}


#---------------------------------------------------------
#Alarm creation for fsx_readthroughput_dimension
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "fsx_readthroughput_dimension" {
   for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "DataReadBytes" && value.alarm_type == "fsx"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")                                                    
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  metric_query {
    id          = "e1"
    expression  = "(m1*100)/((m1+m2)/300)"
    label       = "Percent Data Read Throughput"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name         = "DataReadBytes"
      namespace           = "AWS/FSx"
      period              = lookup(each.value,"period")  
      stat                = "Sum"

      dimensions = {
        FileSystemId = lookup(each.value,"fsx_identifier") 
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name         = "DataWriteBytes"
      namespace           = "AWS/FSx"
      period              = lookup(each.value,"period") 
      stat                = "Sum"

      dimensions = {
        FileSystemId = lookup(each.value,"fsx_identifier") 
      }
    }
  }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}


#---------------------------------------------------------
#Alarm creation for fsx_writethroughput_dimension
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "fsx_writethroughput_dimension" {
   for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "DataWriteBytes" && value.alarm_type == "fsx"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")                                                    
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn]
  metric_query {
    id          = "e1"
    expression  = "(m2*100)/((m1+m2)/300)"
    label       = "Percent Data Write Throughput"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name         = "DataReadBytes"
      namespace           = "AWS/FSx"
      period              = lookup(each.value,"period")  
      stat                = "Sum"

      dimensions = {
        FileSystemId = lookup(each.value,"fsx_identifier") 
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name         = "DataWriteBytes"
      namespace           = "AWS/FSx"
      period              = lookup(each.value,"period") 
      stat                = "Sum"

      dimensions = {
        FileSystemId = lookup(each.value,"fsx_identifier") 
      }
    }
  }
     tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for fsx_memorycapacity_dimension
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this_fsx" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "fsx"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods") 
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")   
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"fsx_identifier")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       = distinct(compact(concat([data.aws_sns_topic.thissns[each.key].arn])))
  ok_actions          = distinct(compact(concat([data.aws_sns_topic.thissns[each.key].arn])))
  dimensions ={
    FileSystemId = lookup(each.value,"fsx_identifier") 
  }
  
}


#---------------------------------------------------------
#Alarm creation for AWS Backup
#---------------------------------------------------------
resource "aws_backup_vault_notifications" "this_backup" {
    for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.alarm_type == "awsbackup" 
  }
  backup_vault_name   = lookup(each.value,"aws_backup_identifier")
  sns_topic_arn       = data.aws_sns_topic.thissns[each.key].arn
  backup_vault_events = ["BACKUP_JOB_FAILED"]
}

#---------------------------------------------------------
#Alarm creation for custom Login Alert (/ec2/vm-pa-prd-iz-cms-applogs)
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "custom_dimensions" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "LoginAccess" && value.alarm_type == "Custom"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}

#---------------------------------------------------------
#Alarm creation for custom Login Alert (/ec2/vm-pa-prd-ez-pace-cd-applogs)
#---------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "pace_cd_applogs" {
  for_each = {
    for key, value in local.cw_list :
    key => value
    if value.environment == var.environment && var.create_cw == "yes" && value.metric_name == "PacesLoginAccess" && value.alarm_type == "Custom"
  }
  alarm_name          = lookup(each.value,"alarm_name")
  comparison_operator = lookup(each.value,"comparison_operator")
  evaluation_periods  = lookup(each.value,"evaluation_periods")
  metric_name         = lookup(each.value,"metric_name")
  namespace           = lookup(each.value,"namespace") 
  period              = lookup(each.value,"period")                                                                  
  statistic           = lookup(each.value,"statistic") 
  threshold           = lookup(each.value,"threshold")
  alarm_description   = "${lookup(each.value,"instance_name")}-${lookup(each.value,"alarm_description")}"
  alarm_actions       =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  ok_actions          =[data.aws_sns_topic.thissns[each.key].arn,data.aws_sns_topic.thissns2[each.key].arn]
  tags = merge(
    {
      Name         = replace(lookup(each.value,"alarm_name",null),">","")
    },
    var.common_tags
  )
}