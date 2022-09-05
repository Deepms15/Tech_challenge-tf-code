resource "aws_db_instance" "database-instance" {
  
  allocated_storage           = var.allocated_storage
  instance_class              = var.instance_class
  availability_zone           = var.availability_zone
  identifier                  = var.identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  db_subnet_group_name        = var.db_subnet_group_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  db_name                     = var.db_name
  username                    = var.username
  password                    = var.password
  port                        = var.port
  multi_az                    = var.multi_az
  storage_encrypted           = var.storage_encrypted
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  skip_final_snapshot         = var.skip_final_snapshot
  tags                        = var.tags

}
